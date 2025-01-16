import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferencesAsync instance = SharedPreferencesAsync();
  static const String key = "locations";

  static Future<void> add(String s) async {
    try {
      List<String> locations = await getList();
      locations.add(s);
      await _save(locations);
    } catch (e) {
      print(e);
    }
  }

  static Future<void> _save(List<String> locations) async {
    await instance.setStringList(key, locations);
  }

  static Future<List<String>> getList() async {
    return (await instance.getStringList(key)) ?? [];
  }
}
