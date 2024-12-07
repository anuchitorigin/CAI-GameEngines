import 'package:shared_preferences/shared_preferences.dart';

class FilterMemoryService {
  setFilterMemory(String filterName, String value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(filterName, value);
  }

  Future<String> getFilterMemory(String filterName) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(filterName) ?? '';
  }
}