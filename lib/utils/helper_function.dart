import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

String getFormattedDate(num dt, String f){
  return DateFormat(f).format(DateTime.fromMillisecondsSinceEpoch(dt.toInt() * 1000));
}

Future<bool> setTempStatus(bool status) async{
  final prefs = await SharedPreferences.getInstance();
  return prefs.setBool('temp', status);
}


Future<bool> getTempStatus() async{
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('temp') ?? false;
}