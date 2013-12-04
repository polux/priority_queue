// Copyright (c) 2013, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Paul Brauner (polux@google.com)

import 'package:priority_queue/priority_queue.dart';
import 'package:persistent/persistent.dart';

abstract class Tree {
  int get frequency;

  PersistentMap<String, String> get code => _code("");
  PersistentMap<String, String> _code(String prefix);
}

class Leaf extends Tree {
  final String character;
  final int frequency;

  Leaf(this.character, this.frequency);

  _code(String prefix) {
    return new PersistentMap().insert(character, prefix);
  }
}

class Fork extends Tree {
  final int frequency;
  final Tree left;
  final Tree right;

  Fork(Tree left, Tree right)
      : this.left = left
      , this.right = right
      , frequency = left.frequency + right.frequency;

  _code(String prefix) {
    return left._code(prefix + "0").union(right._code(prefix +"1"));
  }
}

int compareFreqs(Tree tree1, Tree tree2) {
  return tree2.frequency.compareTo(tree1.frequency);
}

Tree makeTree(List characters) {
  final frequencies = <String, int>{};
  for (final character in characters) {
    final frequency = frequencies[character];
    frequencies[character] = (frequency == null) ? 1 : frequency + 1;
  }
  final leaves = new List();
  frequencies.forEach((character, frequency) {
    leaves.add(new Leaf(character, frequency));
  });
  final queue = new PriorityQueue<Tree>.from(leaves, comparator: compareFreqs);
  while (queue.length > 1) {
    Tree tree1 = queue.removeMax();
    Tree tree2 = queue.removeMax();
    queue.add(new Fork(tree1, tree2));
  }
  return queue.single;
}

main() {
  final characters = "Text to be encoded".split('');
  print(makeTree(characters).code);
}