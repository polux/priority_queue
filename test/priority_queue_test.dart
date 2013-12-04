// Copyright (c) 2013, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Paul Brauner (polux@google.com)

library priority_queue_test;

import 'package:args/args.dart' as args;
import 'package:propcheck/propcheck.dart';
import 'package:unittest/unittest.dart';
import 'src/traces.dart';

final Property implemMatchesModelProp = forall(programs, (program) {
  return sameTraces(
      program.execute(IMPL_FACTORY),
      program.execute(MODEL_FACTORY));
});

main(List<String> arguments) {
  final parser = new args.ArgParser();
  parser.addFlag('help', negatable: false);
  parser.addFlag('quiet', negatable: false);
  final flags = parser.parse(arguments);

  if (flags['help']) {
    print(parser.getUsage());
    return;
  }

  test('quickcheck implem matches model', () {
    final qc = new QuickCheck(maxSize: 500, seed: 42, quiet: flags['quiet']);
    qc.check(implemMatchesModelProp);
  });
  test('smallcheck implem matches model', () {
    final sc = new SmallCheck(depth: 7, quiet: flags['quiet']);
    sc.check(implemMatchesModelProp);
  });
}