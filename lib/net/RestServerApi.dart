import 'dart:async';
import 'dart:convert';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:smart_bell/dao/CustomerData.dart';
import 'package:smart_bell/dao/DeviceAttribute.dart';
import 'package:smart_bell/dao/DeviceList.dart';
import 'package:smart_bell/dao/IoTWifiConfigData.dart';
import 'package:smart_bell/dao/LoginResponse.dart';
import 'package:smart_bell/dao/SessionData.dart';
import 'package:smart_bell/dao/UserInfoData.dart';
import 'package:smart_bell/net/APIConstants.dart';
import 'package:smart_bell/net/network_util.dart';
import 'package:smart_bell/screen/LoginPage.dart';
import 'package:smart_bell/util/CommonUtil.dart';
import 'package:smart_bell/utilities/Navigators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:thingsboard_client/thingsboard_client.dart';
import '../util/SessionManager.dart';
import 'package:smart_bell/utilities/Extensions.dart';
import 'package:http/io_client.dart';
import 'package:http/http.dart' as http;
import 'package:smart_bell/dao/DeviceBell.dart';

const kDeviceURL =
    'https://t5aa275v2j.execute-api.eu-central-1.amazonaws.com/default/Smart_bell_lambda';

const kDynamoDbUrl =
    'https://z8otpdwr58.execute-api.eu-central-1.amazonaws.com/default/Storing_data_dynamodb';

class RestServerApi {
  NetworkUtil _netUtil = new NetworkUtil();
  var tenantClient = ThingsboardClient("https://dev-iot.habilelabs.io");
  // var tenantClient = ThingsboardClient("http://97a7-203-153-42-103.ngrok.io");

  static Future<dynamic> loginWithAmplify(
      BuildContext context, String email, String password) async {
    try {
      SignInResult res = await Amplify.Auth.signIn(
        username: email,
        password: password,
      );

      return {'status': res.isSignedIn, 'message': 'Sign in Successfull'};
    } on AuthException catch (e) {
      return {'status': false, 'message': e.message};
    }
  }

  static Future<dynamic> logoutWithAmplify() async {
    try {
      await Amplify.Auth.signOut();
      return {'status': true, 'message': 'Logged out Successfully'};
    } catch (e) {
      return {
        'status': false,
        'message': 'There was a problem, please try again'
      };
    }
  }

  // Register Through Amplify
  static Future<dynamic> registerUserThroughAmplify(
      BuildContext context, fname, lname, email, password) async {
    try {
      Map<CognitoUserAttributeKey, String> userAttributes = {
        CognitoUserAttributeKey.email: email,
        CognitoUserAttributeKey.givenName: fname,
        CognitoUserAttributeKey.familyName: lname,
      };

      SignUpResult res = await Amplify.Auth.signUp(
          username: email,
          password: password,
          options: CognitoSignUpOptions(userAttributes: userAttributes));

      return {
        'status': res.isSignUpComplete,
        'message': 'User Registered Successfully'
      };
    } on AuthException catch (e) {
      return {'status': false, 'message': e.message};
    }
  }

  // Verify Email Through Amplify
  static Future<dynamic> verifyEmail(String email, String code) async {
    try {
      SignUpResult res = await Amplify.Auth.confirmSignUp(
          username: email, confirmationCode: code);
      return {
        'status': res.isSignUpComplete,
        'message': 'Account Verified Successfully'
      };
    } catch (e) {
      return {'status': false, 'message': e.message};
    }
  }

