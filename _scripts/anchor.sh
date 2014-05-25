for f in *.md
do
    sed -i "" 's/^\#\# \(.*\)$/{% anchor h2 %}\1{% endanchor %}/g' $f
    sed -i "" 's/^\#\#\# \(.*\)$/{% anchor h3 %}\1{% endanchor %}/g' $f
done