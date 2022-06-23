import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:smart_bell/net/RestServerApi.dart';
import 'package:smart_bell/screen/LoginPage.dart';
import 'package:smart_bell/util/CommonUtil.dart';
import 'package:smart_bell/util/SessionManager.dart';
import 'package:smart_bell/utilities/Navigators.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

///
///
///
class FileData {
  final File file;
  final String fieldName;
  final String contentType;

  FileData(this.file, this.fieldName, this.contentType);
}

Map<String, String> tokenExpired = {"token": "Expired"};

class NetworkUtil {
  static NetworkUtil _instance = new NetworkUtil.internal();
  static String BASE_URL = "dev-iot.habilelabs.io";
  // static String BASE_URL = "97a7-203-153-42-103.ngrok.io";
  static String BASE_LOCAL_URL = "192.168.4.1";
  static String HTTPS = "https";
  static String HTTP = "http";

  NetworkUtil.internal();

  factory NetworkUtil() => _instance;

  Future<dynamic> get(BuildContext context, String methodName,
      {Map<String, String> request,
      int port = 0,
      host = "",
      token,
      String scheme,
      bool callOnce = false}) async {
    bool trustSelfSigned = true;
    HttpClient httpClient = new HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => trustSelfSigned);

    IOClient ioClient = new IOClient(httpClient);
    if (scheme == null) {
      scheme = HTTPS;
    }
    Uri uri = new Uri(
        scheme: scheme,
        host: host == "" ? BASE_URL : host,
        port: port == 0 ? null : port,
        path: methodName,
        queryParameters: request);
    print(uri);
    Map<String, String> headers = {};
    bool isTenant = true;
    String headerToken = null;
    if (token != null) {
      isTenant = true;
      headerToken = 'Bearer ' + token;
    } else if (await new RestServerApi().getUserToken(context) != null) {
      isTenant = false;
      headerToken = await _getBasicAuthorizationString(context);
    }
    print(headerToken);
    headers['Content-Type'] = 'application/json';
    headers['Accept'] = 'application/json';

