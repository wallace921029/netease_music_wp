import 'package:flutter/material.dart';
import 'package:netease_music_wp/color.dart';
import 'package:netease_music_wp/hot_list.dart';
import 'package:netease_music_wp/recommend_music.dart';
import 'package:netease_music_wp/search_page.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = new TabController(length: 3, vsync: this);
    _controller.index = 0;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('NetEase Music WP'),
        backgroundColor: NetEaseColor.red,
      ),
      body: new Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          new Container(
            height: 40,
            decoration: new BoxDecoration(
              border: new Border(bottom: new BorderSide(color: NetEaseColor.grey))
            ),
            child: new TabBar(
              tabs: <Widget>[
                new Text('推荐音乐'),
                new Text('热歌榜'),
                new Text('搜索'),
              ],
              controller: _controller,
              indicatorColor: NetEaseColor.red,
              labelColor: NetEaseColor.red,
              unselectedLabelColor: NetEaseColor.black,
              indicatorSize: TabBarIndicatorSize.label,
            ),
          ),
          new Expanded(
            child: new TabBarView(
              children: <Widget>[
                new RecommendMusic(),
                new HotList(),
                new SearchPage(),
              ],
              controller: _controller,
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
