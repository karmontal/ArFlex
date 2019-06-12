import 'dart:convert';
import 'package:sqflite/sqflite.dart';

import 'dbConn.dart';
import 'package:html/parser.dart'; // Contains HTML parsers to generate a Document object
import 'package:html/dom.dart'; // Contains DOM related classes for extracting data from elements
import 'package:http/http.dart';
import 'package:ArFlix/Models/Movie.dart';

class Getter {
  static Database dbb;
  static void init() {
    DbConn.getDb().then((onValue) {
      openDatabase(onValue).then((onValue){
        dbb = onValue;
      });
    });
  }

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
      h.fav = false;
      
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
      h.fav = false;
      
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
            item
                .querySelector(".details")
                .querySelector(".title")
                .querySelector("a")
                .innerHtml, //name
            item
                .querySelector(".details")
                .querySelector(".title")
                .querySelector("a")
                .attributes["href"], //url
            item
                .querySelector(".image")
                .querySelector("img")
                .attributes["src"], //poster
            typ, //type
            item.querySelector(".details").querySelector("p").innerHtml, //desc
            '' //year
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
            item.querySelector("span.server").innerHtml, //name
            item.attributes["data-url"], //url
            '', //poster
            item.attributes["data-type"], //type
            '', //desc
            '' //year
            );
        result.add(h);
      }
    }

    return result;
  }

  static Future<List<Movie>> getTVShowDetails(String str) async {
    var client = Client();
    Movie h;
    List<Movie> result = new List<Movie>();
    Response response;
    response = await client.get(str);
    String body = utf8.decode(response.bodyBytes);
    var document = parse(body);

    var ses = document.querySelectorAll(".se-c");
    for (var sea in ses) {
      var eps = sea.querySelector(".episodios").querySelectorAll("li");
      for (var ep in eps) {
        h = new Movie(
            ep.querySelector("a").innerHtml, //name
            ep.querySelector("a").attributes["href"], //url
            ep.querySelector("img").attributes["src"], //poster
            sea.querySelector(".se-t").innerHtml, //type
            ep.querySelector(".numerando").innerHtml, //desc
            ep.querySelector(".date").innerHtml //year
            );
        result.add(h);
      }
    }

    return result;
  }
  //sasdad
}
