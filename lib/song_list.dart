import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:netease_music_wp/color.dart';
import 'package:netease_music_wp/list_song_item.dart';
import 'package:netease_music_wp/my_label.dart';
import 'package:netease_music_wp/my_url.dart';

class SongList extends StatefulWidget {
  final int id;
  SongList({Key key, this.id}) : super(key: key);

  _SongListState createState() => _SongListState();
}

class _SongListState extends State<SongList> {
  String coverImgUrl;
  String name = '';
  List tags = [];
  String description = '';
  TextOverflow overflow = TextOverflow.ellipsis;
  int showLine = 1;
  int maxLine = 1;
  bool isCollapse = true;
  List tracks = [];

  @override
  void initState() {
    getDate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> generateTagWidgetList() {
      List<Widget> tagWidgetList = [];
      tagWidgetList.add(new Padding(
          padding: new EdgeInsets.only(left: 8, right: 4),
          child: new Text('标签:', style: new TextStyle(fontSize: 12.0))));
      tags.forEach((item) {
        tagWidgetList.add(new MyLabel(text: item));
      });
      return tagWidgetList;
    }

    generateCollapseIcon() {
      if (isCollapse && maxLine > 3) {
        return new GestureDetector(
          child: new Container(
            alignment: Alignment.centerRight,
            child: new Icon(Icons.arrow_drop_down, color: Colors.grey),
          ),
          onTap: () {
            setState(() {
              overflow = null;
              showLine = null;
              isCollapse = false;
            });
          },
        );
      }
      if (!isCollapse && maxLine > 3) {
        return new GestureDetector(
          child: new Container(
            alignment: Alignment.centerRight,
            child: new Icon(Icons.arrow_drop_up, color: Colors.grey),
          ),
          onTap: () {
            setState(() {
              overflow = TextOverflow.ellipsis;
              showLine = 3;
              isCollapse = true;
            });
          },
        );
      }
      return new Offstage();
    }

    List<Widget> generateSongList() {
      List<Widget> list = [];
      for (var i = 0; i < tracks.length; i++) {
        var item = tracks[i];

        var id = item['id'];
        var name = item['name'];
        var description = item['alia'].isNotEmpty ? item['alia'][0] : '';
        var artist = '';
        item['ar'].forEach((_item) {
          artist += _item['name'];
        });
        var album = item['al']['name'];
        var leading = new Container(
            width: 40,
            child: new Text('${i < 9 ? "0" + (i + 1).toString() : i + 1}',
                textAlign: TextAlign.center,
                style: new TextStyle(
                    fontSize: 16, color: i < 3 ? Colors.red : Colors.grey)));

        var song = new ListSongItem(
            id: id,
            name: name,
            description: description,
            artist: artist,
            album: album,
            leading: leading);
        list.add(song);
        list.add(new Divider(height: 0));
      }
      return list;
    }

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('歌单'),
        backgroundColor: NetEaseColor.red,
      ),
      body: new SingleChildScrollView(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 顶部封面
            new Stack(
              children: <Widget>[
                coverImgUrl == null
                    ? new Text('loading')
                    : new Image.network(coverImgUrl,
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        fit: BoxFit.cover),
                new BackdropFilter(
                    filter: new ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: new Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.black.withAlpha(100),
                    )),
                new Container(
                  child: new Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Padding(
                        padding: new EdgeInsets.all(25),
                        child: coverImgUrl == null
                            ? new Text('loading')
                            : new Image.network(coverImgUrl,
                                width: 100, height: 100),
                      ),
                      new Expanded(
                        child: new Padding(
                          padding: new EdgeInsets.only(top: 25),
                          child: new Text(name,
                              style: new TextStyle(
                                  fontSize: 16, color: Colors.white)),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
            // 标签
            new Padding(
              padding: new EdgeInsets.only(top: 10.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: generateTagWidgetList(),
              ),
            ),
            // 简介
            new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Container(
                  alignment: Alignment.topLeft,
                  padding: new EdgeInsets.fromLTRB(8, 10, 8, 0),
                  child: new Text(
                    description,
                    overflow: overflow,
                    maxLines: showLine,
                    style: new TextStyle(fontSize: 12.0),
                  ),
                ),
                generateCollapseIcon()
              ],
            ),
            // 歌曲列表
            new Container(
              padding: new EdgeInsets.only(
                  left: 8.0, right: 8.0, top: 4.0, bottom: 4.0),
              width: double.infinity,
              color: NetEaseColor.grey,
              child: new Text('歌曲列表', style: new TextStyle(fontSize: 12.0)),
            ),
            new Column(
              children: generateSongList(),
            )
          ],
        ),
      ),
    );
  }

  void getDate() async {
    Response response =
        await http.get('${MyUrl.prefix}/playlist/detail?id=${widget.id}');
    Map<String, dynamic> res = json.decode(response.body);
    setState(() {
      coverImgUrl = res['playlist']['coverImgUrl'];
      name = res['playlist']['name'];
      tags = res['playlist']['tags'];
      description = '简介: ${res['playlist']['description']}';
      setDynamicLineNumber();
      tracks = res['playlist']['tracks'];
    });
  }

  void setDynamicLineNumber() {
    var lineMaxNumber = ((MediaQuery.of(context).size.width - 20) / 12).floor();
    var line = (description.length / lineMaxNumber).ceil();
    if (line < 4) {
      setState(() {
        overflow = null;
        maxLine = line;
        showLine = line;
      });
    } else {
      setState(() {
        overflow = TextOverflow.ellipsis;
        maxLine = line;
        showLine = 3;
      });
    }
  }
}
