import 'package:ArFlix/API.dart';
import 'package:ArFlix/Getter.dart';
import 'package:ArFlix/Models/Movie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';

//------ Global Variables------
Movie selectedMovie;
var movieWatchDetails = new List<Movie>();
var latestMovies = new List<Movie>();
var tvWatchDetails = new List<Movie>();
var searchList = new List<Movie>();
String watchURL, searchTxt, tvWatchURL, tvShowName;
bool canRunSite = false;
int ver = 1;
int latestVer = 0;

//-----------------------------

//------ Global Functions------
_launchURL() async {
  const url = 'http://api.karapps.com';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
//-----------------------------

void main() async {
  FacebookAudienceNetwork.init();
  runApp(new MyApp());
}

//------ Latest Movies ------
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'ArFlix',
      theme: new ThemeData(
        primarySwatch: Colors.red,
        backgroundColor: Colors.black,
      ),
      home: new MyListScreen(),
    );
  }
}

class MyListScreen extends StatefulWidget {
  @override
  createState() => _MyListScreenState();
}

class _MyListScreenState extends State {
  _getLatest() {
    canLaunch("https://www.movs4u.tv/").then((onValue) {
      setState(() {
        canRunSite = onValue;
      });
    });
    Getter.getLatest().then((response) {
      setState(() {
        latestMovies = response;
      });
    });
  }

  Widget _progress() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text("تحميل آخر الأفلام والمسلسلات المضافة ..."),
        CircularProgressIndicator()
      ],
    ));
  }

  Widget _done() {
    return ListView.separated(
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: latestMovies.length,
      separatorBuilder: (context, index) {
        if ((index + 1) % (5) == 0 && index > 0) {
          return FacebookNativeAd(
            placementId: "333970483937433_333971380604010",
            adType: NativeAdType.NATIVE_BANNER_AD,
            bannerAdSize: NativeBannerAdSize.HEIGHT_100,
            width: double.infinity,
            backgroundColor: Colors.blue,
            titleColor: Colors.white,
            descriptionColor: Colors.white,
            buttonColor: Colors.deepPurple,
            buttonTitleColor: Colors.white,
            buttonBorderColor: Colors.white,
            listener: (result, value) {
              print("Native Ad: $result --> $value");
            },
          );
        } else
          return SizedBox(
            height: 0,
          );
      },
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.all(5),
          child: Card(
              child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                leading: Image(
                  image: new CachedNetworkImageProvider(
                      latestMovies[index].poster),
                  height: 72,
                ),
                title: Text(latestMovies[index].name),
                subtitle: Text(latestMovies[index].type),
                onTap: () {
                  selectedMovie = latestMovies[index];
                  if (selectedMovie.type.contains('TV')) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => _TVWatchDetail()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => _MovieWatchDetail()),
                    );
                  }
                },
                trailing: IconButton(
                  icon: Icon(Icons.star_border),
                  onPressed: () {},
                ),
              ),
            ],
          )),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    canLaunch("http://api.karapps.com").then((onValue) {
      if (onValue) {
        API.getVer().then((onValue) {
          latestVer = int.parse(onValue);
        });
      }
    });

    _getLatest();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  build(context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
            appBar: AppBar(
                title: Text("آخر الأفلام والمسلسلات المضافة"),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.star),
                    tooltip: 'المفضلة',
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.search),
                    tooltip: 'بحث',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SearchS()),
                      );
                    },
                  ),
                ]),
            body: !canRunSite
                ? Center(
                    child: Text(
                        "لايمكن تشغيل موقع الأفلام حاليا ... يرجى التأكد من اتصال الانترنت"))
                : (latestMovies.length == 0
                    ? _progress()
                    : latestVer > ver
                        ? AlertDialog(
                            title: Text('إصدار جديد'),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  Text('هناك إصدار جديد للتطبيق.'),
                                  Text('انقر لتحميله من موقعنا.'),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('تحميل'),
                                onPressed: () {
                                  _launchURL();
                                },
                              ),
                            ],
                          )
                        : _done())));
  }
}
//-----------------------------

//------ Search ------
class SearchS extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'ArFlix',
      theme: new ThemeData(
        primarySwatch: Colors.red,
        backgroundColor: Colors.black,
      ),
      home: new SearchScreen(),
    );
  }
}

class SearchScreen extends StatefulWidget {
  @override
  createState() => _SearchScreenState();
}

class _SearchScreenState extends State {
  final myController = TextEditingController();

  _search(String s) {
    Getter.search(s).then((response) {
      setState(() {
        searchList = response;
      });
    });
  }

