echo "Examining CSS redundancy"
for f in production/static/css/*
do
    if [[ $f == 'production/static/css/layout.css' ]]; then
        continue
    fi
    echo $f":"
    csscss $f
done

SCRIPT='<script type="text/javascript" src="../dev/helium.js"></script>
<script type="text/javascript">
window.addEventListener("load", function(){
    helium.init();

    setTimeout(function(){
        if( document.querySelector("#cssdetectTextarea") ){
            document.querySelector("#cssdetectTextarea").innerHTML = "http://localhost:8000/index.html"
        }
    },1000);
}, false);
</script>
</head>'
export SCRIPT

if [[ $1 == '--helium' ]]; then
    echo "Adding helium script and opening index"
    for f in production/index.html
    do
        perl -pi -e 's|</head>|$ENV{SCRIPT}|' $f
        open $f
    done
fi