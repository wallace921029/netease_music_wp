import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:netease_music_wp/color.dart';
import 'package:netease_music_wp/list_song_item.dart';
import 'package:netease_music_wp/my_url.dart';

class RecommendMusic extends StatefulWidget {
  RecommendMusic({Key key}) : super(key: key);

  _RecommendMusicState createState() => _RecommendMusicState();
}

class _RecommendMusicState extends State<RecommendMusic> {
  @override
  Widget build(BuildContext context) {
    return new SingleChildScrollView(
      child: new Column(
        children: <Widget>[
          new Container(
            alignment: Alignment.centerLeft,
            margin: new EdgeInsets.only(top: 2.0, bottom: 2.0),
            padding: new EdgeInsets.only(left: 2.0),
            height: 30,
            decoration: new BoxDecoration(
                border: new Border(
                    left: new BorderSide(color: NetEaseColor.red, width: 4.0))),
            child: new Text('推荐歌单', style: new TextStyle(fontSize: 16)),
          ),
          new FutureBuilder(
            future: http.get('${MyUrl.prefix}/personalized?limit=6'),
            builder: (buildContext, snapshot) {
              List<Widget> list = [];
              if (snapshot.connectionState == ConnectionState.done) {
                Map<String, dynamic> res = json.decode(snapshot.data.body);
                res['result'].forEach((item) {
                  var album = new Container(
                    width: MediaQuery.of(context).size.width / 3 - (4 / 3),
                    child: new Column(
                      children: <Widget>[
                        new Image.network(item['picUrl']),
                        new Text(item['name'],
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: new TextStyle(fontSize: 12.0))
                      ],
                    ),
                  );
                  list.add(album);
                });
                return new Wrap(
                  spacing: 2.0,
                  runSpacing: 8.0,
                  children: list,
                );
              }
              return Text('loading...');
            },
          ),
          new Divider(color: Colors.white, height: 30,),
          new Container(
            alignment: Alignment.centerLeft,
            margin: new EdgeInsets.only(top: 2.0, bottom: 2.0),
            padding: new EdgeInsets.only(left: 2.0),
            height: 30,
            decoration: new BoxDecoration(
                border: new Border(
                    left: new BorderSide(color: NetEaseColor.red, width: 4.0))),
            child: new Text('最新音乐', style: new TextStyle(fontSize: 16)),
          ),
          new FutureBuilder(
            future: http.get('${MyUrl.prefix}/personalized/newsong'),
            builder: (buildContext, snapshot) {
              List<Widget> list = [];
              if (snapshot.connectionState == ConnectionState.done) {
                Map<String, dynamic> res = json.decode(snapshot.data.body);
                res['result'].forEach((item) {
                  var id  = item['id'];
                  var name = item['song']['name'];
                  var description = '';
                  if (item['song']['alias'].length != 0) {
                    description += '(';
                    item['song']['alias'].forEach((item) {
                      description += item;
                    });
                    description += ')';
                  }
                  var artist = '';
                  if (item['song']['artists'].length != 0) {
                    item['song']['artists'].forEach((item){
                      artist += item['name'];
                    });
                  }
                  var album = item['song']['album']['name'];
                  var listTile = new ListSongItem(id: id, name: name, description: description, artist: artist, album: album);
                  list.add(listTile);
                  list.add(new Divider(height: 0,));
                });
                return new Column(
                  children: list,
                );
              }
              return Text('loading...');
            },
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }
}
