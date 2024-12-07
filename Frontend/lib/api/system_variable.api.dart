import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import 'package:cai_gameengine/constansts/default_error.const.dart';

import 'package:cai_gameengine/models/api_result.model.dart';
import 'package:cai_gameengine/models/system_variable.model.dart';

import 'package:cai_gameengine/services/domain.service.dart';

class SystemVariableAPI {
  static final apiEndpoint = '${DomainService.dataEndpoint}/sysvar';

  Future<String> ping() async {
    http.Response res = await http.get(Uri.parse(apiEndpoint), headers: { 'responseType': 'text' });

    return res.body;
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
    temp.result = SystemVariableModel.systemvariableDataFromJson(temp.result);

    return temp;
  }

  Future<APIResult> readOne(String token, int id) async {
    dynamic res;
    try{
      res = await http.get(Uri.parse('$apiEndpoint/id/$id'), headers: { 'Authorization': 'Bearer $token' });
    } catch(err) {
      log('err: $err');
    }

    APIResult temp;
    try {
      temp = APIResult.apiresultFromJson(res.body);
    } catch(err) {
      temp = defaultError;
    }
    temp.result = SystemVariableModel.systemvariableDataFromJson(temp.result);

    return temp;
  }

  Future<APIResult> readValue(String token, String varid) async {
    dynamic res;
    try{
      res = await http.get(Uri.parse('$apiEndpoint/value/$varid'), headers: { 'Authorization': 'Bearer $token' });
    } catch(err) {
      log('err: $err');
    }

    APIResult temp;
    try {
      temp = APIResult.apiresultFromJson(res.body);
    } catch(err) {
      temp = defaultError;
    }
    temp.result = VariableValueModel.variablevalueDataFromJson(temp.result);

    return temp;
  }

  Future<APIResult> updateOne(
    String token,
    int id,
    String varname,
    String? descr,
    String varvalue,
  ) async {
    var info = <String, dynamic>{
      "varname": varname,
      "descr": descr ?? '',
      "varvalue": varvalue,
    };

    http.Response res;
    try{
      res = await http.put(Uri.parse('$apiEndpoint/id/$id'), body: jsonEncode(info), headers: { 'Authorization': 'Bearer $token', 'Content-type': 'application/json' });
    } catch(err) {
      res = http.Response('{"status": 0, "message": "$err", "result": []}', 500);
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