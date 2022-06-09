import 'dart:convert';

class SessionData {
  String shift_name;
  int bellCount;
  bool isSelected = false;
  DateTime time;
  DateTime tempDate;
  List<String> weekdays;
  bool isNoti = false;
  int isSpecialBell = 0;
  bool isSynced = true;

  @override
  String toString() {
    // TODO: implement toString
    return jsonEncode({"shift_name": "$shift_name", "bellCount": "$bellCount"});
  }
}
