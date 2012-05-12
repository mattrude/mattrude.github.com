#!/bin/bash

PAGENAME="WordPress Webmaster Tools Plugin"

mkdir -p projects
cd projects

for project in `cat ../project-list`
do
    echo "------ $project ------"
    rm -rf $project
    git clone git@github.com:mattrude/$project.git -q
    cd $project
    git checkout --track -b gh-pages origin/gh-pages -q

    rm -f index.html readme.md
    git show master:readme.md > readme.md && \
    PAGENAME=`grep "^# " readme.md |sed 's/^# //g'`
    sed "/###TITLE###/c $PAGENAME" ../../header.txt > index.html && \
    sed -i "/# $PAGENAME/c <div id=\"title\"><h1>mattrude.github.com <i>&mdash; </i>$PAGENAME</h1></div><p><a href=\"/\">mattrude.github.com</a> / <strong>$PAGENAME</strong></p>" readme.md && \
    markdown readme.md >> index.html && \
    cat ../../footer.txt >> index.html
    rm -f favicon.ico && cp ../../favicon.ico .
    rm -f style.css && cp ../../style.css .
    rm -f readme.md
    git add .
    git commit . -m "Webstie Update" && git push --all
    cd ../
    echo ""
done
cd ../
rm -rf projects

rm -rf index.html
INDEXNAME=`grep "^# " index.md |sed 's/^# //g'`
sed "/###TITLE###/c $PAGENAME" header.txt > index.html && \
markdown index.md >> index.html && \
cat footer.txt >> index.html
git commit index.html -m "Webstie Update" && git push --all
