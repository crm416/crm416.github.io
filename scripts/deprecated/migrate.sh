# Copy files to App Engine folder
cp -rf production/static/* app_engine/

# Push live
appcfg.py update app_engine

# Replace references in all files
for f in production/*.html production/*/*.html
do
    perl -pi -e 's/(\.\.\/)?static/http:\/\/crmarsh416.appspot.com/' $f
done
