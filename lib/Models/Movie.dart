class Movie {
  String name;
  String url;
  String poster;
  String type;
  String desc;
  String year;
  bool fav;

  Movie(String name, String url, String poster, String type, String desc,
      String year) {
    this.name = name;
    this.url = url;
    this.poster = poster;
    this.type = type;
    this.desc = desc;
    this.year = year;
  }

  Movie.fromJson(Map json)
      : name = json['Name'],
        url = json['Url'],
        poster = json['poster'],
        type = json['type'],
        desc = json['desc'],
        year = json['year'];

  Map toJson() {
    return {
      'Name': name,
      'Url': url,
      'poster': poster,
      'type': type,
      'desc': desc,
      'year': year
    };
  }
}
