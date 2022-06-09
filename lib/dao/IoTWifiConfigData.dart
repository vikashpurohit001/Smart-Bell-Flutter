import 'package:smart_bell/util/CommonUtil.dart';

class IotWifiConfigData {
  String ip_address, message, ssid;
  bool isSuccess = false;

  IotWifiConfigData.fromJson(Map<String, dynamic> json) {
    ip_address = CommonUtil.getJsonVal(json, 'ip_address');
    if (ip_address != null) {
      message = CommonUtil.getJsonVal(json, 'message');
      ssid = CommonUtil.getJsonVal(json, 'ssid');
      isSuccess = true;
    } else {
      isSuccess = false;
    }
  }
}