  static Future<dynamic> getBellDeviceList(String username) async {
    var result = await http.post(
      Uri.parse(kDeviceURL),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
          <String, String>{"Action": "get_list", "Device": '${username}'}),
    );
    Map<String, dynamic> decodedResponse = jsonDecode(result.body);
    List<DeviceBell> finalResult = [];
    for (String name in decodedResponse['files']) {
      String username = await CommonUtil.getCurrentLoggedInUsername();
      String extractedName = name.split('${username}_')[1];
      extractedName = extractedName.split('.json')[0];
      finalResult.add(DeviceBell(extractedName));
    }
    return finalResult;
  }

  static Future<dynamic> createDevice(String name) async {
    String deviceName = await CommonUtil.generateDeviceName(name);
    var result = await http.post(
      Uri.parse(kDeviceURL),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "Device_Type": "Smart_Bell",
        "Action": "create",
        "Device": deviceName
      }),
    );
    await CommonUtil.createCertificate(
        jsonDecode(result.body)['files'][0][deviceName]['certificatePem'],
        deviceName);
    print(jsonDecode(result.body)['files'][0][deviceName]['certificatePem']);
    await CommonUtil.createKey(
        jsonDecode(result.body)['files'][0][deviceName]['keyPair']
            ['PrivateKey'],
        deviceName);
    return {'status': true, 'message': 'Device Created Successfully'};
  }

  static Future<dynamic> getCredentials(String name) async {
    String deviceName = await CommonUtil.generateDeviceName(name);
    var result = await http.post(
      Uri.parse(kDeviceURL),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{"Action": "get", "Device": deviceName}),
    );
    await CommonUtil.createCertificate(
        jsonDecode(result.body)['files'][0][deviceName]['certificatePem'],
        name);
    await CommonUtil.createKey(
        jsonDecode(result.body)['files'][0][deviceName]['keyPair']
            ['PrivateKey'],
        name);
    return {'status': true, 'message': 'Certificate Created Successfully'};
  }

  static Future<dynamic> updateProfile(
      String firstname, String lastname) async {
    List<AuthUserAttribute> attributes = [
      AuthUserAttribute(
          userAttributeKey: CognitoUserAttributeKey.givenName,
          value: firstname),
      AuthUserAttribute(
          userAttributeKey: CognitoUserAttributeKey.familyName,
          value: lastname),
    ];

    try {
      await Amplify.Auth.updateUserAttributes(attributes: attributes);
      return {'message': 'Account updated successfully', 'status': true};
    } on AmplifyException catch (e) {
      return {'message': e.message, 'status': false};
    }
  }

  static Future<dynamic> updatePassword(
      String oldPassword, String newPassword) async {
    try {
      await Amplify.Auth.updatePassword(
          oldPassword: oldPassword, newPassword: newPassword);
      return {'message': 'Account updated successfully', 'status': true};
    } on AmplifyException catch (e) {
      return {'message': 'Please enter correct Password', 'status': false};
    }
  }

  static Future<dynamic> getSessions(String name) async {
    String username = await CommonUtil.getCurrentLoggedInUsername();
    String deviceName = '${username}_${name}_App';
    var result = await http.post(
      Uri.parse(kDynamoDbUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "TableName": "Smart_Bell_Device",
        "Data": "",
        "Find": deviceName
      }),
    );
    if (jsonDecode(result.body)['Data'] is! List<dynamic>) {
      Map<String, dynamic> attributes = jsonDecode(result.body)['Data']['Data'];
      DeviceAttributes deviceAttributes = DeviceAttributes();
      deviceAttributes.attributes = attributes;
      if (attributes == null) {
        return deviceAttributes;
      }
      List<SessionData> sessionList = [];
      List<String> weekdays = attributes.keys.toList();

      for (String weekName in weekdays) {
        if (weekName != "isPaused") {
          Map<String, dynamic> weekMap =
              CommonUtil.getJsonVal(attributes, weekName);
          List<String> sessionNames = weekMap.keys.toList();
          for (String sessionName in sessionNames) {
            SessionData sessionData;
            var data = sessionList
                .where((element) => element.shift_name == sessionName);
            if (data != null && data.length > 0) {
              sessionData = data.elementAt(0);
            }
            if (sessionData == null) {
              sessionData = SessionData();
              sessionData.shift_name = sessionName;
              Map<String, dynamic> shiftInfo = weekMap[sessionName];
              sessionData.time = CommonUtil.getJsonVal(shiftInfo, "time")
                  .toString()
                  .convertTimeToDateTime();
              sessionData.bellCount = int.parse(
                  CommonUtil.getJsonVal(shiftInfo, "count").toString());
              if (shiftInfo.containsKey("isSpecialBell")) {
                sessionData.isSpecialBell = int.parse(
                    CommonUtil.getJsonVal(shiftInfo, "isSpecialBell")
                        .toString());
              } else {
                sessionData.isSpecialBell = 0;
              }
              sessionData.weekdays = [];
              sessionList.add(sessionData);
            }
            sessionData.weekdays.add(weekName);
          }
        } else {
          deviceAttributes.isPaused =
              CommonUtil.getJsonVal(attributes, weekName);
        }
      }
      sessionList.sort((a, b) =>
          a.time.getTimeInDateTime().compareTo(b.time.getTimeInDateTime()));
      deviceAttributes.sessionList = sessionList;
      return deviceAttributes;
    } else {
      return [];
    }
  }

  static Future<dynamic> getMiscDetail(String name, String detail) async {
    String username = await CommonUtil.getCurrentLoggedInUsername();
    String deviceName = '${username}_${name}_Device-${detail}';
    print('Device Name inside Misc Details: $deviceName');
    var result = await http.post(
      Uri.parse(kDynamoDbUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "TableName": "Smart_Bell_Device",
        "Data": "",
        "Find": deviceName
      }),
    );
    if (jsonDecode(result.body)['Data'] is! List<dynamic>) {
      return jsonDecode(result.body)['Data'][detail];
    } else {
      return null;
    }
  }

  static Future<dynamic> deleteBellDevice(String name) async {
    String deviceName = await CommonUtil.generateDeviceName(name);
    var result = await http.post(
      Uri.parse(kDeviceURL),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "Device_Type": "Smart_Bell",
        "Action": "delete",
        "Device": deviceName
      }),
    );
    if (result.statusCode == 200) {
      return {'status': true, 'message': 'Device deleted Successfully'};
    } else {
      return {
        'status': false,
        'message': 'Error: Please try again aftger some time'
      };
    }
  }

  ///////////////////////////////////////////////////////////////////////////////////////
  Future<AppLoginResponse> login(
      BuildContext context, String email, password) async {
    var param = {
      LoginAPIConst.PARAM_USERNAME: email,
      LoginAPIConst.PARAM_PASSWORD: password,
    };
    AppLoginResponse loginResponse = AppLoginResponse();
    Map<String, dynamic> res =
        await _netUtil.post(context, LoginAPIConst.URL, body: param);
    loginResponse.status =
        CommonUtil.getJsonVal(res, APIConstants.RESPONSE_STATUS);

    if (loginResponse.status == null) {
      loginResponse.isSuccess = true;
      loginResponse.token = CommonUtil.getJsonVal(res, APIConstants.RES_TOKEN);
      loginResponse.refreshToken =
          CommonUtil.getJsonVal(res, APIConstants.RES_REFRESH_TOKEN);
      SessionManager().setLoginToken(loginResponse.token);
      SessionManager().setRefreshToken(loginResponse.refreshToken);
    } else {
      loginResponse.isSuccess = false;
      loginResponse.message =
          CommonUtil.getJsonVal(res, APIConstants.RESPONSE_MESSAGE);
    }
    return loginResponse;
  }

  Future<dynamic> getUserInfo(BuildContext context) async {
    Map<String, dynamic> res =
        await _netUtil.get(context, UserInfoAPIConst.URL);
    if (res.containsKey(APIConstants.RES_TOKEN) &&
        res[APIConstants.RES_TOKEN] == APIConstants.RESPONSE_TOKEN_VALUE) {
      return res;
    }
    UserInfoData userInfoData = UserInfoData.fromJson(res);
    SessionManager().setLoginUserId(userInfoData.id);
    SessionManager().setLoginUserEmail(userInfoData.email);
    SessionManager().setEntityType(userInfoData.entityType);
    SessionManager().setTenantId(userInfoData.tenantId);
    SessionManager().setCustomerId(userInfoData.customerId);
    SessionManager().setAuthority(userInfoData.authority);
    SessionManager().setFirstName(userInfoData.firstName);
    SessionManager().setLastName(userInfoData.lastName);
    return userInfoData;
  }

  Future<dynamic> getDeviceList(
    BuildContext context,
  ) async {
    String userId = await SessionManager().getCustomerId();
    Map<String, String> par = {
      "pageSize": "10",
      "page": "0",
      "sortProperty": "createdTime",
      "sortOrder": "DESC",
    };
    String url = '/api/customer/${userId}/deviceInfos';
    Map<String, dynamic> res = await _netUtil.get(context, url, request: par);

    if (res != null) {
      if (res.containsKey(APIConstants.RES_TOKEN) &&
          res[APIConstants.RES_TOKEN] == APIConstants.RESPONSE_TOKEN_VALUE) {
        return res;
      }
      DeviceListResponse response = DeviceListResponse.fromJson(res);
      if (response != null) {
        List<DeviceList> deviceLists = response.data;
        return deviceLists;
      }
    }
    return null;
  }

  Future<bool> getTenantAuthToken() async {
    try {
      Map<String, dynamic> res = await _netUtil.get(
          null, APIConstants.URL_TENANT,
          host: APIConstants.BASE_URL_TENANT_API);

      if (res != null) {
        AppLoginResponse loginResponse = AppLoginResponse();
        loginResponse.token =
            CommonUtil.getJsonVal(res, APIConstants.RES_TOKEN);
        loginResponse.refreshToken =
            CommonUtil.getJsonVal(res, APIConstants.RES_REFRESH_TOKEN);
        SessionManager().setTenantToken(loginResponse.token);
        SessionManager().setRefreshTenantToken(loginResponse.refreshToken);
        Map<String, dynamic> response = await _netUtil.get(
            null, "/api/deviceProfileInfo/default",
            token: loginResponse.token);

        if (response != null) {
          DeviceProfileInfo profileInfo = DeviceProfileInfo.fromJson(response);
          SessionManager().setDefaultProfileId(profileInfo.id.id);
        }
      }
      return true;
    } catch (e, s) {
      return false;
    }
  }

  Future<String> getUserToken(context) async {
    String token = await SessionManager().getLoginToken();
    if (context == null) {
      return token;
    }
    if (token != null) {
      bool hasExpired = JwtDecoder.isExpired(token);
      if (hasExpired) {
        String rToken = await SessionManager().getRefreshToken();
        hasExpired = JwtDecoder.isExpired(rToken);
        if (!hasExpired) {
          Map<String, dynamic> res = await _netUtil.post(
              context, "/api/auth/token",
              token: token, body: {"refreshToken": rToken});
          String userToken = res['token'];
          String userRtoken = res['refreshToken'];
          SessionManager().setLoginToken(userToken);
          SessionManager().setRefreshToken(userRtoken);
          return userToken;
        } else {
          _netUtil.handleSessionTimeout(context);
        }
      } else {
        return token;
      }
    } else {
      return null;
    }
  }

  Future<String> getTenantToken(context) async {
    String token = await SessionManager().getTenantToken();
    if (context == null) {
      return token;
    }
    if (token != null) {
      bool hasExpired = JwtDecoder.isExpired(token);
      if (hasExpired) {
        String rToken = await SessionManager().getRefreshTenantToken();
        hasExpired = JwtDecoder.isExpired(rToken);
        if (!hasExpired) {
          Map<String, dynamic> res = await _netUtil.post(
              context, "/api/auth/token",
              token: token, body: {"refreshToken": rToken});
        } else {
          _netUtil.handleSessionTimeout(context);
        }
      } else {
        return token;
      }
    } else {
      return null;
    }
  }

  Future<dynamic> registerUser(
      BuildContext context, fname, lname, email, id) async {
    //create Customer
    //create User
    var param = {
      "title": email,
    };
    String token = await getTenantToken(context);

    Map<String, dynamic> res =
        await _netUtil.post(null, '/api/customer', body: param, token: token);

    if (res != null) {
      if (res.containsKey(APIConstants.RES_TOKEN) &&
          res[APIConstants.RES_TOKEN] == APIConstants.RESPONSE_TOKEN_VALUE) {
        return res;
      }
      CustomerData customerData = CustomerData.fromJson(res);
      if (customerData.id != null) {
        return saveUser(context, fname, lname, email, null, customerData.id,
            customerData.tenantId);
      } else {
        return customerData.message;
      }
    }
    return false;
  }

  Future<dynamic> saveUser(BuildContext context, fname, lname, email, id,
      customerId, tenantId) async {
    String token = await getTenantToken(context);
    var userParam = {
      "authority": "CUSTOMER_USER",
      "customerId": {"entityType": "CUSTOMER", "id": customerId},
      "email": email,
      "firstName": fname,
      "lastName": lname,
      "name": '$fname $lname',
      "tenantId": {"entityType": "TENANT", "id": tenantId}
    };
    if (id != null) {
      userParam["id"] = {"entityType": "USER", "id": id};
    }
    Map<String, dynamic> userRes = await _netUtil.post(null, '/api/user',
        body: userParam, query: 'sendActivationMail=true', token: token);

    if (userRes != null) {
      if (userRes.containsKey(APIConstants.RES_TOKEN) &&
          userRes[APIConstants.RES_TOKEN] ==
              APIConstants.RESPONSE_TOKEN_VALUE) {
        return userRes;
      }
      UserInfoData userInfoData = UserInfoData.fromJson(userRes);
      if (userInfoData != null && userInfoData.id != null) {
        return true;
      }
    }

    return false;
  }

  Future<List<String>> getWifiList(
    BuildContext context,
  ) async {
    Map<String, dynamic> res = await _netUtil.get(context, "/",
        port: 80, host: NetworkUtil.BASE_LOCAL_URL, scheme: NetworkUtil.HTTP);

    if (res != null) {
      List<String> keys = res.keys.toList();
      return keys;
    }
    return null;
  }

  Future<dynamic> postToken(BuildContext context, Username) async {
    var param = {"Username": Username};
    Map<String, dynamic> res = await _netUtil.post(context, '/token',
        body: param,
        host: NetworkUtil.BASE_LOCAL_URL,
        port: 80,
        scheme: NetworkUtil.HTTP);

    return res;
  }

  Future<IotWifiConfigData> configureDevice(
      BuildContext context, String ssid, password, Username) async {
    await postToken(context, Username);
    var param = {
      "ssid": ssid,
      "password": password,
    };
    IotWifiConfigData data;
    Map<String, dynamic> res = await _netUtil.post(context, '/configure',
        body: param,
        host: NetworkUtil.BASE_LOCAL_URL,
        port: 80,
        scheme: NetworkUtil.HTTP);

    if (res != null) {
      data = IotWifiConfigData.fromJson(res);
    }
    return data;
  }

  Future<dynamic> addDeviceToServer(BuildContext context, String title,
      {String id}) async {
    String customerId = await SessionManager().getCustomerId();
    String tenantToken = await getTenantToken(context);
    String defaultProfileId = await SessionManager().getDefaultProfileId();
    if (defaultProfileId == null) {
      defaultProfileId = "0a3f28f0-2832-11ec-bda4-cb31dd48c097";
    }
    Map<String, dynamic> param = {
      "name": title,
      "label": "",
      "deviceProfileId": {
        "entityType": "DEVICE_PROFILE",
        "id": defaultProfileId
      },
      "additionalInfo": {
        "gateway": false,
        "overwriteActivityTime": false,
        "description": ""
      },
      "customerId": {"entityType": "CUSTOMER", "id": customerId}
    };
    if (title != null) {
      param["name"] = title;
    }
    if (id != null) {
      param["id"] = {"entityType": "DEVICE", "id": id};
    }
    Map<String, dynamic> res = await _netUtil.post(context, '/api/device',
        body: param, token: tenantToken);

    if (res != null) {
      if (res.containsKey("token") && res["token"] == "Expired") {
        return res;
      }
      Map<String, dynamic> deviceJson = CommonUtil.getJsonVal(res, 'id');
      if (deviceJson != null) {
        String deviceId = CommonUtil.getJsonVal(deviceJson, 'id');
        if (deviceId != null) {
          dynamic deviceToken = await getDeviceToken(context, deviceId);
          if (deviceToken == null) {
            return {"deviceId": deviceId};
          } else if (deviceToken is String) {
            return {"deviceToken": deviceToken, "deviceId": deviceId};
          } else {
            return deviceToken;
          }
        }
      } else {
        return CommonUtil.getJsonVal(res, 'message');
      }
    }
    return null;
  }

  Future<dynamic> getDeviceToken(BuildContext context, String deviceId) async {
    String url = '$deviceId/credentials';
    Map<String, dynamic> res = await _netUtil.get(
      context,
      '/api/device/$url',
    );

    if (res != null) {
      if (res.containsKey("token") && res["token"] == "Expired") {
        return res;
      }
      return CommonUtil.getJsonVal(res, 'credentialsId');
    }

    return null;
  }

  Future<dynamic> addAttributesToClientScopeDevice(BuildContext context,
      String deviceId, Map<String, dynamic> attributes) async {
    Map<String, dynamic> res = await _netUtil.post(
        context, '/api/plugins/telemetry/DEVICE/$deviceId/CLIENT_SCOPE',
        body: attributes);

    if (res.containsKey("token") && res["token"] == "Expired") {
      return res;
    }
    return "Attributes Added";
  }

  Future<dynamic> addAttributesToServerScopeDevice(BuildContext context,
      String deviceId, Map<String, dynamic> attributes) async {
    Map<String, dynamic> res = await _netUtil.post(
        context, '/api/plugins/telemetry/DEVICE/$deviceId/SERVER_SCOPE',
        body: attributes);

    if (res.containsKey("token") && res["token"] == "Expired") {
      return res;
    }
    return "Attributes Added";
  }

  Future<dynamic> addAttributesToDevice(BuildContext context,
      String deviceToken, Map<String, dynamic> attributes) async {
    Map<String, dynamic> res = await _netUtil.post(
        context, '/api/plugins/telemetry/DEVICE/$deviceToken/SHARED_SCOPE',
        body: attributes);

    if (res.containsKey("token") && res["token"] == "Expired") {
      return res;
    }
    return "Attributes Added";
  }

  Future<dynamic> changePassword(
      BuildContext context, String currentPassword, String newPassword) async {
    Map<String, dynamic> param = {
      "currentPassword": currentPassword,
      "newPassword": newPassword
    };
    Map<String, dynamic> res =
        await _netUtil.post(context, '/api/auth/changePassword', body: param);

    if (res != null) {
      LoginResponse loginResponse = LoginResponse.fromJson(res);
      if (loginResponse.token != null) {
        SessionManager().setLoginToken(loginResponse.token);
        SessionManager().setRefreshTenantToken(loginResponse.refreshToken);
        return true;
      } else {
        String message = CommonUtil.getJsonVal(res, 'message');
        if (message != null) {
          return message;
        }
        String status = CommonUtil.getJsonVal(res, 'status');
        return status != null && status == 'OK';
      }
    }
    return false;
  }

  Future<dynamic> resetPassword(BuildContext context, String email) async {
    Map<String, dynamic> param = {
      "email": email,
    };

    Map<String, dynamic> res = await _netUtil
        .post(context, '/api/noauth/resetPasswordByEmail', body: param);

    if (res != null) {
      String message = CommonUtil.getJsonVal(res, 'message');
      if (message != null) {
        return message;
      }
      String status = CommonUtil.getJsonVal(res, 'status');
      return status != null && status == 'OK';
    }
    return false;
  }

  Future<dynamic> logout(BuildContext context) async {
    Map<String, dynamic> res = await _netUtil.post(
      context,
      '/api/auth/logout',
    );

    if (res != null) {
      String message = CommonUtil.getJsonVal(res, 'message');
      if (message != null) {
        return message;
      }
      String status = CommonUtil.getJsonVal(res, 'status');
      return status != null && status == 'OK';
    }
    return false;
  }

  Future<dynamic> getLastSyncTime(BuildContext context, String deviceId) async {
    try {
      dynamic res = await _netUtil.get(context, '/smartbell/app/$deviceId',
          host: APIConstants.BASE_URL_TENANT_API);

      if (res != null) {
        if (res is Map &&
            res.containsKey("token") &&
            res["token"] == "Expired") {
          return res;
        }
        return res;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<dynamic> getServerAttributesToDevice(
      BuildContext context, String deviceToken) async {
    dynamic res = await _netUtil.get(context,
        '/api/plugins/telemetry/DEVICE/$deviceToken/values/attributes/SERVER_SCOPE');

    return res;
  }

  Future<dynamic> getAttributesToDevice(
      BuildContext context, String deviceToken) async {
    Map<String, dynamic> res =
        await _netUtil.get(context, '/api/v1/$deviceToken/attributes');

    if (res != null) {
      if (res.containsKey("token") && res["token"] == "Expired") {
        return res;
      }

      Map<String, dynamic> attributes = CommonUtil.getJsonVal(res, "shared");
      Map<String, dynamic> clientAttri = CommonUtil.getJsonVal(res, "client");
      DeviceAttributes deviceAttributes = DeviceAttributes();
      deviceAttributes.attributes = attributes;
      deviceAttributes.clientAttri = clientAttri;
      if (attributes == null) {
        return deviceAttributes;
      }
      List<SessionData> sessionList = [];
      List<String> weekdays = attributes.keys.toList();

      for (String weekName in weekdays) {
        if (weekName != "isPaused") {
          Map<String, dynamic> weekMap =
              CommonUtil.getJsonVal(attributes, weekName);
          List<String> sessionNames = weekMap.keys.toList();
          for (String sessionName in sessionNames) {
            SessionData sessionData;
            var data = sessionList
                .where((element) => element.shift_name == sessionName);
            if (data != null && data.length > 0) {
              sessionData = data.elementAt(0);
            }
            if (sessionData == null) {
              sessionData = SessionData();
              sessionData.shift_name = sessionName;
              Map<String, dynamic> shiftInfo = weekMap[sessionName];
              sessionData.time = CommonUtil.getJsonVal(shiftInfo, "time")
                  .toString()
                  .convertTimeToDateTime();
              sessionData.bellCount = int.parse(
                  CommonUtil.getJsonVal(shiftInfo, "count").toString());
              if (shiftInfo.containsKey("isSpecialBell")) {
                sessionData.isSpecialBell = int.parse(
                    CommonUtil.getJsonVal(shiftInfo, "isSpecialBell")
                        .toString());
              } else {
                sessionData.isSpecialBell = 0;
              }
              sessionData.weekdays = [];
              sessionList.add(sessionData);
            }
            sessionData.weekdays.add(weekName);
          }
        } else {
          deviceAttributes.isPaused =
              CommonUtil.getJsonVal(attributes, weekName);
        }
      }
      sessionList.sort((a, b) =>
          a.time.getTimeInDateTime().compareTo(b.time.getTimeInDateTime()));
      deviceAttributes.sessionList = sessionList;

      return deviceAttributes;
    } else {
      return null;
    }
  }

  Future<dynamic> deleteDevice(BuildContext context, String deviceId) async {
    try {
      String tenantToken = await getTenantToken(context);
      Map<String, dynamic> res = await _netUtil
          .delete(context, '/api/device/$deviceId', token: tenantToken);

      if (res != null) {
        if (res.containsKey("token") && res["token"] == "Expired") {
          return res;
        }
        String status = CommonUtil.getJsonVal(res, 'status');
        return status != null && status == 'OK';
      }
    } catch (e) {
      print(e);
      return true;
    }
  }
}
