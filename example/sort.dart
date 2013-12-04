// Copyright (c) 2013, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Paul Brauner (polux@google.com)

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