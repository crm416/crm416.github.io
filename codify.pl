for f in */*/index.html
do
    echo $f
    perl -pi -e 's/\<code\>/\<code\ class="prettyprint lang-ml"\>/' $f
done