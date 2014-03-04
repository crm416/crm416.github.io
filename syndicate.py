# -*- coding: utf-8 -*

import os
import sys
import argparse
import re
import string
import datetime
from jinja2 import Environment, FileSystemLoader

reload(sys)
sys.setdefaultencoding('utf-8')

# get optional command-line arguments
parser = argparse.ArgumentParser("Turn Markdown files into static web sites.")
parser.add_argument(
    '--template', dest='template_file', metavar='template_file',
    nargs='?', default="post.html", help='post template file')
parser.add_argument('--gfm', dest='gfm', action='store_const',
                    const=True, default=False, help='activate github-flavored markdown')
parser.add_argument('--minify', dest='minify', action='store_const',
                    const=True, default=False, help='activate CSS minification')
parser.add_argument('--prettify', dest='prettify', action='store_const',
                    const=True, default=False, help='activate code syntax highlighting')
parser.add_argument('posts', nargs='*',
                    default=[], help='a list of posts to generate (defaults to all possible posts), specified by the name of the post\'s directory')
args = parser.parse_args()

# iterate over all markdown files in this directory and subdirectories

ROOT_DIRECTORY = os.path.dirname(os.path.realpath(__file__))
FILENAME_MATCH = "markdown.txt"
FILENAME_DATE = re.compile(
    r'([0-9]{4})-([0-9]{1,2})-([0-9]{1,2})\.(md|txt|markdown|mdown)$')
CSS_DIRECTORY = ROOT_DIRECTORY + "/production/static/css/"

# for share buttons
ROOT_URL = "http://www.princeton.edu/~crmarsh/"


def buttonHTML(title, URL):
    twitter = '<a class="btn btn-primary" href="http://twitter.com/intent/tweet?url=%s&text=%s&via=crm416">Tweet</a>' % (
        URL, title)
    facebook = '<a class="btn btn-primary" href="http://facebook.com/sharer.php?u=%s">Like</a>' % URL
    google = '<a class="btn btn-primary" href="https://plus.google.com/share?url=http%%3A%%2F%%2F%s">+1</a>' % URL[
        7:]
    return twitter + ' | ' + facebook + ' | ' + google


# a list of all the files in ROOT_DIRECTORY that match FILENAME_MATCH
def post_filter(path, name):
    def valid_filename(s):
        return bool(FILENAME_DATE.match(s)) or s == FILENAME_MATCH
    return ((not args.posts) or (path.split('/')[-1] in args.posts)) and valid_filename(name)

csv_files = [os.path.join(root, name)
             for root, dirs, files in os.walk(ROOT_DIRECTORY)
             for name in files
             if post_filter(root, name)]

# set compilation function
compile_markdown = "ruby utils/gfm.rb %s | perl utils/markdown.pl > temp.txt" if args.gfm else "perl utils/markdown.pl %s > temp.txt"

# compress CSS
if args.minify:
    combined_css_path = CSS_DIRECTORY + 'combined.css'
    # delete CSS if already exists
    if os.path.isfile(combined_css_path):
        os.remove(combined_css_path)

    # merge all CSS
    css_files = [os.path.join(root, name) for root, dirs, files in os.walk(CSS_DIRECTORY)
                 for name in files if ".css" in name]
    all_css = ''.join([open(f).read() for f in css_files])

    # compress CSS
    from cssmin import cssmin
    minifed_css = cssmin(all_css)

    # store all CSS in single file
    combined_css = open(combined_css_path, "w+")
    combined_css.write(minifed_css)

# aggregate posts for feed
allPosts = []

