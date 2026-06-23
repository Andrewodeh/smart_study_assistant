import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/subject.dart';

abstract class SubjectRepository {
  Future<List<Subject>> loadAll();
  Future<void> saveAll(List<Subject> subjects);
}

class SharedPrefsSubjectRepository implements SubjectRepository {
  static const String _key = 'subjects';

  @override
  Future<List<Subject>> loadAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);
    if (data == null) return [];
    final List<dynamic> list = jsonDecode(data) as List<dynamic>;
    return list
        .map((e) => Subject.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveAll(List<Subject> subjects) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(subjects.map((s) => s.toJson()).toList()),
    );
  }
}

/// A Hive-backed implementation for storing `Subject` models.
class HiveSubjectRepository implements SubjectRepository {
  static const String _boxName = 'subjects_box';

  Future<Box<Subject>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<Subject>(_boxName);
    }
    return Hive.box<Subject>(_boxName);
  }

  @override
  Future<List<Subject>> loadAll() async {
    final box = await _getBox();
    return box.values.toList();
  }

  @override
  Future<void> saveAll(List<Subject> subjects) async {
    final box = await _getBox();
    // Replace existing contents with new list keyed by id
    await box.clear();
    for (final s in subjects) {
      await box.put(s.id, s);
    }
  }

  /// Migrate any SharedPreferences-stored subjects into Hive.
  ///
  /// Merges by id so nothing is lost even if Hive already holds some subjects
  /// (e.g. from a previous partial migration). Only adds subjects whose id is
  /// not already present, then clears the legacy SharedPreferences key.
  static Future<void> migrateFromSharedPrefsIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(SharedPrefsSubjectRepository._key);
    if (data == null) return;

    try {
      final List<dynamic> list = jsonDecode(data) as List<dynamic>;
      final subjects = list
          .map((e) => Subject.fromJson(e as Map<String, dynamic>))
          .toList();

      final box = Hive.isBoxOpen(_boxName)
          ? Hive.box<Subject>(_boxName)
          : await Hive.openBox<Subject>(_boxName);

      for (final s in subjects) {
        if (!box.containsKey(s.id)) {
          await box.put(s.id, s);
        }
      }

      // Remove the old SharedPreferences key after a successful merge.
      await prefs.remove(SharedPrefsSubjectRepository._key);
    } catch (e) {
      // Leave SharedPreferences intact so a later launch can retry.
      // ignore: avoid_print
      print('Subject migration failed: $e');
    }
  }
}
