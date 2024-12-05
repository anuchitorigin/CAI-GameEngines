import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import 'package:cai_gameengine/constansts/default_error.const.dart';

import 'package:cai_gameengine/models/api_result.model.dart';
import 'package:cai_gameengine/models/exam.model.dart';
import 'package:cai_gameengine/models/recordcount.model.dart';
import 'package:cai_gameengine/models/create_quiz.model.dart';
import 'package:cai_gameengine/models/quiz.model.dart';

import 'package:cai_gameengine/services/domain.service.dart';

class ExamAPI {
  static final apiEndpoint = '${DomainService.dataEndpoint}/exam';

  Future<String> ping() async {
    http.Response res = await http.get(Uri.parse('$apiEndpoint/'), headers: { 'responseType': 'text' });

    return res.body;
  }

  Future<APIResult> createOne(
    String token,
    String examcode,
    int moduleID,
    int lessonID,
    int maxscore,
    double examminute,
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
      "examcode": examcode, 
      "module_id": moduleID,
      "lesson_id": lessonID,
      "maxscore": maxscore,
      "examminute": examminute,
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

  Future<APIResult> readOne(String token, int examID) async {
    var res;
    try{
      res = await http.get(Uri.parse('$apiEndpoint/id/$examID'), headers: { 'Authorization': 'Bearer $token' });
    } catch(err) {
      log('err: $err');
    }

    APIResult temp;
    try {
      temp = APIResult.apiresultFromJson(res.body);
    } catch(err) {
      temp = defaultError;
    }
    temp.result = ExamModel.examDataFromJson(temp.result);

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
    String? examcode,
    int? module_id,
    int? lesson_id,
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
      "examcode": examcode, 
      "module_id": module_id,
      "lesson_id": lesson_id,
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
    temp.result = ExamModel.examDataFromJson(temp.result);

    return temp;
  }

  Future<APIResult> readCount(
    String token,
    int? belocked,
    int? becancelled,
    int? docstatus,
    String? examcode,
    int? module_id,
    int? lesson_id,
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
      "examcode": examcode, 
      "module_id": module_id,
      "lesson_id": lesson_id,
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
    String examcode,
    int moduleID,
    int lessonID,
    int maxscore,
    double examminute,
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
      "examcode": examcode, 
      "module_id": moduleID,
      "lesson_id": lessonID,
      "maxscore": maxscore,
      "examminute": examminute,
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

  Future<APIResult> deleteOne(String token, int examID) async {
    var res;
    try{
      res = await http.delete(Uri.parse('$apiEndpoint/id/$examID'), headers: { 'Authorization': 'Bearer $token' });
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

  Future<APIResult> createQuizOne(
    String token,
    int exam_id,
    int quizno,
    double? quizminute,
    String question,
    String? contentid,
    String? mediaid,
    List<CreateQuizChoiceModel> choices
  ) async {
    List<Map<String, dynamic>> items = [];

    for(var choice in choices) {
      items.add({
        "answer": choice.answer,
        "choiceno": choice.choiceno,
        "choicescore": choice.choicescore,
        "becorrect": choice.becorrect,
        "mediaid": choice.mediaid,
        "feedbackid": choice.feedbackid
      });
    }

    Map<String, dynamic> info = {
      "exam_id": exam_id,
      "quizno": quizno,
      "quizminute": quizminute,
      "question": question,
      "contentid": contentid,
      "mediaid": mediaid,
      "choices": items
    };

    var res;
    try{
      res = await http.post(Uri.parse('$apiEndpoint/quiz'), body: jsonEncode(info), headers: { 'Authorization': 'Bearer $token', 'Content-type': 'application/json' });
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

  Future<APIResult> readQuizOne(String token, int quizID) async {
    var res;
    try{
      res = await http.get(Uri.parse('$apiEndpoint/quiz/id/$quizID'), headers: { 'Authorization': 'Bearer $token' });
    } catch(err) {
      log('err: $err');
    }

    APIResult temp;
    try {
      temp = APIResult.apiresultFromJson(res.body);
    } catch(err) {
      temp = defaultError;
    }
    temp.result = QuizModel.quizDataFromJson(temp.result);

    return temp;
  }

  Future<APIResult> readQuizFilter(
    String token,
    int limit,
    int page,
    String? sort,
    int? belocked,
    int? becancelled,
    int? docstatus,
    int? exam_id,
    String? question
  ) async {
    Map<String, dynamic> info = {
      "limit": limit,
      "page": page,
      "sort": sort ?? '',
      "belocked": belocked,
      "becancelled": becancelled,
      "docstatus": docstatus,
      "exam_id": exam_id,
      "question": question
    };

    http.Response res;
    try{
      res = await http.post(Uri.parse('$apiEndpoint/quiz/filter'), body: jsonEncode(info), headers: { 'Authorization': 'Bearer $token', 'Content-type': 'application/json' });
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
    temp.result = QuizModel.quizDataFromJson(temp.result);

    return temp;
  }

  Future<APIResult> readQuizCount(
    String token,
    int? belocked,
    int? becancelled,
    int? docstatus,
    int? exam_id,
    String? question
  ) async {
    var info = {
      "belocked": belocked,
      "becancelled": becancelled,
      "docstatus": docstatus,
      "exam_id": exam_id,
      "question": question
    };

    http.Response res;
    try{
      res = await http.post(Uri.parse('$apiEndpoint/quiz/count'), body: jsonEncode(info), headers: { 'Authorization': 'Bearer $token', 'Content-type': 'application/json' });
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

  Future<APIResult> updateQuizOne(
    String token,
    int id,
    int exam_id,
    int quizno,
    double? quizminute,
    String question,
    String? contentid,
    String? mediaid,
    List<CreateQuizChoiceModel> choices
  ) async {
    Map<String, dynamic> info = {
      "exam_id": exam_id,
      "quizno": quizno,
      "quizminute": quizminute,
      "question": question,
      "contentid": contentid,
      "mediaid": mediaid,
    };

    List<Map<String, dynamic>> items = [];

    for(var choice in choices) {
      items.add({
        "answer": choice.answer,
        "choiceno": choice.choiceno,
        "choicescore": choice.choicescore,
        "becorrect": choice.becorrect,
        "mediaid": choice.mediaid,
        "feedbackid": choice.feedbackid
      });
    }

    info["choices"] =  items;

    http.Response res;
    try{
      res = await http.put(Uri.parse('$apiEndpoint/quiz/id/$id'), body: jsonEncode(info), headers: { 'Authorization': 'Bearer $token', 'Content-type': 'application/json' });
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

  Future<APIResult> deleteQuizOne(String token, int quizID) async {
    var res;
    try{
      res = await http.delete(Uri.parse('$apiEndpoint/quiz/id/$quizID'), headers: { 'Authorization': 'Bearer $token' });
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