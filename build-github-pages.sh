#!/bin/bash

PAGENAME="WordPress Webmaster Tools Plugin"
GITHUBUSER="mattrude"
DIR="/root/$GITHUBUSER.github.com"

cd $DIR

git pull

mkdir -p projects
cd projects

for project in `cat ../project-list`
do
    echo "------ $project ------"
	if [ -d $project/.git ]; then
		cd $project
		git up
	else
        echo "$project not found, cloning it now."
	    git clone git@github.com:$GITHUBUSER/$project.git -q
	    cd $project
	fi
    GHPAGESLOCAL=`git branch |grep "gh-pages" |wc -l`
    if [ $GHPAGESLOCAL == "1" ]; then
        CURRENTBRANCH=`git status |grep "# On branch " |awk '{print $4}'`
        if [ $CURRENTBRANCH != "gh-pages" ]; then
            git checkout gh-pages
        fi
    else
        GHPAGES=`git remote show origin |grep "gh-pages tracked" |wc -l`
        if [ "$GHPAGES" == "1" ]; then
	    echo "Checking out gh-pages"
            git checkout --track -b gh-pages origin/gh-pages -q
#            git checkout -b gh-pages
        else
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
    sed -i "/# $PAGENAME/c <div id=\"title\"><h1>$PAGENAME <i> &mdash; </i> gh.$GITHUBUSER.com</h1></div><div id=\"breadcrums\"><p><a href=\"/\">gh.$GITHUBUSER.com</a> / <strong>$PAGENAME</strong></p></div>" readme.md && \
    markdown readme.md >> index.html && \
    cat ../../comments.txt >> index.html
    sed "s/###SOURCE###/$project/g" ../../footer.txt >> index.html
    rm -f style.css 
    #cp ../../style.css .
	rm -f favicon.ico
    rm -f readme.md

    HASWIKI="false"

    HASWIKI=`curl -s https://api.github.com/repos/$GITHUBUSER/$project |grep "has_wiki" |awk '{print $2}' |sed 's/,//g'`
    
    if [ $HASWIKI != "true" ]; then
        HASWIKI="false"
    fi
    
    if [ $HASWIKI = "true" ]; then
        echo "This project has a wiki; creating static wiki pages."
        cd $DIR/projects/$project/
        if [ -d git-wiki ]; then
            cd git-wiki
            git pull -q
        else
            echo "  - No wiki directory found, creating new directory"
            git clone git@github.com:$GITHUBUSER/$project.wiki.git git-wiki -q
        fi
        if [ -d git-wiki ]; then
            rm -rf wiki
            mkdir -p $DIR/projects/$project/wiki
            echo "<?php ?>" > $DIR/projects/$project/wiki/index.html
            cd git-wiki
            for WIKIMD in `ls *.md`
            do
                echo "  - Building static page $WIKIMD"
                WIKI=`echo $WIKIMD |sed 's/\.md//g'`
                LDIR="$DIR/projects/$project/wiki/$WIKI"
                rm -rf $LDIR
                mkdir -p $LDIR/
                cat $DIR/header.txt > $LDIR/index.html
                PAGENAME=`echo $WIKI |sed 's/-/ /g'`
                sed "s/###TITLE###/$PAGENAME/g" $DIR/header.txt |sed "s/###SOURCE###/$project/g" > $LDIR/index.html && \
                echo "<div id=\"title\"><h1>$PAGENAME <i> &mdash; </i> gh.$GITHUBUSER.com/$project</h1></div>" >> $LDIR/index.html && \
                echo "<div id=\"breadcrums\"><p><a href=\"/\">gh.$GITHUBUSER.com</a> / <a href=\"/$project\">$project</a> / wiki / <strong>$PAGENAME</strong></p></div>" >> $LDIR/index.html && \
                markdown $WIKIMD >> $LDIR/index.html
                cat $DIR/footer.txt >> $LDIR/index.html
                sed -i "s/src=\"images/src=\"https:\/\/github.com\/$GITHUBUSER\/$project\/wiki\/images/g" $LDIR/index.html
            done
            cd $DIR/projects/$project
            rm -rf git-wiki
            mv index.html index.html-work && cat index.html-work |sed "s/https:\/\/github.com\/$GITHUBUSER\/$project\/wiki\//http:\/\/gh.$GITHUBUSER.com\/$project\/wiki\//g" > index.html && rm -f index.html-work
        fi
    else
        rm -rf $DIR/projects/$project/git-wiki $DIR/projects/$project/wiki
    fi

    cd $DIR/projects/$project
    REPOSTATUS=`git status -s |wc -l`
    if [ $REPOSTATUS != "0" ]; then
        echo "Committing changes to repository:"
        git checkout gh-pages -q
        git add .
        git commit . -m "Website Update" && git push --all
        #twidge update "Updating github website for the $project repository, see: http://gh.$GITHUBUSER.com/$project"
    else
        echo "No changes found, no update needed"
    fi
    
    cd ../
    echo ""
done
cd $DIR

echo "------ $GITHUBUSER.github.com ------"
rm -rf index.html
INDEXNAME=`grep "^# " index.md |sed 's/^# //g'`
sed "/###TITLE###/c 	<title>$INDEXNAME</title>" header.txt > index.html && \
markdown index.md >> index.html && \
sed "s/###SOURCE###/$GITHUBUSER.github.com/g" footer.txt >> index.html

MAINREPOSTATUS=`git status -s |wc -l`
if [ $MAINREPOSTATUS != "0" ]; then
    echo "Committing changes to main repository:"
    git commit . -m "Website Update" -q
    git push --all -q
fi