  Widget _progress() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[Text("تحميل ..."), CircularProgressIndicator()],
    ));
  }

  @override
  void initState() {
    //
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
//    _getLatest();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  build(context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
              title: TextField(
                decoration: InputDecoration(
                    border: InputBorder.none, hintText: 'أبحث عن ...'),
                controller: myController,
                onChanged: (sss) {
                  _search(sss);
                },
              ), //Text("Latest Movies"),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.search),
                  tooltip: 'بحث',
                  onPressed: () {
                    /* ... */
                  },
                ),
              ]),
          body: myController.text == ""
              ? SizedBox(
                  height: 0,
                )
              : (searchList.length == 0
                  ? _progress()
                  : ListView.builder(
                      itemCount: searchList.length,
                      itemBuilder: (context, index) {
                        return Center(
                          child: Card(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(
                                  leading: Image(
                                    image: new CachedNetworkImageProvider(
                                        searchList[index].poster),
                                    height: 72,
                                  ),
                                  title: Text(searchList[index].name),
                                  subtitle: Text(searchList[index].type),
                                  onTap: () {
                                    selectedMovie = searchList[index];
                                    if (selectedMovie.type.contains('TV')) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                _TVWatchDetail()),
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                _MovieWatchDetail()),
                                      );
                                    }
                                  },
                                  trailing: IconButton(
                                    icon: Icon(Icons.star_border),
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )),
        ));
  }
}
//-----------------------------

//------ Movie Watch Links ------
class _MovieWatchDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new _MovieWatchStateFul(),
    );
  }
}

class _MovieWatchStateFul extends StatefulWidget {
  @override
  createState() => _MovieWatchState();
}

class _MovieWatchState extends State {
  _getWatchDetails(String lnk) {
    movieWatchDetails = new List<Movie>();
    Getter.getWatchLinks(lnk).then((response) {
      setState(() {
        movieWatchDetails = response;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _getWatchDetails(selectedMovie.url);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Widget _progress() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text("تحميل روابط مشاهدة الفيلم ..."),
        CircularProgressIndicator()
      ],
    ));
  }

  Widget _done() {
    return ListView.separated(
      itemCount: movieWatchDetails.length + 1,
      separatorBuilder: (context, index) {
        if (index == 0) {
          return Container(
            padding: EdgeInsets.all(10.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
//                  Row(
//                    crossAxisAlignment: CrossAxisAlignment.start,
//                    children: [
//                      Container(
//                        height: 300.0,
//                        padding: const EdgeInsets.all(8.0),
//                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
//                        child: Image(
//                          image: new CachedNetworkImageProvider(
//                              selectedMovie.poster),
//                          height: 300,
//                        ),
//                      ),
//                      Container(
//                          height: 300.0,
//                          padding: const EdgeInsets.all(8.0),
//                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
//                          child: Column(
//                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                            mainAxisSize: MainAxisSize.max,
//                            crossAxisAlignment: CrossAxisAlignment.center,
//                            children: [
//                              RaisedButton(
//                                color: Colors.redAccent,
//                                textColor: Colors.white,
//                                child: Text("مشاهدة"),
//                                onPressed: () {},
//                              ),
//                              RaisedButton(
//                                color: Colors.redAccent,
//                                textColor: Colors.white,
//                                child: Text("تحميل"),
//                              )
//                            ],
//                          ))
//                    ],
//                  ),
//                  Text(selectedMovie.name, style: TextStyle(fontSize: 24.0)),
//                  Text(selectedMovie.type),
                  Center(
                    child: Text("سيرفرات المشاهدة"),
                  )
                ]),
          );
        } else if (index % (4) == 0) {
          return Divider(); //Text("Advertisement");
        } else {
          return SizedBox(
            height: 0,
          );
        }
      },
      itemBuilder: (context, index) {
        if (index == 0 || index == movieWatchDetails.length) {
          return SizedBox(
            height: 0,
          );
        } else {
          return Center(
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    title: Text(movieWatchDetails[index].name),
                    onTap: () {
                      watchURL = movieWatchDetails[index].url;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => _MovieWatchWebView()),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  @override
  build(context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 300.0,
                floating: false,
                pinned: true,
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.search),
                    tooltip: 'بحث',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SearchS()),
                      );
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text("فيلم " + selectedMovie.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        )),
                    background: Image(
                      image:
                          new CachedNetworkImageProvider(selectedMovie.poster),
                      fit: BoxFit.cover,
                    )),
              ),
            ];
          },
          body: movieWatchDetails.length == 0 ? _progress() : _done(),
        ));
  }
}
//-----------------------------

