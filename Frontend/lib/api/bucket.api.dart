import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import 'package:cai_gameengine/constansts/default_error.const.dart';

import 'package:cai_gameengine/models/api_result.model.dart';
import 'package:cai_gameengine/models/create_bucket.model.dart';
import 'package:cai_gameengine/models/bucket.model.dart';

import 'package:cai_gameengine/services/domain.service.dart';

class BucketAPI {
  static final apiEndpoint = '${DomainService.dataEndpoint}/bucket';

  Future<String> ping() async {
    http.Response res = await http.get(Uri.parse('$apiEndpoint/'), headers: { 'responseType': 'text' });

    return res.body;
  }

  Future<APIResult> createOne(
    String token,
    PlatformFile image,
  ) async {
    var res;
    try{
      final mimeType = lookupMimeType(image.name);

      String requestFilename = image.name;
      if(requestFilename.length > 80) {
        final splitFilename = requestFilename.split('.');
        final fileExt = splitFilename.removeLast();
        final filename = splitFilename.join();

        requestFilename = '${filename.substring(0, 80 - fileExt.length - 2)}~.$fileExt';
      }

      final httpImage = http.MultipartFile.fromBytes('imagedata', image.bytes as List<int>, contentType: MediaType.parse(mimeType!), filename: requestFilename);

      http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse('$apiEndpoint/'));
      request.fields['filename'] = requestFilename;
      request.files.add(httpImage);
      request.headers['Authorization'] = 'Bearer $token';

      final http.StreamedResponse resStream = await request.send();
      res = await resStream.stream.bytesToString();
    } catch(err) {
      log('err: $err');
    }

    var temp = APIResult.apiresultFromJson(res);
    temp.result = CreateBucketModel.createBucketDataFromJson(temp.result);

    return temp;
  }

  Future<APIResult> readOne(String token, String pictureid) async {
    var res;
    try{
      res = await http.get(Uri.parse('$apiEndpoint/$pictureid'), headers: { 'Authorization': 'Bearer $token' });
    } catch(err) {
      log('err: $err');
    }

    var temp = APIResult.apiresultFromJson(utf8.decode(res.bodyBytes));
    temp.result = BucketModel.bucketFromJson(temp.result);

    return temp;
  }

  Future<APIResult> deleteOne(String token, String pictureid) async {
    var res;
    try{
      res = await http.delete(Uri.parse('$apiEndpoint/$pictureid'), headers: { 'Authorization': 'Bearer $token' });
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