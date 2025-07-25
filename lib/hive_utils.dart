import 'package:hive/hive.dart';

/// Open a typed Hive box safely.
/// If the box is already open, just return the existing instance.
Future<Box<T>> openTypedBox<T>(String name) async {
  if (Hive.isBoxOpen(name)) {
    return Hive.box<T>(name);
  }
  return Hive.openBox<T>(name);
}
