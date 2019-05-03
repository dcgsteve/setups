#!/bin/sh

dd if=/dev/zero of=./tmp.$$$ bs=1G count=1 oflag=dsync
