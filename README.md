Priority queue for Dart
=======================

Binary-heap based priority queue for Dart. Elements are inserted using `add`,
and the maximum element is removed using `removeMax`, observed with `peek`.

An originality of this implementation is that it provides an `O(log n)` `remove`
method using a hash map to keep track of the elements' positions within the 
heap. Since maintaining this map is not free, it is only optionally activated 
by passing `fastLookup: true` to the constructor. See the dartdoc for details.

Example:

```dart
import 'package:priority_queue/priority_queue.dart';

sort(values) {
  final queue = new PriorityQueue.from(values);
  final result = [];
  while (!queue.isEmpty) {
    result.add(queue.removeMax());
  }
  return result;
}

main() {
  print(sort([3,1,4,1,5,9,2,6,5,3,5,9]));
}
```
