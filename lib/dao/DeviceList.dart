// {"data":
// [
// {"id":{"entityType":"DEVICE","id":"fbe21ec0-bd47-11eb-aebe-9dc5f051fda7"},"createdTime":1621940243116,
// "additionalInfo":{"description":"Demo device that is used in Raspberry Pi GPIO control sample application"},
// "tenantId":{"entityType":"TENANT","id":"fab25150-bd47-11eb-aebe-9dc5f051fda7"},
// "customerId":{"entityType":"CUSTOMER","id":"8bd1c6e0-beae-11eb-92ce-09f01ecb2553"},
// "name":"Raspberry Pi Demo Device","type":"default","label":null,
// "deviceProfileId":{"entityType":"DEVICE_PROFILE","id":"fabbee40-bd47-11eb-aebe-9dc5f051fda7"},
// "deviceData":{"configuration":{"type":"DEFAULT"},
// "transportConfiguration":{"type":"DEFAULT"}},
// "customerTitle":"Aditi","customerIsPublic":false,"deviceProfileName":"default"}
// ]
// ,"totalPages":1,"totalElements":1,"hasNext":false}
// I/flutter ( 4543): {data: [{id: {entityType: DEVICE, id: fbe21ec0-bd47-11eb-aebe-9dc5f051fda7}, createdTime: 1621940243116, additionalInfo: {description: Demo device that is used in Raspberry Pi GPIO control sample application}, tenantId: {entityType: TENANT, id: fab25150-bd47-11eb-aebe-9dc5f051fda7}, customerId: {entityType: CUSTOMER, id: 8bd1c6e0-beae-11eb-92ce-09f01ecb2553}, name: Raspberry Pi Demo Device, type: default, label: null, deviceProfileId: {entityType: DEVICE_PROFILE, id: fabbee40-bd47-11eb-aebe-9dc5f051fda7}, deviceData: {configuration: {type: DEFAULT}, transportConfiguration: {type: DEFAULT}}, customerTitle: Aditi, customerIsPublic: false, deviceProfileName: default}], totalPages: 1, totalElements: 1, hasNext: false}

import 'package:smart_bell/util/CommonUtil.dart';

class DeviceListResponse {
  List<DeviceList> data;
  int totalPages;
  int totalElements;
  bool hasNext;

  DeviceListResponse.fromJson(Map<String, dynamic> json) {
    List<dynamic> listData = CommonUtil.getJsonVal(json, 'data');
    data = [];
    for (var value in listData) {
      data.add(DeviceList.fromJson(value));
    }
    totalPages = CommonUtil.getJsonVal(json, 'totalPages');
    totalElements = CommonUtil.getJsonVal(json, 'totalElements');
    hasNext = CommonUtil.getJsonVal(json, 'hasNext');
  }
}

class DeviceList {
  String deviceId;
  String deviceToken;
  int createdTime;
  String label;
  String name;
  String deviceProfileId;
  bool customerIsPublic;
  bool isSelected = false;
  bool isActive = false;
  bool isPaused = false;
  DeviceList(deviceId) {
    this.deviceId = deviceId;
  }
  DeviceList.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> idData = CommonUtil.getJsonVal(json, 'id');
    deviceId = CommonUtil.getJsonVal(idData, 'id');
    createdTime = CommonUtil.getJsonVal(json, 'createdTime');
    name = CommonUtil.getJsonVal(json, 'name');
    label = CommonUtil.getJsonVal(json, 'label');
    customerIsPublic = !CommonUtil.getJsonVal(json, 'customerIsPublic');
    Map<String, dynamic> deviceProfileIdData =
        CommonUtil.getJsonVal(json, 'deviceProfileId');
    deviceProfileId = CommonUtil.getJsonVal(deviceProfileIdData, 'id');
  }
}
