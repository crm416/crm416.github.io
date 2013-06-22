# Remove lingering minified css
rm -f production/static/css/*-min.css

# Compress CSS
echo "Minifying CSS"
java -jar dev/yuicompressor-2.4.8.jar -o '.css$:-min.css' production/static/css/*.css
for f in post.html production/index.html production/about.html
do
    echo "Compressing CSS for "$f
    perl -pi -e 's/\.css/\-min\.css/' $f
done
python syndicate.py post.html

echo "Adding lang tags"
python codify.py
