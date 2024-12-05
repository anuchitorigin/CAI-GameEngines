import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

import 'package:cai_gameengine/constansts/default_error.const.dart';

import 'package:cai_gameengine/models/api_result.model.dart';
import 'package:cai_gameengine/models/signup_success.model.dart';
import 'package:cai_gameengine/models/resetpass_success.model.dart';
import 'package:cai_gameengine/models/login.model.dart';

import 'package:cai_gameengine/services/domain.service.dart';
import 'package:cai_gameengine/services/device_info.service.dart';

class AuthenAPI {
  static final apiEndpoint = DomainService.authEndpoint;

  final DeviceInfoService device = DeviceInfoService();

  Future<String> ping() async {
    http.Response res = await http.get(Uri.parse('$apiEndpoint/'), headers: { 'responseType': 'text' });

    return res.body;
  }

  Future<APIResult> localSignup(String loginid, String firstname, String? lastname, String roleid) async {
    var info = {
      "loginid": loginid,
      "firstname": firstname,
      "lastname": lastname,
      "roleid": roleid
    };

    // ignore: prefer_typing_uninitialized_variables
    var res;
    try{
      res = await http.post(Uri.parse('$apiEndpoint/local/signup'), body: info);
    } catch(err) {
      log('err: $err');
    }

    APIResult temp;
    try {
      temp = APIResult.apiresultFromJson(res.body);
    } catch(err) {
      temp = defaultError;
    }
    temp.result = signupDataFromJson(temp.result);

    return temp;
  }

  Future<APIResult> localLogin(String loginid, String password) async {
    var info = {
      "loginid": loginid,
      "passcode": getHash(password),
      "callerip": await getIpAddress(),
      "callername": await device.getDeviceName()
    };

    // ignore: prefer_typing_uninitialized_variables
    var res;
    try{
      res = await http.post(Uri.parse('$apiEndpoint/local/login'), body: info);
    } catch(err) {
      log('err: $err');
    }

    APIResult temp;
    try {
      temp = APIResult.apiresultFromJson(res.body);
    } catch(err) {
      temp = defaultError;
    }
    temp.result = loginTokenDataFromJson(temp.result);

    return temp;
  }

  Future<APIResult> resetPassword(String token, String? userid) async {
    var info = { "id_token": token };
    if(userid != null) {
      info["userid"] = userid;
    }

    // ignore: prefer_typing_uninitialized_variables
    var res;
    try{
      res = await http.post(Uri.parse('$apiEndpoint/local/resetpass'), body: info);
    } catch(err) {
      log('err: $err');
    }

    APIResult temp;
    try {
      temp = APIResult.apiresultFromJson(res.body);
    } catch(err) {
      temp = defaultError;
    }
    temp.result = resetpassDataFromJson(temp.result);

    return temp;
  }

  Future<APIResult> changePassword(String token, String oldPassword, String newPassword) async {
    var info = {
      "id_token": token,
      "oldpass": getHash(oldPassword),
      "newpass": getHash(newPassword)
    };

    // ignore: prefer_typing_uninitialized_variables
    var res;
    try{
      res = await http.post(Uri.parse('$apiEndpoint/local/changepass'), body: info);
    } catch(err) {
      log('err: $err');
    }

    APIResult temp;
    try {
      temp = APIResult.apiresultFromJson(res.body);
    } catch(err) {
      temp = defaultError;
    }

    return temp;
  }

}

String getHash(String text) {
  var bytes1 = utf8.encode(text);
  var digest1 = sha256.convert(bytes1);

  return digest1.toString();
}

Future<String> getIpAddress() async {
  var res = await http.get(Uri.parse('https://api.ipify.org/?format=json'));
  
  return json.decode(res.body)['ip'];
}