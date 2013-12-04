#!/bin/bash

ROOTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OUTDIR=$ROOTDIR/continuous
TMPDIR=`mktemp -d`

cd $TMPDIR
git clone https://github.com/polux/priority_queue
cd priority_queue
pub get
rm -rf $OUTDIR
dartdoc -v --link-api --pkg=packages/ --out $OUTDIR lib/priority_queue.dart
rm -rf $TMPDIR
