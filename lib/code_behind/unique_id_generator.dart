import 'dart:math';

class UniqueIdGenerator {
  static int createUniqueId() {
    final now =
        DateTime.now().microsecondsSinceEpoch; // Current time in microseconds
    final random = Random()
        .nextInt(1 << 20); // Random number within a reasonable range (20 bits)

    final id = (now & 0x7FFFFFFF) ^
        random; // XOR to mix time and random, ensuring it's within int32 range

    return id;
  }
}