    headers["X-Authorization"] = headerToken;
    headers[HttpHeaders.cacheControlHeader] = 'max-age=3600, must-revalidate';
    return ioClient
        .get(uri, headers: headers)
        .then((http.Response response) async {
      final String res = response.body;
      print(res);
      final int statusCode = response.statusCode;
      print(statusCode);
      bool isLogin = await RestServerApi().getUserToken(context) != null;
      if (statusCode == 401 && isLogin) {
        if (isTenant && !callOnce) {
          await getTenantTokenAgain();
          return get(context, methodName,
              request: request,
              port: port,
              host: host,
              token: token,
              scheme: scheme,
              callOnce: true);
        } else {
          handleSessionTimeout(context);
          return tokenExpired;
        }
      } else if (statusCode == 403 && !callOnce) {
        await getTenantTokenAgain();
        return get(context, methodName,
            request: request,
            port: port,
            host: host,
            token: token,
            scheme: scheme,
            callOnce: true);
      }
      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }

      return json.decode(res);
    });
  }

  Future<Map<String, dynamic>> post(BuildContext context, String methodName,
      {Map<String, dynamic> body,
      String token,
      host = "",
      int port = 0,
      query,
      queryParam,
      String scheme,
      bool callOnce = false}) async {
    bool trustSelfSigned = true;
    HttpClient httpClient = new HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => trustSelfSigned);
    IOClient ioClient = new IOClient(httpClient);
    String headerToken;
    bool isTenant = true;
    if (token != null) {
      isTenant = true;
      headerToken = 'Bearer ' + token;
    } else if (await RestServerApi().getUserToken(context) != null) {
      isTenant = false;
      headerToken = await _getBasicAuthorizationString(context);
    }
    if (scheme == null) {
      scheme = HTTPS;
    }
    Uri uri = new Uri(
        scheme: scheme,
        host: host == "" ? BASE_URL : host,
        port: port == 0 ? null : port,
        query: query,
        queryParameters: queryParam,
        path: methodName);
    return ioClient.post(uri, body: json.encode(body), headers: {
      "Content-Type": "application/json",
      'X-Authorization': headerToken,
      HttpHeaders.cacheControlHeader: 'max-age=3600, must-revalidate'
    }).then((http.Response response) async {
      final String res = response.body;
      final int statusCode = response.statusCode;
      if (statusCode == 200 && res.isEmpty) {
        return {"status": "OK"};
      }
      if (statusCode != 200) {
        bool isLogin = await RestServerApi().getUserToken(context) != null;
        if (statusCode == 401 && isLogin) {
          if (isTenant && !callOnce) {
            await getTenantTokenAgain();
            return post(context, methodName,
                body: body,
                token: token,
                host: host,
                port: port,
                query: query,
                queryParam: queryParam,
                scheme: scheme,
                callOnce: true);
          } else {
            handleSessionTimeout(context);
            return tokenExpired;
          }
        } else if (statusCode == 403 && host == "192.168.4.1") {
          return null;
        } else if ((statusCode == 403 || statusCode == 401) && !callOnce) {
          await getTenantTokenAgain();
          return post(context, methodName,
              body: body,
              token: token,
              host: host,
              port: port,
              query: query,
              queryParam: queryParam,
              scheme: scheme,
              callOnce: true);
        }
      }
      return json.decode(res);
    });
  }

  Future<Map<String, dynamic>> delete(BuildContext context, String methodName,
      {Map<String, dynamic> body,
      String token,
      host = "",
      int port = 0,
      query,
      queryParam,
      bool callOnce = false}) async {
    bool trustSelfSigned = true;
    HttpClient httpClient = new HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => trustSelfSigned);
    IOClient ioClient = new IOClient(httpClient);
    String headerToken;
    bool isTenant = true;
    if (token != null) {
      isTenant = true;
      headerToken = 'Bearer ' + token;
    } else if (await RestServerApi().getUserToken(context) != null) {
      isTenant = false;
      headerToken = await _getBasicAuthorizationString(context);
    }
    Uri uri = new Uri(
        scheme: HTTPS,
        host: host == "" ? BASE_URL : host,
        port: port == 0 ? null : port,
        query: query,
        queryParameters: queryParam,
        path: methodName);
    return ioClient.delete(uri, body: json.encode(body), headers: {
      "Content-Type": "application/json",
      'X-Authorization': headerToken,
      HttpHeaders.cacheControlHeader: 'max-age=3600, must-revalidate'
    }).then((http.Response response) async {
      final String res = response.body;
      final int statusCode = response.statusCode;
      if (statusCode == 200 && res.isEmpty) {
        return {"status": "OK"};
      }
      bool isLogin = await SessionManager().getLoginUserId() != null;
      if (statusCode == 401 && isLogin) {
        if (isTenant && !callOnce) {
          await getTenantTokenAgain();
          return delete(context, methodName,
              body: body,
              token: token,
              host: host,
              port: port,
              query: query,
              queryParam: queryParam,
              callOnce: true);
        } else {
          handleSessionTimeout(context);
          return tokenExpired;
        }
      } else if (statusCode == 403 && !callOnce) {
        await getTenantTokenAgain();
        return delete(context, methodName,
            body: body,
            token: token,
            host: host,
            port: port,
            query: query,
            queryParam: queryParam,
            callOnce: true);
      }
      return json.decode(res);
    });
  }

  Future<String> _getBasicAuthorizationString(context) async {
    String loginToken = await RestServerApi().getUserToken(context);
    if (loginToken != null) {
      String basicAuth = 'Bearer ' + loginToken;
      return basicAuth;
    }
    return null;
  }

  void handleSessionTimeout(BuildContext context) {
    SessionManager().logOutUser();
    manageLogout(context);
  }

  Future<dynamic> getTenantTokenAgain() async {
    return await RestServerApi().getTenantAuthToken();
  }

  manageLogout(BuildContext context) {
    CommonUtil.showSnackBar(context, "Session Expired. Please re-login.");
    Navigators.pushAndRemoveUntil(context, LoginPage());
  }
}
