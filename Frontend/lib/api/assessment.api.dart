import 'dart:convert';
import 'dart:core';
import 'dart:developer';

import 'package:http/http.dart' as http;

import 'package:cai_gameengine/constansts/default_error.const.dart';

import 'package:cai_gameengine/models/api_result.model.dart';
import 'package:cai_gameengine/models/assessment.model.dart';
import 'package:cai_gameengine/models/recordcount.model.dart';

import 'package:cai_gameengine/services/domain.service.dart';

class AssessmentAPI {
  static final apiEndpoint = '${DomainService.mainEndpoint}/assessment';

  Future<String> ping() async {
    http.Response res = await http.get(Uri.parse('$apiEndpoint/'), headers: { 'responseType': 'text' });

    return res.body;
  }

  Future<APIResult> createOne(
    String token,
    String? examcode,
    int? moduleID,
    int? lessonID,
  ) async {
    Map<String, dynamic> info = {
      "examcode": examcode,
      "module_id": moduleID,
      "lesson_id": lessonID
    };

    http.Response res;
    try{
      res = await http.post(Uri.parse('$apiEndpoint/'), body: jsonEncode(info), headers: { 'Authorization': 'Bearer $token', 'Content-type': 'application/json' });
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
    temp.result = CreateAssessmentResult.createassessmentresultFromJson(temp.result);
    

    return temp;
  }

  Future<APIResult> readFilter(
    String token,
    int limit,
    int page,
    String? sort,
    String? datefrom,
    String? dateto,
    String? finishedfrom,
    String? finishedto,
    String? userid,
    String? examcode,
    int? moduleID,
    int? lessonID
  ) async {
    Map<String, dynamic> info = {
      "limit": limit,
      "page": page,
      "sort": sort ?? '',
      "datefrom": datefrom,
      "dateto": dateto,
      "finishedfrom": finishedfrom,
      "finishedto": finishedto,
      "userid": userid,
      "examcode": examcode, 
      "module_id": moduleID,
      "lesson_id": lessonID
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
    temp.result = AssessmentModel.assessmentFromJson(temp.result);

    return temp;
  }

  Future<APIResult> readCount(
    String token,
    String? datefrom,
    String? dateto,
    String? finishedfrom,
    String? finishedto,
    String? userid,
    String? examcode,
    int? moduleID,
    int? lessonID
  ) async {
    Map<String, dynamic> info = {
      "datefrom": datefrom,
      "dateto": dateto,
      "finishedfrom": finishedfrom,
      "finishedto": finishedto,
      "userid": userid,
      "examcode": examcode, 
      "module_id": moduleID,
      "lesson_id": lessonID
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
    String examid,
    int finishminute,
    List<CreateUpdateOne> quizzes,
  ) async {
    List<Map<String, dynamic>> quizList = [];

    for(var quiz in quizzes) {
      quizList.add(quiz.toMap());
    }

    Map<String, dynamic> info = {
      "examid": examid,
      "finishminute": finishminute,
      "quizzes": quizList
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

  Future<APIResult> checkChoice(
    String token,
    String examid,
    int quizID,
    int choiceID
  ) async {
    Map<String, dynamic> info = {
      "examid": examid,
      "quiz_id": quizID,
      "choice_id": choiceID
    };

    http.Response res;
    try{
      res = await http.post(Uri.parse('$apiEndpoint/check/choice'), body: jsonEncode(info), headers: { 'Authorization': 'Bearer $token', 'Content-type': 'application/json' });
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
    temp.result = CheckChoiceModel.checkchoiceDataFromJson(temp.result);

    return temp;
  }

}