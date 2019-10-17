import 'package:flutter/material.dart';
import 'package:netease_music_wp/color.dart';

class MyLabel extends StatelessWidget {
  final String text;
  const MyLabel({Key key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: new EdgeInsets.fromLTRB(5, 0, 5, 0),
      margin: new EdgeInsets.only(left: 4, right: 4),
      alignment: Alignment.center,
      width: 45,
      height: 25,
      decoration: new BoxDecoration(
          borderRadius: new BorderRadius.all(new Radius.circular(100.0)),
          border: new Border.all(color: NetEaseColor.grey)),
      child: new Text(text,
          style: new TextStyle(fontSize: 10, color: Colors.black)),
    );
  }
}
