# Remove lingering minified css
rm -f production/static/css/*-min.css

for f in post.html production/index.html production/about.html production/*/index.html
do
    echo "Uncompressing CSS for "$f
    perl -pi -e 's/\-min\.css/\.css/' $f
done