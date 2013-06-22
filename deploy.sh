echo "Creating posts"
./prepare.sh

echo "Pushing to server"
scp -r production/* crmarsh@nobel.princeton.edu:public_html/

for f in post.html production/index.html production/about.html production/*/index.html
do
    echo "Uncompressing CSS for "$f
    perl -pi -e 's/\-min\.css/\.css/' $f
done

echo "Deleting minified CSS"
rm -f production/static/css/*-min.css
