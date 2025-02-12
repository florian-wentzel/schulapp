import 'dart:math';

class UniqueIdGenerator {
  static const int numMax = 100000;
  static final int numMaxLen = numMax.toString().length;

  static int createUniqueId() {
    return DateTime.now().millisecondsSinceEpoch * pow(10, numMaxLen).toInt() +
        Random().nextInt(numMax);
  }
}
