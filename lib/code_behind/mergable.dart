// class MergeConflict {
//   final String msg;

//   MergeConflict({required this.msg});
// }

enum MergeErrorSolution {
  keepLocal,
  keepRemote,
  keepBoth,
}

abstract class MergableClass<T> {
  DateTime get lastModified;
  String get uid; //UUID
  T get parent;

  //returns new merged object
  //vielleicht null wenn beide gespeichert werden sollen
  Future<List<T>> merge(
    T other,
    Future<MergeErrorSolution> Function(String errorMsg) onMergeError,
  );
}
// import 'package:uuid/data.dart';
// import 'package:uuid/rng.dart';
// import 'package:uuid/uuid.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:schulapp/extensions.dart';

// class MergeManager {
//   // static void mergeItems<T extends Mergable<T>>(
//   //     Mergable<T> first, Mergable<T> second) {
//   //   List<MergeItem> firstItems = first.getMergeItems();
//   //   List<MergeItem> secondItems = second.getMergeItems();

//   //   Map<String, MergeItem> firstMap = {
//   //     for (var item in firstItems) item.name: item
//   //   };
//   //   Map<String, MergeItem> secondMap = {
//   //     for (var item in secondItems) item.name: item
//   //   };

//   //   assert(
//   //     firstMap.keys.toSet().containsAll(secondMap.keys) &&
//   //         secondMap.keys.toSet().containsAll(firstMap.keys),
//   //     'The two maps do not have the same keys',
//   //   );

//   //   final allKeys =
//   //       firstMap.keys.toSet().union(secondMap.keys.toSet()).toList();

//   //   print(allKeys);

//   //   for (final name in allKeys) {
//   //     if (!firstMap.containsKey(name) || !secondMap.containsKey(name)) {
//   //       continue;
//   //     }

//   //     if (secondMap.containsKey(name)) {
//   //       if (firstMap[name]!
//   //           .lastModified
//   //           .isBefore(secondMap[name]!.lastModified)) {
//   //         //first hat aelteres item, also wird es ueberschrieben
//   //         // print('Merging ${name}: ${firstMap[name]!.value} -> ${secondMap[name]!.value}');
//   //         //Hier muss jetzt der eigentliche Wert gesetzt werden
//   //         //Das Problem ist, dass ich nicht weiss, welchen Typ der Wert hat
//   //         //Ich koennte es mit reflection machen, aber das ist in Dart nicht so einfach
//   //         //Alternativ koennte ich eine Funktion uebergeben, die den Wert setzt
//   //         //Das wuerde aber bedeuten, dass ich fuer jede Klasse eine eigene Merge-Funktion schreiben muss
//   //         //Das ist auch nicht optimal
//   //         //Idee: Ich koennte eine Map<String, Function> uebergeben, die den Namen des Feldes und eine Funktion zum Setzen des Wertes enthaelt
//   //         //Dann koennte ich die Funktion aufrufen, um den Wert zu setzen
//   //         //Das wuerde aber bedeuten, dass ich fuer jede Klasse eine eigene Map schreiben muss
//   //         //Das ist auch nicht optimal
//   //         //Vielleicht gibt es ja eine bessere Loesung

//   //         //Lösung mit Extension:
//   //         // first.setValueByName(name, secondMap[name]!.value);
//   //       }
//   //     } else {
//   //       //Item existiert nur in first, also nichts zu tun
//   //     }
//   //   }

//   //   // final Map<String, Mergable<T>> firstMap = {
//   //   //   for (var item in first.getMergeItems()) item.uuid: item
//   //   // };
//   //   // final Map<String, Mergable<T>> secondMap = {
//   //   //   for (var item in second.getMergeItems()) item.uuid: item
//   //   // };

//   //   // // Merge items present in both lists
//   //   // for (final uuid in firstMap.keys) {
//   //   //   if (secondMap.containsKey(uuid)) {
//   //   //     firstMap[uuid]!.merge(secondMap[uuid]!);
//   //   //   }
//   //   // }

//   //   // // Add new items from remote to local
//   //   // for (final uuid in secondMap.keys) {
//   //   //   if (!firstMap.containsKey(uuid)) {
//   //   //     localItems.add(secondMap[uuid]!);
//   //   //   }
//   //   // }

//   //   // // Optionally, handle deletions or other
//   //   // // logic as needed
//   // }
// }

// // abstract class Mergable<T> {
// //   String get uid; //UUID
// //   DateTime get lastModified;
// //   //runtime anschaunen

// //   List<MergeItem> getMergeItems();
// // }

// abstract class IMergableVar<T> {
//   DateTime lastModified;
//   T value;

//   IMergableVar({
//     required this.lastModified,
//     required this.value,
//   });
// }

// class MergableVar<T> implements IMergableVar<T> {
//   @override
//   DateTime lastModified;

//   @override
//   T value;

//   MergableVar({
//     required this.lastModified,
//     required this.value,
//   });
// }

// class Tt implements MergableClass<Tt> {
//   @override
//   String get uid => Uuid().v4(config: V4Options(null, CryptoRNG()));

//   @override
//   Tt get parent => this;

//   @override
//   void merge(MergableClass<Tt> other) {
//     // other.parent.
//   }

//   Tt({required String name}) : name = MergableVar(value: name);

//   MergableVar<String> name;
// }

// class Task implements MergableClass<Task> {
//   @override
//   DateTime get lastModified => DateTime.fromMillisecondsSinceEpoch(100);

//   @override
//   String get uid => Uuid().v4(config: V4Options(null, CryptoRNG()));

//   Mergable<String> name = Mergable();

//   @override
//   List<MergeItem> getMergeItems() {
//     //Hier werden alle membervariablen die gemerged werden sollen zurueckgegeben
//     // Type nameType = name.runtimeType;

//     return [
//       MergeItem<String>(
//         lastModified: lastModified,
//         name: 'name',
//         value: name,
//       ),
//     ];
//   }
// }

// class MergeItem<T> {
//   DateTime lastModified;
//   String name;
//   T value;

//   MergeItem(
//       {required this.lastModified, required this.name, required this.value});
// }
