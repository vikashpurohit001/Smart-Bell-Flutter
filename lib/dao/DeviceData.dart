import 'package:smart_bell/dao/SessionData.dart';

class DeviceData {
  String device_name;
  bool isTurnOn;
  bool isSelected = false;
  List<SessionData> _sessionData;
}
