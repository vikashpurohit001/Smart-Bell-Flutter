import 'package:smart_bell/util/CommonUtil.dart';

class UserInfoData {
  String id;
  String entityType;
  int createdTime;
  String tenantId;
  String customerId;
  String email, authority, firstName, lastName, name;

  UserInfoData.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> mapId = CommonUtil.getJsonVal(json, 'id');
    if (mapId != null) {
      id = CommonUtil.getJsonVal(mapId, 'id');
      entityType = CommonUtil.getJsonVal(mapId, 'entityType');
    }
    createdTime = CommonUtil.getJsonVal(json, 'createdTime');
    Map<String, dynamic> tenantJson = CommonUtil.getJsonVal(json, 'tenantId');
    if (tenantJson != null) {
      tenantId = CommonUtil.getJsonVal(tenantJson, 'id');
    }
    Map<String, dynamic> customerJson =
        CommonUtil.getJsonVal(json, 'customerId');
    if (customerJson != null) {
      customerId = CommonUtil.getJsonVal(customerJson, 'id');
    }
    email = CommonUtil.getJsonVal(json, 'email');
    authority = CommonUtil.getJsonVal(json, 'authority');
    firstName = CommonUtil.getJsonVal(json, 'firstName');
    lastName = CommonUtil.getJsonVal(json, 'lastName');
    name = CommonUtil.getJsonVal(json, 'name');
  }
}
