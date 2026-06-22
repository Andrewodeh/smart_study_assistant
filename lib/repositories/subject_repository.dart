import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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
