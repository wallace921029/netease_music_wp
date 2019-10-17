import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:netease_music_wp/list_song_item.dart';
import 'package:netease_music_wp/my_url.dart';

class HotList extends StatefulWidget {
  HotList({Key key}) : super(key: key);

  _HotListState createState() => _HotListState();
}

class _HotListState extends State<HotList> {
  List<Widget> list = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    Response response = await http.get('${MyUrl.prefix}/top/list?idx=1');
    Map<String, dynamic> res = json.decode(response.body);

    var updateTime = DateTime.now();
    var stack = new Stack(
      children: <Widget>[
        new Image.network('http://s3.music.126.net/mobile-new/img/hot_music_bg_3x.jpg'),
        new Positioned(
          left: -10,
          top: 20,
          child: new Image.network('http://s3.music.126.net/mobile-new/img/index_icon_2x.png',
              width: 150,
              height: 65,
              fit: BoxFit.cover,
              alignment: Alignment.bottomLeft),
        ),
        new Positioned(
          left: 12,
          top: 90,
          child: new Text('更新日期：${updateTime.month}月${updateTime.day}日',
              style: new TextStyle(fontSize: 10, color: Colors.white)),
        )
      ],
    );
    if (mounted) {
      setState(() {
        list.add(stack);      
      });
    }

    for(var i = 0; i < res['playlist']['tracks'].length; i++) {
      var id = res['playlist']['tracks'][i]['id'];
      var name = res['playlist']['tracks'][i]['name'];
      var description = '';
      if (res['playlist']['tracks'][i]['alia'].length != 0) {
        description += '(';
        res['playlist']['tracks'][i]['alia'].forEach((item){
          description += item;
        });
        description += ')';
      }
      var artist = '';
      if (res['playlist']['tracks'][i]['ar'].length != 0) {
        res['playlist']['tracks'][i]['ar'].forEach((item) {
          artist += item['name'];
        });
      }
      var album = res['playlist']['tracks'][i]['al']['name'];
      var leading = new Container(
        width: 40,
        child: new Text('${i< 9 ? "0" + (i + 1).toString() : i + 1}', 
          textAlign: TextAlign.center,
          style: new TextStyle(
            fontSize: 16,
            color: i < 3 ? Colors.red : Colors.grey
          )
        )
      );
      var listTile = new ListSongItem(id: id, name: name, description: description, artist: artist, album: album, leading: leading);
      if (mounted) {
        setState(() {
          list.add(listTile);
          list.add(new Divider(height: 0));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new SingleChildScrollView(
      child: new Column(
        children: list,
      ),
    );
  }
}
