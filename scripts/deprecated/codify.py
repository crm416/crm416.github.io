import subprocess
import yaml

LANG_INDEX = "scripts/lang-index.yml"

script = """
for f in */*/index.html
do
    perl -pi -e 's/\<code\>/\<code\ class="prettyprint lang-%s"\>/' $f
done
"""

subscript = """
perl -pi -e 's/\<code\ class="prettyprint lang-%s"\>/\<code\ class="prettyprint lang-%s"\>/' %s
"""


def main():
    f = open(LANG_INDEX)
    langIndex = yaml.load(f)
    f.close()

    # handle default processing
    default = langIndex['default']
    subprocess.call(['sh', '-c', script % default])
    for e in langIndex['other']:
        subprocess.call(['sh', '-c', subscript % (default, e['lang'], e['filename'])])

main()
