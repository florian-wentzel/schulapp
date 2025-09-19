import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schulapp/code_behind/mergable.dart';
import 'package:schulapp/code_behind/utils.dart';

void main() {
  test(
    "Test if uid works",
    () {
      //Der letzte ist immer die konstante
      List<List<double>> koefizienten = [
        [1, 2, 3, 2],
        [1, 1, 1, 2],
        [3, 3, 1, 0]
      ];

      // Task t1 = Task();
      // t1.name = 'Task 1';

      // print(t1.uid);

      // Task t2 = Task();
      // t2.name = 'Task 2';

      // print(t2.uid);

      // Tt tt1 = Tt();
      // print(tt1.uid);

      // MergeManager.mergeItems<Task>(t1, t2);
    },
  );
}
