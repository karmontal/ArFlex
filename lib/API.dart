import 'dart:async';
import 'package:http/http.dart' as http;

const baseURL = "http://api.karapps.com";

class API {
  static Future<String> getVer() async {
    var url = baseURL + "/getver";
    return await http.read(url);
  }
}
