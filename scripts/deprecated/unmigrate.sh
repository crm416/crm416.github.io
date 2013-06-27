# Replace references in all files
for f in production/*.html
do
    perl -pi -e 's/http\:\/\/crmarsh416\.appspot\.com/static/' $f
done

for f in production/*/*.html
do
    perl -pi -e 's/http\:\/\/crmarsh416\.appspot\.com/..\/static/' $f
done