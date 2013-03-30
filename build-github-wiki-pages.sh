#!/bin/bash

DIR="/root/mattrude.github.com"

cd $DIR

mkdir -p projects
cd projects

for project in `cat ../project-list`
do
    cd $project
    echo "------ $project ------"
    git checkout gh-pages -q
    if [ -d wiki ]; then
        echo "------ $project ------"
        git up
        git clone git@github.com:mattrude/$project.wiki.git git-wiki -q
        if [ -d git-wiki ]; then
            rm -rf wiki
            mkdir -p $DIR/projects/$project/wiki
            echo "<?php ?>" > $DIR/projects/$project/wiki/index.html
            cd git-wiki
            for WIKIMD in `ls *.md`
            do
                echo "Working on page $WIKIMD"
                WIKI=`echo $WIKIMD |sed 's/\.md//g'`
                LDIR="$DIR/projects/$project/wiki/$WIKI"
                rm -rf $LDIR
                mkdir -p $LDIR/
                cat $DIR/header.txt > $LDIR/index.html
                PAGENAME=`echo $WIKI |sed 's/-/ /g'`
                sed "s/###TITLE###/$PAGENAME/g" $DIR/header.txt |sed "s/###SOURCE###/$project/g" > $LDIR/index.html && \
                echo "<div id=\"title\"><h1>$PAGENAME <i> &mdash; </i> gh.mattrude.com/$project</h1></div>" >> $LDIR/index.html && \
                echo "<div id=\"breadcrums\"><p><a href=\"/\">gh.mattrude.com</a> / <a href=\"/$project\">$project</a> / wiki / <strong>$PAGENAME</strong></p></div>" >> $LDIR/index.html && \
                markdown $WIKIMD >> $LDIR/index.html
                cat $DIR/footer.txt >> $LDIR/index.html
                sed -i "s/src=\"images/src=\"https:\/\/github.com\/mattrude\/$project\/wiki\/images/g" $LDIR/index.html
            done
            cd $DIR/projects/$project
            rm -rf git-wiki
            mv index.html index.html-work && cat index.html-work |sed "s/https:\/\/github.com\/mattrude\/$project\/wiki\//http:\/\/gh.mattrude.com\/$project\/wiki\//g" > index.html && rm -f index.html-work

            git add .
            git commit . -m "Adding/updating the Wiki pages to $project"
            git push
        fi
    fi
    cd $DIR/projects
done
