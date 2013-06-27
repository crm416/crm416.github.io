import subprocess

script = """
for f in */*/index.html
do
    echo $f
    perl -pi -e 's/\<code\>/\<code\ class="prettyprint lang-%s"\>/' $f
done
"""

subscript = """
perl -pi -e 's/\<code\ class="prettyprint lang-%s"\>/\<code\ class="prettyprint lang-%s"\>/' %s
"""


def main():
    f = "scripts/lang-index"
    text = open(f, "r").read()
    info = text.split('\n')
    # handle default processing
    default = info[0].split(', ')[1]
    subprocess.call(['sh', '-c', script % default])
    for e in info[1:]:
        t, l = e.split(', ')[0], e.split(', ')[1]
        subprocess.call(['sh', '-c', subscript % (default, l, t)])

main()
