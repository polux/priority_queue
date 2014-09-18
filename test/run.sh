#!/bin/bash

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

dartanalyzer $ROOT_DIR/lib/*.dart \
&& dartanalyzer $ROOT_DIR/test/*.dart \
&& dartanalyzer $ROOT_DIR/example/*.dart \
&& dart --enable-checked-mode $ROOT_DIR/example/huffman.dart \
&& dart --enable-checked-mode $ROOT_DIR/example/sort.dart \
&& dart --checked $ROOT_DIR/test/priority_queue_test.dart --quiet
