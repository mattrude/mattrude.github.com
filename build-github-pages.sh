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
	if [ `git remote show origin |grep "gh-pages tracked" |wc -l` ]; then
	    git checkout --track -b gh-pages origin/gh-pages -q
	else
	    git checkout gh-pages
	fi
    rm -f index.html readme.md
    git show master:readme.md > readme.md && \
    PAGENAME=`head -2 readme.md |grep "^# " |sed 's/^# //g'`
    sed "s/###TITLE###/$PAGENAME/g" ../../header.txt |sed "s/###SOURCE###/$project/g" > index.html && \
    sed -i "/# $PAGENAME/c <div id=\"title\"><h1>mattrude.github.com <i>&mdash; </i>$PAGENAME</h1></div><div id=\"breadcrums\"><p><a href=\"/\">mattrude.github.com</a> / <strong>$PAGENAME</strong></p></div>" readme.md && \
    markdown readme.md >> index.html && \
    cat ../../comments.txt >> index.html
    sed "s/###SOURCE###/$project/g" ../../footer.txt >> index.html
    rm -f style.css && cp ../../style.css .
    rm -f readme.md
    git add .
    git commit . -m "Webstie Update" && git push --all
    cd ../
    echo ""
done
cd ../
rm -rf projects

echo "------ mattrude.github.com ------"
rm -rf index.html
INDEXNAME=`grep "^# " index.md |sed 's/^# //g'`
sed "s/###TITLE###/$INDEXNAME/g" header.txt > index.html && \
markdown index.md >> index.html && \
sed "s/###SOURCE###/mattrude.github.com/g" footer.txt >> index.html
git commit index.html -m "Webstie Update" && git push --all
