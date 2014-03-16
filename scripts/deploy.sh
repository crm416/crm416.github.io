prepare ()
{
    source env/bin/activate
    sass production/static/css/styles.scss production/static/css/styles.css
    python syndicate.py --minify --prettify
}

migrate ()
{
    # Copy files to App Engine folder
    cp -rf production/static/* app_engine/

    # Push live
    appcfg.py --oauth2 update app_engine

    # Replace references in all files
    for f in production/*.html production/*/*.html
    do
        perl -pi -e 's/(\.\.\/)?static/http:\/\/crmarsh416.appspot.com/' $f
    done
}

unmigrate ()
{
    # Replace references in all files
    for f in production/*.html
    do
        perl -pi -e 's/http\:\/\/crmarsh416\.appspot\.com/static/' $f
    done

    for f in production/*/*.html
    do
        perl -pi -e 's/http\:\/\/crmarsh416\.appspot\.com/..\/static/' $f
    done
}

if [ $# -eq 0 ]
  then
    echo "Please supply a commit message"
    exit 0
fi

echo "Creating posts"
prepare

#echo "Migrating static content to CDN"
migrate

echo "Pushing to server"
scp -r production/* crmarsh@nobel.princeton.edu:public_html/

echo "Pushing to GitHub"
git add -A
git commit -m "$1"
git push

#echo "Reverting to local static content"
unmigrate
