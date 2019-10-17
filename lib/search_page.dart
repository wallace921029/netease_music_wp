import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:netease_music_wp/list_song_item.dart';
import 'package:netease_music_wp/my_url.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key key}) : super(key: key);

  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  GlobalKey<FormState> _formKey;
  TextEditingController textEditingController;
  FocusNode myFocusNode;

  String keywords = '';
  List songs = [];

  @override
  void initState() {
    _formKey = new GlobalKey<FormState>();
    textEditingController = new TextEditingController();
    myFocusNode = new FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new SingleChildScrollView(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 搜索
          new Form(
            key: _formKey,
            child: new Container(
              margin: new EdgeInsets.fromLTRB(10, 5, 10, 5),
              height: 30,
              child: new ClipRRect(
                borderRadius: new BorderRadius.all(new Radius.circular(20.0)),
                child: new TextField(
                  controller: textEditingController,
                  focusNode: myFocusNode,
                  cursorColor: Colors.black,
                  cursorWidth: 1,
                  decoration: new InputDecoration(
                      contentPadding: new EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      hintText: '搜索歌曲',
                      prefixIcon: new Icon(Icons.search, color: Colors.grey, size: 16.0),
                      focusColor: Colors.black,
                      hoverColor: Colors.black,
                      filled: true,
                      fillColor: new Color(0xffebecec),
                      border: InputBorder.none,
                      suffixIcon: new Offstage(
                        offstage: keywords.isEmpty,
                        child: new GestureDetector(
                          child: new Icon(Icons.clear, color: Colors.grey, size: 16.0),
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            Future.delayed(new Duration(milliseconds: 1)).then((v){
                              myFocusNode.unfocus();
                              textEditingController.clear();
                              setState(() {
                                keywords = '';
                              });
                            });
                          },
                        ),
                      ),
                    ),
                  onChanged: (text) {
                    setState(() {
                      keywords = text;
                    });
                  },
                  onSubmitted: (text) {
                    setState(() {
                      keywords = text;
                    });
                    searchKeyWords();
                  },
                ),
              ),
            ),
          ),
          // 热门搜索或搜索结果
          new Offstage(
            offstage: keywords.isNotEmpty,
            child: new FutureBuilder(
              future: http.get('${MyUrl.prefix}/search/hot'),
              builder: (context, AsyncSnapshot<Response> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  Map<String, dynamic> res = json.decode(snapshot.data.body);
                  List<Widget> list = [];
                  var tip = new Container(
                    alignment: Alignment.centerLeft,
                    margin: new EdgeInsets.all(8.0),
                    child: new Text('热门搜索',
                        style: new TextStyle(fontSize: 12, color: Colors.grey)),
                  );
                  list.add(tip);
                  List<Widget> _wrapList = [];
                  res['result']['hots'].forEach((item) {
                    var chip = new GestureDetector(
                      child: new Chip(
                        label: new Text('${item["first"]}'),
                        labelStyle: new TextStyle(fontSize: 14, color: Colors.black),
                        backgroundColor: Colors.white,
                        elevation: 0.8,
                      ),
                      onTap: () {
                        setState(() {
                          keywords = item["first"];
                        });
                        searchKeyWords();
                      },
                    );
                    _wrapList.add(chip);
                  });
                  var wrap = new Padding(
                    padding: new EdgeInsets.only(left: 8, right: 8),
                    child: new Wrap(spacing: 8.0, children: _wrapList),
                  );
                  list.add(wrap);
                  return new Column(
                    children: list,
                  );
                } else {
                  return new Text('loading');
                }
              },
            ),
          ),
          new Offstage(
            offstage: keywords.isEmpty,
            child: new Container(
              child: new Column(
                children: generateSongList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void searchKeyWords() async {
    if (keywords.isNotEmpty) {
      Response response =
          await http.get('${MyUrl.prefix}/search?keywords=$keywords');
      Map<String, dynamic> res = json.decode(response.body);
      if (res['result']['songCount'] == 0) return;
      if (mounted){
        setState(() {
        songs = res['result']['songs'];
      });
      }
    }
  }

  List<Widget> generateSongList() {
    List<Widget> list = [];
    if (songs.length == 0) {
      list.add(new Text('未查询到相关曲目'));
    }
    songs.forEach((item) {
      var id = item['id'];
      var name = item['name'];
      var description = item['alias'].isNotEmpty ? item['alias'][0] : '';
      var artist = '';
      item['artists'].forEach((_item) {
        artist += _item['name'];
      });
      var album = item['album']['name'];
      var songItem = new ListSongItem(
          id: id,
          name: name,
          description: description,
          artist: artist,
          album: album);
      list.add(songItem);
      list.add(new Divider(height: 0));
    });
    return list;
  }
}
