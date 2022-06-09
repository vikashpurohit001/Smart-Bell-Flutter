import 'package:smart_bell/util/CommonUtil.dart';

class CustomerData {
  String id, message, tenantId;
  int status;

  CustomerData.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> custJson = CommonUtil.getJsonVal(json, 'id');
    if (custJson != null) {
      id = CommonUtil.getJsonVal(custJson, 'id');
    }
    status = CommonUtil.getJsonVal(json, 'status');
    message = CommonUtil.getJsonVal(json, 'message');
    Map<String, dynamic> tenantJson = CommonUtil.getJsonVal(json, 'tenantId');
    if (tenantJson != null) {
      tenantId = CommonUtil.getJsonVal(tenantJson, 'id');
    }
  }
}