# generate blog posts
for file_path in csv_files:

    print "Producing " + file_path

    # determine the current directory
    pathArray = file_path.split("/")
    del(pathArray[-1])
    directory = "/".join(pathArray)

    sys.stdout.flush()

    with open(file_path, 'r') as f:
        results = re.findall(r'\|\s*(.*):\s*"(.*)"\n', f.read())
        meta = {}
        for (x, y) in results:
            meta[x] = y

    temp_file_path = directory + "/temp.md"
    with open(file_path, 'r') as f:
        # Delete all meta information (everything before first header)
        text = re.sub(r'(?s).*?(#.*)', r'\g<1>', f.read(), 1)
        open(temp_file_path, 'w').write(text)
    file_path = temp_file_path

    # extract the title from the markdown
    if 'title' in meta:
        title = meta['title']
    else:
        with open(file_path, 'r') as f:
            title = f.readline()
        while title[0] == "#" or title[0] == " ":
            title = title[1:]
        title = title.strip()

    # extract description
    if 'description' in meta:
        description = meta['description']
    else:
        description = None

    # extract date from file name
    m = FILENAME_DATE.match(file_path.split("/")[-1])
    if m:
        date = datetime.date(int(m.group(1)), int(m.group(2)), int(m.group(3)))
        fdate = date.strftime("%B %-d, %Y")
    else:
        date = datetime.date.min
        fdate = ""

    # run the converter and output to a temp.txt
    os.system(compile_markdown % file_path)

    # now read the output from temp.txt and inject into post.html
    temp_file = open("temp.txt", "rb")

    # body HTML formatted first so as to be separable in feed
    bodyHTML = temp_file.read()

    if args.prettify:
        # need to do two passes b/c possible negative lookbehind solution
        # requires fixed-length regex
        bodyHTML = bodyHTML.replace(
            '<code', '<code class="prettyprint"')
        bodyHTML = re.sub(
            r'(\<\!--\?prettify(.*)\?--\>\n\n\<pre.*\>)<code class="prettyprint"', r'\1<code', bodyHTML)
    # social sharing buttons
    buttons = buttonHTML(title, ROOT_URL + file_path.split("/")[-2])
    bodyHTML = bodyHTML.replace(
        '%s</h1>' % title.rstrip(), '%s</h1>\n%s' % (title.rstrip(), buttons))

    if args.minify:
        # need to get relative path from HTML file to minified css
        common_prefix = '/'.join(os.path.commonprefix([file_path, combined_css_path])
                                 .split('/')[:-1])
        minified_css = '../' + \
            os.path.relpath(combined_css_path, common_prefix)
    else:
        minified_css = None

    # add permalinks
    def addPermalinks(html):
        def titleToID(title):
            title = re.sub(r'\(.*\)', r'', title)
            title = re.sub(r'(:.*)', r'', title)
            exclude = set(string.punctuation)
            title = ''.join(ch for ch in title if ch not in exclude)
            title = title.lower()
            title = '-'.join(title.split())
            return title

        def permalink(title):
            return u'<a class="headerlink" href="#%s" title="Permalink to this headline">¶</a>' % titleToID(title)

        titles = re.findall(r'(<h\d>)(.*)(</h\d>)', html)
        for match in titles:
            if match[0] == '<h1>':
                continue
            link = permalink(match[1])
            tag = match[0][:-1] + " id='%s'" % titleToID(match[1]) + ">"
            html = html.replace(''.join(match), tag + match[1] + link + match[2])
        return html

    bodyHTML = addPermalinks(bodyHTML)

    # replace in production HTML
    env = Environment(loader=FileSystemLoader('templates'))
    template = env.get_template('post.html')
    productionHTML = template.render(
        body=bodyHTML, title=title, date=fdate, description=description, minified_css=minified_css)

    # only body goes into 'all posts'
    allPosts.append((date, bodyHTML))

    # write that production output to index.html in original directory
    productionFile = open(directory + "/index.html", "w")
    productionFile.write(productionHTML)

    os.system("rm " + file_path)

if os.path.exists("temp.txt"):
    os.system("rm temp.txt")

if os.path.exists("all.html"):
    # sort posts by date and concatenate HTML
    allPosts.sort(reverse=True)
    allHTML = ''.join(map(lambda (x, y): y, allPosts))
    allHTML = templateHTML.replace("{{ body }}", allHTML)

    # fill in template
    env = Environment(loader=FileSystemLoader('templates'))
    template = env.get_template('post.html')
    allHTML = template.render(body=allHTML)

    # create feed file
    feedFile = open("production/all/index.html", "w")
    feedFile.write(allHTML)

print "Production complete."
