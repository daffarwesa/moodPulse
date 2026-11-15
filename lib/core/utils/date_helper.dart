import 'package:intl/intl.dart';

abstract final class DateHelper {
  static String key(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
  static DateTime fromKey(String key) => DateTime.parse(key);
  static String full(String key) =>
      DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(fromKey(key));
  static String short(String key) =>
      DateFormat('d MMM yyyy', 'id_ID').format(fromKey(key));
  static String dateLong(String key) =>
      DateFormat('d MMMM yyyy', 'id_ID').format(fromKey(key));
  static String dayShort(String key) =>
      DateFormat('EEEE, d MMM yyyy', 'id_ID').format(fromKey(key));
  static String dateTime(int milliseconds) => DateFormat(
    'd MMM yyyy, HH.mm',
    'id_ID',
  ).format(DateTime.fromMillisecondsSinceEpoch(milliseconds));
}
