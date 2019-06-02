import 'dart:async';
import 'package:http/http.dart' as http;

const baseURL = "http://api.karapps.com";

class API {
  static Future getLatest() async {
    var url = baseURL + "/GetLatest";
    return await http.get(url);
  }

  static Future getMovieWatchLinks(String nam) async {
    var url = baseURL + "/GetMovie?id=" + nam;
    return await http.get(url);
  }

  static Future getTVSEpisodes(String nam) async {
    var url = baseURL + "/GetTV?id=" + nam;
    return await http.get(url);
  }

  static Future getTVEpisodeWatchLinks(String nam) async {
    var url = baseURL + "/GetEP?id=" + nam;
    return await http.get(url);
  }

  static Future getSearch(String nam) async {
    var url = baseURL + "/search?s=" + nam;
    return await http.get(url);
  }

  static Future<String> getVer() async {
    var url = baseURL + "/getver";
    return await http.read(url);
  }
}
