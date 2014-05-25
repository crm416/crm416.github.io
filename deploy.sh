if [ $# -eq 0 ]
  then
    echo "Please supply a commit message"
    exit 0
fi

echo "Pushing to server"
scp -r _site/* crmarsh@nobel.princeton.edu:public_html/

echo "Pushing to GitHub"
git add -A
git commit -m "$1"
git push
