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
	else
	    git clone git@github.com:mattrude/$project.git -q
	    cd $project
	fi
    GHPAGESLOCAL=`git branch |grep "gh-pages" |wc -l`
    if [ $GHPAGESLOCAL == "1" ]; then
        CURRENTBRANCH=`git status |grep "# On branch " |awk '{print $4}'`
        if [ $CURRENTBRANCH != "gh-pages" ]; then
            git checkout gh-pages
        fi
    else
        if [ "$GHPAGES" == "1" ]; then
            git checkout --track -b gh-pages origin/gh-pages -q
            git checkout -b gh-pages
        else
            GHPAGES=`git remote show origin |grep "gh-pages tracked" |wc -l`
            if [ "$GHPAGES" == "0" ]; then
                echo "Branch gh-pages dose not exist, creating it"
                git symbolic-ref HEAD refs/heads/gh-pages
                rm .git/index
                git clean -fdx
                sleep 2
                git push --all
            else
                echo "Can't find gh-pages"
                exit 1
            fi
        fi
    fi
    rm -f index.html readme.md
    LISTREADME1=`git ls-tree master: |grep readme.md |wc -l`
    if [ "$LISTREADME1" == "1" ]; then
        README="readme.md"
    else
        LISTREADME2=`git ls-tree master: |grep README.md |wc -l`
        if [ "$LISTREADME2" == "1" ]; then
            README="README.md"
        fi
    fi
    git show master:$README > readme.md && \
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
        git commit . -m "Website Update" && git push --all
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
REPOSTATUS=`git status -s |wc -l`
if [ $REPOSTATUS != "0" ]; then
    git commit index.html -m "Website Update"
    git push --all
fi
