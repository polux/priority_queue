// Copyright (c) 2013, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Paul Brauner (polux@google.com)

library model;

import 'package:priority_queue/priority_queue.dart' as impl;
import 'dart:collection' show IterableBase;

class PriorityQueue<E>
    extends IterableBase<E>
    implements impl.PriorityQueue<E> {

  final Comparator<E> _comparator;
  final List<E> _elements;

  PriorityQueue.from(Iterable<E> values,
                     {int comparator(E value1, E value2),
                      fastLookup: false})
      : _comparator = comparator
      , _elements = values.toList()..sort(comparator);

  PriorityQueue({int comparator(E value1, E value2), fastLookup: false})
      : _comparator = (comparator == null) ? Comparable.compare : comparator
      , _elements = [];

  void add(E value) {
    _elements.add(value);
    _elements.sort(_comparator);
  }

  Iterator<E> get iterator => _elements.iterator;

  E peek() {
    if (isEmpty) {
      throw new StateError("queue is empty");
    }
    return _elements.last;
  }

  E removeMax() {
    if (isEmpty) {
      throw new StateError("queue is empty");
    }
    return _elements.removeLast();
  }

  bool remove(E value) {
    return _elements.remove(value);
  }
}