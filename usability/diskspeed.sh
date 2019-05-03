#!/bin/sh

echo Creating 10 x 1G test files ...
dd if=/dev/zero of=./tmp.tmp bs=1G count=10 oflag=dsync
rm tmp.tmp
