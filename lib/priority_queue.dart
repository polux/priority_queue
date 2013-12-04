// Copyright (c) 2013, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Paul Brauner (polux@google.com)

library priority_queue;

import 'dart:collection' show IterableBase;

class PriorityQueue<E> extends IterableBase<E> {
  final Comparator<E> _comparator;
  final List<E> _elements;
  /* nullable */ final Map<E, Set<int>> _positions;

  bool get _fastLookup => _positions != null;

  /**
   * Creates a [PriorityQueue] from [values].
   *
   * Worst case complexity: `O(values.length)`.
   *
   * If [comparator] is specified, it is used for comparing values instead of
   * [E]'s `compareTo` method.
   *
   * If [fastLookup] is true then [remove] and [contains] will be much faster,
   * but [add] and [removeMax] will be slightly slower (see documentation of
   * these methods for details).
   */
  PriorityQueue.from(Iterable<E> values,
                     {int comparator(E value1, E value2),
                      fastLookup: false})
      : _comparator = (comparator == null) ? Comparable.compare : comparator
      , _elements = values.toList()
      , _positions = fastLookup ? new Map<E, Set<int>>() : null {
     if (_fastLookup) {
       for (int i = 0; i < _elements.length; i++) {
         final pos = _positions
             .putIfAbsent(_elements[i], () => new Set<int>())
             .add(i);
       }
     }
    _buildHeap();
  }

  /**
   * Creates an empty [PriorityQueue].
   *
   * Worst case complexity: `O(1)`.
   *
   * If [comparator] is specified, it is used for comparing values instead of
   * [E]'s `compareTo` method.
   *
   * If [fastLookup] is true then [remove] and [contains] will be much faster,
   * but [add] and [removeMax] will be slightly slower (see documentation of
   * these methods for details).
   */
  PriorityQueue({int comparator(E value1, E value2), fastLookup: false})
      : this.from([], comparator: comparator, fastLookup: fastLookup);

  void _swap(int i, int j) {
    final origi = _elements[i];
    final origj = _elements[j];
    _elements[i] = origj;
    _elements[j] = origi;
    if (_fastLookup) {
      final posi = _positions[origj];
      final posj = _positions[origi];
      posi.remove(j);
      posj.remove(i);
      posi.add(i);
      posj.add(j);
    }
  }

  void _buildHeap() {
    for (int i = (_elements.length ~/ 2) - 1; i >= 0; i--) {
      _heapify(i);
    }
  }

  void _heapify(i) {
    final left = 2 * i + 1;
    final right = 2 * i + 2;
    var largest = i;

    if ((left < _elements.length)
        && (_comparator(_elements[left], _elements[largest]) > 0)) {
      largest = left;
    }
    if ((right < _elements.length)
        && (_comparator(_elements[right], _elements[largest]) > 0)) {
      largest = right;
    }
    if (largest != i) {
      _swap(i, largest);
      _heapify(largest);
    }
  }

  /**
   * Adds value to this queue.
   *
   * Worst case complexity: `O(log length)`.
   */
  void add(E value) {
    _elements.add(value);
    final last = _elements.length - 1;
    if (_fastLookup) {
      _positions.putIfAbsent(value, () => new Set<int>()).add(last);
    }
    _bubbleUp(last);
  }

  void _bubbleUp(int i) {
    if (i == 0) {
      return;
    }
    final parent = (i - 1) ~/ 2;
    if (_comparator(_elements[parent], _elements[i]) < 0) {
      _swap(i, parent);
      _bubbleUp(parent);
    }
  }

  void _forceBubbleUp(int i) {
    if (i == 0) {
      return;
    }
    final parent = (i - 1) ~/ 2;
    _swap(i, parent);
    _forceBubbleUp(parent);
  }

  /**
   * Returns the maximum element of this queue without removing it.
   *
   * Worst case complexity: `O(1)`.
   */
  E peek() {
    if (isEmpty) {
      throw new StateError("queue is empty");
    }
    return _elements[0];
  }

  /**
   * Removes the maximum element from this queue and returns it.
   *
   * Worst case complexity: `O(log length)`.
   */
  E removeMax() {
    if (isEmpty) {
      throw new StateError("queue is empty");
    }
    final last = _elements.length - 1;
    final origRoot = _elements[0];
    final origLast = _elements[last];
    _elements[0] = origLast;
    _elements.removeLast();
    if (_fastLookup) {
      if (_elements.isEmpty) {
        _positions.clear();
      } else {
        final pos1 = _positions[origLast];
        final pos2 = _positions[origRoot];
        pos1.remove(last);
        pos2.remove(0);
        pos1.add(0);
        if (pos2.isEmpty) {
          _positions.remove(origRoot);
        }
      }
    }
    _heapify(0);
    return origRoot;
  }

  /**
   * Removes the first occurence of value from this queue.
   *
   * Returns true if value was in the queue, false otherwise. Worst case
   * complexity: worst case complexity of [HashMap]'s lookup + `O(log length)`
   * if the queue was built with `fastLookup: true`, `O(length)` otherwise.
   */
  bool remove(E value) {
    if (_fastLookup) {
      final pos = _positions[value];
      if (pos != null && !pos.isEmpty) {
        _removeAt(pos.first);
        return true;
      }
    } else {
      int i = 0;
      while ((i < _elements.length) && (_elements[i] != value)) {
        i++;
      }
      if (i != _elements.length) {
        _removeAt(i);
        return true;
      }
    }
    return false;
  }

  void _removeAt(i) {
    final elem = _elements[i];
    _forceBubbleUp(i);
    removeMax();
  }

  @override
  Iterator<E> get iterator => _elements.iterator;

  // optimized versions of Iterable's methods

  /**
   * Returns true if this queue contains an value equal to [value].
   *
   * Worst case complexity: worst case complexity of [HashMap]'s lookup if the
   * queue was built with `fastLookup: true`, `O(length)` otherwise.
   */
  @override
  bool contains(E value) {
    return _fastLookup
        ? _positions.containsKey(value)
        : _elements.contains(value);
  }

  @override
  int get length => _elements.length;

  @override
  bool get isEmpty => _elements.isEmpty;

  @override
  bool get isNotEmpty => _elements.isNotEmpty;

  @override
  E get first => _elements.first;

  @override
  E get last => _elements.last;

  @override
  E elementAt(int index) => _elements[index];

  @override
  String toString() => _elements.toString();
}
