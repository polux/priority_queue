// Copyright (c) 2013, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Paul Brauner (polux@google.com)

library traces;

import 'package:priority_queue/priority_queue.dart' as impl;
import 'package:enumerators/enumerators.dart' as en;
import 'package:enumerators/combinators.dart' as co;
import 'model.dart' as model;

abstract class PriorityQueueFactory {
  impl.PriorityQueue empty(bool fastLookup);
  impl.PriorityQueue from(List<int> values, bool fastLookup);
}

class _ImplFactory implements PriorityQueueFactory {
  empty(bool fastLookup) => new impl.PriorityQueue(fastLookup: fastLookup);
  from(List<int> values, bool fastLookup) =>
      new impl.PriorityQueue.from(values, fastLookup: fastLookup);
}

class _ModelFactory implements PriorityQueueFactory {
  empty(bool fastLookup) => new model.PriorityQueue(fastLookup: fastLookup);
  from(List<int> values, bool fastLookup) =>
      new model.PriorityQueue.from(values, fastLookup: fastLookup);
}

final IMPL_FACTORY = new _ImplFactory();
final MODEL_FACTORY = new _ModelFactory();

abstract class ConstructorCall {
  impl.PriorityQueue execute(PriorityQueueFactory factory);
}

class Empty extends ConstructorCall {
  final bool fastLookup;
  Empty(this.fastLookup);
  String toString() {
    return 'Empty($fastLookup)';
  }
  impl.PriorityQueue execute(PriorityQueueFactory factory) {
    return factory.empty(fastLookup);
  }
}

class From extends ConstructorCall {
  final List<int> values;
  final bool fastLookup;
  From(this.values, this.fastLookup);
  String toString() {
    return 'From($values, $fastLookup)';
  }
  impl.PriorityQueue execute(PriorityQueueFactory factory) {
    return factory.from(values, fastLookup);
  }
}

abstract class Instruction {
  Result execute(impl.PriorityQueue queue);
}

Result _execute(f()) {
  try {
    return new Value(f());
  } catch (error) {
    return new Issue(error);
  }
}

class Insert extends Instruction {
  final int i;
  Insert(this.i);
  String toString() {
    return 'Insert($i)';
  }
  Result execute(impl.PriorityQueue queue) {
    return _execute(() => queue.add(i));
  }
}

class Delete extends Instruction {
  final int i;
  Delete(this.i);
  String toString() {
    return 'Delete($i)';
  }
  Result execute(impl.PriorityQueue queue) {
    return _execute(() => queue.remove(i));
  }
}

class Peek extends Instruction {
  Peek();
  String toString() {
    return 'Peek()';
  }
  Result execute(impl.PriorityQueue queue) {
    return _execute(() => queue.peek());
  }
}

class Pop extends Instruction {
  Pop();
  String toString() {
    return 'Pop()';
  }
  Result execute(impl.PriorityQueue queue) {
    return _execute(() => queue.removeMax());
  }
}

class Program {
  final ConstructorCall constructorCall;
  final List<Instruction> instructions;
  Program(this.constructorCall, this.instructions);
  String toString() {
    return 'Program($constructorCall, $instructions)';
  }
  List<Result> execute(PriorityQueueFactory factory) {
    final queue = constructorCall.execute(factory);
    final result = [];
    for (final instruction in instructions) {
      result.add(instruction.execute(queue));
    }
    return result;
  }
}

abstract class Result {
  bool same(Result result);
}

class Value extends Result {
  final Object value;
  Value(this.value);
  String toString() {
    return 'Value($value)';
  }

  bool same(Result result) {
    return result is Value && value == result.value;
  }
}

class Issue extends Result {
  final Error error;
  Issue(this.error);
  String toString() {
    return 'Issue($error)';
  }

  bool same(Result result) {
    return result is Issue && error.toString() == result.error.toString();
  }
}

_empty(bool fastLookup) => new Empty(fastLookup);
_from(List<int> values, bool fastLookup) => new From(values, fastLookup);

final constructorCalls =
    en.apply(_empty, co.bools)
  + en.apply(_from, co.listsOf(co.ints), co.bools);

_insert(int i) => new Insert(i);
_delete(int i) => new Delete(i);
_peek() => new Peek();
_pop() => new Pop();

final instructions = en.apply(_insert, co.ints)
                   + en.apply(_delete, co.ints)
                   + en.singleton(_peek())
                   + en.singleton(_pop());

_program(ConstructorCall constructorCall) =>
    (List<Instruction> instructions) =>
        new Program(constructorCall, instructions);

final programs = en.singleton(_program)
    .apply(constructorCalls)
    .apply(co.listsOf(instructions));

bool sameTraces(List<Result> trace1, List<Result> trace2) {
  if (trace1.length != trace2.length) return false;
  for (int i = 0; i < trace1.length; i++) {
    if (!trace1[i].same(trace2[i])) return false;
  }
  return true;
}