//------ TV Shows Watch Episodes ------
class _TVWatchDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new _TVWatchStateFul(),
    );
  }
}

class _TVWatchStateFul extends StatefulWidget {
  @override
  createState() => _TVWatchState();
}

class _TVWatchState extends State {
  _getWatchDetails(String lnk) {
    movieWatchDetails = new List<Movie>();
    Getter.getTVShowDetails(lnk).then((response) {
      setState(() {
        movieWatchDetails = response;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _getWatchDetails(selectedMovie.url);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Widget _progress() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text("تحميل تفاصيل المسلسل ..."),
        CircularProgressIndicator()
      ],
    ));
  }

  List<Widget> _geteps(List<Movie> s) {
    List<Widget> w = new List<Widget>();
    for (int i = 0; i < s.length; i++) {
      w.add(new ListTile(
        title: Text(s[i].desc + " (" + s[i].name + ")"),
        subtitle: Text(s[i].year),
        leading: Image(
          image: new CachedNetworkImageProvider(s[i].poster),
          height: 72,
        ),
        onTap: () {
          tvWatchURL = s[i].url;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => _TVWatchLinksState()),
          );
        },
      ));
      w.add(Divider());
    }
    return w;
  }

  Widget _done() {
    List<String> seasons = new List<String>();
    List<List<Movie>> movs = new List<List<Movie>>();
    seasons.add("");
    int s = 0;
    for (int i = 0; i < movieWatchDetails.length; i++) {
      if (seasons[s] != movieWatchDetails[i].type) {
        seasons.add(movieWatchDetails[i].type);
        var mm = movieWatchDetails
            .where((s) => s.type == movieWatchDetails[i].type)
            .toList();
        movs.add(mm);
        s++;
      }
    }

//    String season = "";
    return ListView.separated(
      itemCount: seasons.length,
      separatorBuilder: (context, index) {
        if (index == 0) {
//          season = movieWatchDetails[0].type;
          return Container(
            padding: EdgeInsets.all(10.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text("الحلقات"),
                  ),
                ]),
          );
        } else {
          return SizedBox(
            height: 0,
          );
        }
      },
      itemBuilder: (context, index) {
        if (index == 0) {
          return SizedBox(
            height: 0,
          );
        } else {
          return ExpansionTile(
            title: Text("Season " + seasons[index]),
            children: _geteps(movs[index - 1]),
          );
        }
      },
    );
  }

  @override
  build(context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 300.0,
                floating: false,
                pinned: true,
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.search),
                    tooltip: 'بحث',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SearchS()),
                      );
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text("مسلسل " + selectedMovie.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        )),
                    background: Image(
                      image:
                          new CachedNetworkImageProvider(selectedMovie.poster),
                      fit: BoxFit.cover,
                    )),
              ),
            ];
          },
          body: movieWatchDetails.length == 0 ? _progress() : _done(),
        ));
  }
}
//-----------------------------

//------ TV Watch Links ------
class _TVWatchLinksState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new _MovieWatchLinksStateFul(),
    );
  }
}

class _MovieWatchLinksStateFul extends StatefulWidget {
  @override
  createState() => _MovieWatchLinksState();
}

class _MovieWatchLinksState extends State {
  _getTVWatchLinks(String lnk) {
    tvWatchDetails = new List<Movie>();
    Getter.getWatchLinks(lnk).then((response) {
      setState(() {
        tvWatchDetails = response;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _getTVWatchLinks(tvWatchURL);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Widget _progress() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text("تحميل روابط المشاهدة ..."),
        CircularProgressIndicator()
      ],
    ));
  }

  Widget _done() {
    return ListView.builder(
        itemCount: tvWatchDetails.length,
        itemBuilder: (context, index) {
          return Center(
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    title: Text(tvWatchDetails[index].name),
                    onTap: () {
                      watchURL = tvWatchDetails[index].url;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => _MovieWatchWebView()),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  build(context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: Text("سيرفرات المشاهدة"), actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              tooltip: 'بحث',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchS()),
                );
              },
            ),
          ]),
          body: tvWatchDetails.length == 0 ? _progress() : _done(),
        ));
  }
}
//-----------------------------

//------ Watch Web View Plugin ------
class _MovieWatchWebView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: new _MovieWatchWebViewStateFul());
  }
}

class _MovieWatchWebViewStateFul extends StatefulWidget {
  @override
  createState() => _MovieWatchWebViewState();
}

class _MovieWatchWebViewState extends State {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  build(context) {
    return new WebviewScaffold(
      url: watchURL,
      supportMultipleWindows: true,
    );
  }
}
//-----------------------------
