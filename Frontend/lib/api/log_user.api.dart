import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import 'package:cai_gameengine/constansts/default_error.const.dart';

import 'package:cai_gameengine/models/api_result.model.dart';
import 'package:cai_gameengine/models/log_user.model.dart';
import 'package:cai_gameengine/models/recordcount.model.dart';

import 'package:cai_gameengine/services/domain.service.dart';

class LogUserAPI {
  static final apiEndpoint = '${DomainService.dataEndpoint}/log_user';

  Future<String> ping() async {
    http.Response res = await http.get(Uri.parse(apiEndpoint), headers: { 'responseType': 'text' });

    return res.body;
  }

  Future<APIResult> readFilter(
    String token,
    int limit,
    int page,
    String? sort,
    String? datefrom,
    String? dateto,
    String? userid,
    String? incident,
    String? logdetail,
  ) async {
    Map<String, dynamic> info = {
      "limit": limit,
      "page": page,
      "sort": sort ?? '',
      "datefrom": datefrom,
      "dateto": dateto,
      "userid": userid ?? '', 
      "incident": incident ?? '',
      "logdetail": logdetail ?? '',
    };

    http.Response res;
    try{
      res = await http.post(Uri.parse('$apiEndpoint/filter'), body: jsonEncode(info), headers: { 'Authorization': 'Bearer $token', 'Content-type': 'application/json' });
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
    temp.result = LogUserModel.loguserDataFromJson(temp.result);

    return temp;
  }

  Future<APIResult> readCount(
    String token,
    String? datefrom,
    String? dateto,
    String? userid,
    String? incident,
    String? logdetail,
  ) async {
    var info = {
      "datefrom": datefrom,
      "dateto": dateto,
      "userid": userid ?? '', 
      "incident": incident ?? '',
      "logdetail": logdetail ?? '',
    };

    http.Response res;
    try{
      res = await http.post(Uri.parse('$apiEndpoint/count'), body: jsonEncode(info), headers: { 'Authorization': 'Bearer $token', 'Content-type': 'application/json' });
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
    temp.result = RecordCountModel.recordcountDataFromJson(temp.result);

    return temp;
  }
}