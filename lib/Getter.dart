import 'dart:convert';

import 'package:html/parser.dart'; // Contains HTML parsers to generate a Document object
import 'package:html/dom.dart'; // Contains DOM related classes for extracting data from elements
import 'package:http/http.dart';
import 'package:ArFlix/Models/Movie.dart';

class Getter {
  static Future<List<Movie>> getLatest() async {
    var client = Client();
    Movie h;
    List<Element> ite;
    List<Movie> result = new List<Movie>();
    Response response;
    response = await client.get('https://www.movs4u.tv/');
    String body = utf8.decode(response.bodyBytes);
    var document = parse(body);

    //Movies
    ite = document.querySelectorAll('article.item.movies');
    for (var item in ite) {
      h = new Movie(
          item.querySelector("h3").querySelector("a").innerHtml,
          item.querySelector("h3").querySelector("a").attributes["href"],
          item
              .querySelector("div.poster")
              .querySelector("img")
              .attributes["src"],
          "Movie - " +
              item
                  .querySelector("div.poster")
                  .querySelector(".mepo")
                  .querySelector("span")
                  .innerHtml,
          "",
          item.querySelector("div.data").querySelector("span").innerHtml);
      result.add(h);
    }

    //TV Shows
    ite = document.querySelectorAll('article.item.tvshows');
    for (var item in ite) {
      h = new Movie(
          item.querySelector("h3").querySelector("a").innerHtml,
          item.querySelector("h3").querySelector("a").attributes["href"],
          item
              .querySelector("div.poster")
              .querySelector("img")
              .attributes["src"],
          "TV - " +
              item.querySelector("div.poster").querySelector(".ses").innerHtml +
              " " +
              item.querySelector("div.poster").querySelector(".esp").innerHtml,
          "",
          item.querySelector("div.data").querySelector("span").innerHtml);
      result.add(h);
    }

    return result;
  }

  static Future<List<Movie>> search(String str) async {
    var client = Client();
    Movie h;
    List<Element> ite;
    List<Movie> result = new List<Movie>();
    Response response;
    response = await client.get('https://www.movs4u.tv/?s=' + str);
    String body = utf8.decode(response.bodyBytes);
    var document = parse(body);

    ite = document.querySelectorAll('.result-item');
    for (var item in ite) {
      var typ = item.querySelector(".image").querySelector("span").innerHtml;
      if (typ == "Movie" || typ == "TVShow") {
        h = new Movie(
          item.querySelector(".details").querySelector(".title").querySelector("a").innerHtml,//name
          item.querySelector(".details").querySelector(".title").querySelector("a").attributes["href"],//url
          item.querySelector(".image").querySelector("img").attributes["src"],//poster
          typ,//type
          item.querySelector(".details").querySelector("p").innerHtml,//desc
          ''//year
        );
        result.add(h);
      }
    }

    return result;
  }

  static Future<List<Movie>> getWatchLinks(String str) async {
    var client = Client();
    Movie h;
    List<Element> ite;
    List<Movie> result = new List<Movie>();
    Response response;
    response = await client.get(str);
    String body = utf8.decode(response.bodyBytes);
    var document = parse(body);

    ite = document.querySelectorAll('.dooplay_player_option');
    for (var item in ite) {
      if (item.attributes["data-url"] != null) {
        h = new Movie(
          item.querySelector("span.server").innerHtml,//name
          item.attributes["data-url"],//url
          '',//poster
          item.attributes["data-type"],//type
          document.querySelector("._pm_quality").innerHtml,//desc
          ''//year
        );
        result.add(h);
      }
    }

    return result;
  }
}
