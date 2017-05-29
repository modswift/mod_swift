#!/bin/sh

cd swift-apache
SRCDIR=${PWD}
SCRIPTS=`ls swift-apache*`

cd /usr/local/bin
for i in $SCRIPTS; do
  ln -sf $SRCDIR/$i $i
done
