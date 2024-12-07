import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import 'package:cai_gameengine/constansts/default_error.const.dart';

import 'package:cai_gameengine/models/api_result.model.dart';
import 'package:cai_gameengine/models/recordcount.model.dart';
import 'package:cai_gameengine/models/module.model.dart';
import 'package:cai_gameengine/models/lesson.model.dart';

import 'package:cai_gameengine/services/domain.service.dart';

class ModuleAPI {
  static final apiEndpoint = '${DomainService.dataEndpoint}/module';

  Future<String> ping() async {
    http.Response res = await http.get(Uri.parse('$apiEndpoint/'), headers: { 'responseType': 'text' });

    return res.body;
  }

  Future<APIResult> createOne(
    String token,
    String modulecode,
    String title,
    String caption,
    String? descr,
    String? coverid,
    int maturityrating,
    List<String> tags
  ) async {
    String tagList = '[';

    final int length = tags.length;
    for (var i = 0; i < length; i++) {
      if(tags[i].isNotEmpty) {
        tagList += '${i > 0 ? ',' : ''}"${tags[i].trim()}"';
      }
    }
    tagList += ']';

    Map<String, dynamic> info = {
      "modulecode": modulecode, 
      "title": title,
      "caption": caption,
      "descr": descr,
      "coverid": coverid,
      "maturityrating": maturityrating,
      "tags": tagList
    };

    var res;
    try{
      res = await http.post(Uri.parse('$apiEndpoint/'), body: jsonEncode(info), headers: { 'Authorization': 'Bearer $token', 'Content-type': 'application/json' });
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

  Future<APIResult> readOne(String token, int moduleID) async {
    var res;
    try{
      res = await http.get(Uri.parse('$apiEndpoint/id/$moduleID'), headers: { 'Authorization': 'Bearer $token' });
    } catch(err) {
      log('err: $err');
    }

    APIResult temp;
    try {
      temp = APIResult.apiresultFromJson(res.body);
    } catch(err) {
      temp = defaultError;
    }
    temp.result = ModuleModel.moduleDataFromJson(temp.result);

    return temp;
  }

  Future<APIResult> readFilter(
    String token,
    int limit,
    int page,
    String? sort,
    int? belocked,
    int? becancelled,
    int? docstatus,
    String? modulecode,
    String? title,
    String? caption,
    String? descr,
    int? maturityrating,
    List<String> tags
  ) async {
    String tagList = '[';

    final int length = tags.length;
    for (var i = 0; i < length; i++) {
      if(tags[i].isNotEmpty) {
        tagList += '${i > 0 ? ',' : ''}"${tags[i].trim()}"';
      }
    }
    tagList += ']';

    Map<String, dynamic> info = {
      "limit": limit,
      "page": page,
      "sort": sort ?? '',
      "belocked": belocked,
      "becancelled": becancelled,
      "docstatus": docstatus,
      "modulecode": modulecode, 
      "title": title,
      "caption": caption,
      "descr": descr,
      "maturityrating": maturityrating,
      "tags": tagList
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
    temp.result = ModuleModel.moduleDataFromJson(temp.result);

    return temp;
  }

  Future<APIResult> readCount(
    String token,
    int? belocked,
    int? becancelled,
    int? docstatus,
    String? modulecode,
    String? title,
    String? caption,
    String? descr,
    int? maturityrating,
    List<String> tags
  ) async {
    String tagList = '[';

    final int length = tags.length;
    for (var i = 0; i < length; i++) {
      if(tags[i].isNotEmpty) {
        tagList += '${i > 0 ? ',' : ''}"${tags[i].trim()}"';
      }
    }
    tagList += ']';

    var info = {
      "belocked": belocked,
      "becancelled": becancelled,
      "docstatus": docstatus,
      "modulecode": modulecode, 
      "title": title,
      "caption": caption,
      "descr": descr,
      "maturityrating": maturityrating,
      "tags": tagList
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

  Future<APIResult> updateOne(
    String token,
    int id,
    String modulecode,
    String title,
    String caption,
    String? descr,
    String? coverid,
    int maturityrating,
    List<String> tags
  ) async {
    String tagList = '[';

    final int length = tags.length;
    for (var i = 0; i < length; i++) {
      if(tags[i].isNotEmpty) {
        tagList += '${i > 0 ? ',' : ''}"${tags[i].trim()}"';
      }
    }
    tagList += ']';

    Map<String, dynamic> info = {
      "modulecode": modulecode, 
      "title": title,
      "caption": caption,
      "descr": descr,
      "coverid": coverid,
      "maturityrating": maturityrating,
      "tags": tagList
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

  Future<APIResult> deleteOne(String token, int moduleID) async {
    var res;
    try{
      res = await http.delete(Uri.parse('$apiEndpoint/id/$moduleID'), headers: { 'Authorization': 'Bearer $token' });
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

  Future<APIResult> createLessonOne(
    String token,
    String lessoncode,
    int module_id,
    int lessonno,
    String title,
    String? descr,
    String? coverid,
    String? contentid,
    String? mediaid,
    List<String> tags
  ) async {
    String tagList = '[';

    final int length = tags.length;
    for (var i = 0; i < length; i++) {
      if(tags[i].isNotEmpty) {
        tagList += '${i > 0 ? ',' : ''}"${tags[i].trim()}"';
      }
    }
    tagList += ']';

    Map<String, dynamic> info = {
      "lessoncode": lessoncode,
      "module_id": module_id,
      "lessonno": lessonno,
      "title": title,
      "descr": descr,
      "coverid": coverid,
      "contentid": contentid,
      "mediaid": mediaid,
      "tags": tagList
    };

    var res;
    try{
      res = await http.post(Uri.parse('$apiEndpoint/lesson'), body: jsonEncode(info), headers: { 'Authorization': 'Bearer $token', 'Content-type': 'application/json' });
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

  Future<APIResult> readLessonOne(String token, int lessonID) async {
    var res;
    try{
      res = await http.get(Uri.parse('$apiEndpoint/lesson/id/$lessonID'), headers: { 'Authorization': 'Bearer $token' });
    } catch(err) {
      log('err: $err');
    }

    APIResult temp;
    try {
      temp = APIResult.apiresultFromJson(res.body);
    } catch(err) {
      temp = defaultError;
    }
    temp.result = LessonModel.lessonDataFromJson(temp.result);

    return temp;
  }

  Future<APIResult> readLessonFilter(
    String token,
    int limit,
    int page,
    String? sort,
    int? module_id,
    String? lessoncode,
    String? title,
    String? descr,
    List<String> tags
  ) async {
    String tagList = '[';

    final int length = tags.length;
    for (var i = 0; i < length; i++) {
      if(tags[i].isNotEmpty) {
        tagList += '${i > 0 ? ',' : ''}"${tags[i].trim()}"';
      }
    }
    tagList += ']';

    Map<String, dynamic> info = {
      "limit": limit,
      "page": page,
      "sort": sort ?? '',
      "module_id": module_id,
      "lessoncode": lessoncode,
      "title": title,
      "descr": descr,
      "tags": tagList
    };

    http.Response res;
    try{
      res = await http.post(Uri.parse('$apiEndpoint/lesson/filter'), body: jsonEncode(info), headers: { 'Authorization': 'Bearer $token', 'Content-type': 'application/json' });
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
    temp.result = LessonModel.lessonDataFromJson(temp.result);

    return temp;
  }

  Future<APIResult> readLessonCount(
    String token,
    int? module_id,
    String? lessoncode,
    String? title,
    String? descr,
    List<String> tags
  ) async {
    String tagList = '[';

    final int length = tags.length;
    for (var i = 0; i < length; i++) {
      if(tags[i].isNotEmpty) {
        tagList += '${i > 0 ? ',' : ''}"${tags[i].trim()}"';
      }
    }
    tagList += ']';

    var info = {
      "module_id": module_id,
      "lessoncode": lessoncode,
      "title": title,
      "descr": descr,
      "tags": tagList
    };

    http.Response res;
    try{
      res = await http.post(Uri.parse('$apiEndpoint/lesson/count'), body: jsonEncode(info), headers: { 'Authorization': 'Bearer $token', 'Content-type': 'application/json' });
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

  Future<APIResult> updateLessonOne(
    String token,
    int id,
    String lessoncode,
    int module_id,
    int lessonno,
    String title,
    String? descr,
    String? coverid,
    String? contentid,
    String? mediaid,
    List<String> tags
  ) async {
    String tagList = '[';

    final int length = tags.length;
    for (var i = 0; i < length; i++) {
      if(tags[i].isNotEmpty) {
        tagList += '${i > 0 ? ',' : ''}"${tags[i].trim()}"';
      }
    }
    tagList += ']';

    Map<String, dynamic> info = {
      "lessoncode": lessoncode,
      "module_id": module_id,
      "lessonno": lessonno,
      "title": title,
      "descr": descr,
      "coverid": coverid,
      "contentid": contentid,
      "mediaid": mediaid,
      "tags": tagList
    };

    http.Response res;
    try{
      res = await http.put(Uri.parse('$apiEndpoint/lesson/id/$id'), body: jsonEncode(info), headers: { 'Authorization': 'Bearer $token', 'Content-type': 'application/json' });
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

  Future<APIResult> deleteLessonOne(String token, int lessonID) async {
    var res;
    try{
      res = await http.delete(Uri.parse('$apiEndpoint/lesson/id/$lessonID'), headers: { 'Authorization': 'Bearer $token' });
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