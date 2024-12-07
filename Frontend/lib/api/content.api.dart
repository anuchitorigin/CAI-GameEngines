import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import 'package:cai_gameengine/constansts/default_error.const.dart';

import 'package:cai_gameengine/models/api_result.model.dart';
import 'package:cai_gameengine/models/create_content.model.dart';
import 'package:cai_gameengine/models/content.model.dart';

import 'package:cai_gameengine/services/domain.service.dart';

class ContentAPI {
  static final apiEndpoint = '${DomainService.dataEndpoint}/content';

  Future<String> ping() async {
    http.Response res = await http.get(Uri.parse('$apiEndpoint/'), headers: { 'responseType': 'text' });

    return res.body;
  }

  Future<APIResult> createOne(
    String token,
    PlatformFile content,
  ) async {
    var res;
    try{
      http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse('$apiEndpoint/'));
      request.headers['Authorization'] = 'Bearer $token';

      final mimeType = lookupMimeType(content.name);
      final httpImage = http.MultipartFile.fromBytes('contentdata', content.bytes as List<int>, contentType: MediaType.parse(mimeType!), filename: content.name);

      request.files.add(httpImage);

      final http.StreamedResponse resStream = await request.send();
      res = await resStream.stream.bytesToString();
    } catch(err) {
      log('err: $err');
    }

    var temp = APIResult.apiresultFromJson(res);
    temp.result = CreateContentModel.createContentDataFromJson(temp.result);

    return temp;
  }

  Future<APIResult> readOne(String token, String contentid) async {
    var res;
    try{
      res = await http.get(Uri.parse('$apiEndpoint/$contentid'), headers: { 'Authorization': 'Bearer $token' });
    } catch(err) {
      log('err: $err');
    }

    APIResult temp;
    try {
      temp = APIResult.apiresultFromJson(res.body);
    } catch(err) {
      temp = defaultError;
    }
    temp.result = ContentModel.contentFromJson(temp.result);

    return temp;
  }

  Future<APIResult> deleteOne(String token, String contentid) async {
    var res;
    try{
      res = await http.delete(Uri.parse('$apiEndpoint/$contentid'), headers: { 'Authorization': 'Bearer $token' });
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