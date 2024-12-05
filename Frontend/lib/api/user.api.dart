import 'dart:developer';

import 'package:http/http.dart' as http;

import 'package:cai_gameengine/constansts/default_error.const.dart';

import 'package:cai_gameengine/models/api_result.model.dart';
import 'package:cai_gameengine/models/role.model.dart';
import 'package:cai_gameengine/models/profile.model.dart';
import 'package:cai_gameengine/models/user.model.dart';

import 'package:cai_gameengine/services/domain.service.dart';

class UserAPI {
  static final apiEndpoint = '${DomainService.dataEndpoint}/user';

  Future<String> ping() async {
    http.Response res = await http.get(Uri.parse(apiEndpoint), headers: { 'responseType': 'text' });

    return res.body;
  }

  Future<APIResult> readRoleAll(String token) async {
    dynamic res;
    try{
      res = await http.get(Uri.parse('$apiEndpoint/role/all'), headers: { 'Authorization': 'Bearer $token' });
    } catch(err) {
      log('err: $err');
    }

    APIResult temp;
    try {
      temp = APIResult.apiresultFromJson(res.body);
    } catch(err) {
      temp = defaultError;
    }
    temp.result = roleDataFromJson(temp.result);

    return temp;
  }

  Future<APIResult> readAll(String token) async {
    dynamic res;
    try{
      res = await http.get(Uri.parse('$apiEndpoint/all'), headers: { 'Authorization': 'Bearer $token' });
    } catch(err) {
      log('err: $err');
    }

    APIResult temp;
    try {
      temp = APIResult.apiresultFromJson(res.body);
    } catch(err) {
      temp = defaultError;
    }
    temp.result = userDataFromJson(temp.result);

    return temp;
  }

  Future<APIResult> readProfile(String token) async {
    dynamic res;
    try{
      res = await http.get(Uri.parse('$apiEndpoint/profile'), headers: { 'Authorization': 'Bearer $token' });
    } catch(err) {
      log('err: $err');
    }

    var temp;
    if(res.body != 'Unauthorized') {
      temp = APIResult.apiresultFromJson(res.body);
      temp.result = profileDataFromJson(temp.result);
    } else {
      temp = APIResult.apiresultFromJson('{"status": 0, "message": "Unauthorized", "result": []}');
    }

    return temp;
  }

  Future<APIResult> readOne(String token, String userid) async {
    dynamic res;
    try{
      res = await http.get(Uri.parse('$apiEndpoint/id/$userid'), headers: { 'Authorization': 'Bearer $token' });
    } catch(err) {
      log('err: $err');
    }

    APIResult temp;
    try {
      temp = APIResult.apiresultFromJson(res.body);
    } catch(err) {
      temp = defaultError;
    }
    temp.result = profileDataFromJson(temp.result);

    return temp;
  }

  Future<APIResult> updateUser(
    String token,
    String userid,
    String roleparam,
    String firstname,
    String? lastname,
    String? employeeid,
    String? remark) async {
    var info = {
      "roleparam": roleparam,
      "firstname": firstname,
      "lastname": lastname,
      "employeeid": employeeid ?? '',
      "remark": remark ?? ''
    };

    var res;
    try{
      res = await http.post(Uri.parse('$apiEndpoint/id/$userid'), body: info, headers: { 'Authorization': 'Bearer $token' });
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

  Future<APIResult> deleteUser(String token, String userid) async {
    var res;
    try{
      res = await http.delete(Uri.parse('$apiEndpoint/id/$userid'), headers: { 'Authorization': 'Bearer $token' });
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