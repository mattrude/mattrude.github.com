#!/bin/bash

PAGENAME="WordPress Webmaster Tools Plugin"

cd /root/mattrude.github.com

mkdir -p projects
cd projects

for project in `cat ../project-list`
do
    echo "------ $project ------"
	if [ -d $project/.git ]; then
		cd $project
		git up
        CURRENTBRANCH=`git status |grep "# On branch " |awk '{print $4}'`
        if [ $CURRENTBRANCH != "gh-pages" ]; then
		    git checkout gh-pages
        fi
	else
	    git clone git@github.com:mattrude/$project.git -q
	    cd $project
		if [ `git remote show origin |grep "gh-pages tracked" |wc -l` ]; then
		    git checkout --track -b gh-pages origin/gh-pages -q
		else
            CURRENTBRANCH=`git status |grep "# On branch " |awk '{print $4}'`
            if [ $CURRENTBRANCH != "gh-pages" ]; then
		        git checkout gh-pages
            fi
		fi
	fi
    rm -f index.html readme.md
    git show master:readme.md > readme.md && \
    PAGENAME=`head -2 readme.md |grep "^# " |sed 's/^# //g'`
    sed "s/###TITLE###/$PAGENAME/g" ../../header.txt |sed "s/###SOURCE###/$project/g" > index.html && \
    sed -i "/# $PAGENAME/c <div id=\"title\"><h1>$PAGENAME <i> &mdash; </i> gh.mattrude.com</h1></div><div id=\"breadcrums\"><p><a href=\"/\">gh.mattrude.com</a> / <strong>$PAGENAME</strong></p></div>" readme.md && \
    markdown readme.md >> index.html && \
    cat ../../comments.txt >> index.html
    sed "s/###SOURCE###/$project/g" ../../footer.txt >> index.html
    rm -f style.css && cp ../../style.css .
	rm -f favicon.ico
    rm -f readme.md
    REPOSTATUS=`git status -s |wc -l`
    if [ $REPOSTATUS != "0" ]; then
        git add .
        git commit . -m "Webstie Update" && git push --all
    fi
    cd ../
    echo ""
done
cd ../

echo "------ mattrude.github.com ------"
rm -rf index.html
INDEXNAME=`grep "^# " index.md |sed 's/^# //g'`
sed "/###TITLE###/c 	<title>$INDEXNAME</title>" header.txt > index.html && \
markdown index.md >> index.html && \
sed "s/###SOURCE###/mattrude.github.com/g" footer.txt >> index.html
git commit index.html -m "Webstie Update" && git push --all
