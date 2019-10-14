import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:netease_music_wp/my_url.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key key}) : super(key: key);

  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Widget> list = [];

  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  TextEditingController _textEditingController = new TextEditingController();

  String searchKey = '';

  @override
  void initState() { 
    super.initState();
    var textField = new Form(
      key: _formKey,
      child: new Container(
          margin: new EdgeInsets.fromLTRB(10, 5, 10, 5),
          height: 30,
        child: new ClipRRect(
          borderRadius: new BorderRadius.all(new Radius.circular(20.0)),
          child: new TextFormField(
            controller: _textEditingController,
            cursorColor: Colors.black,
            cursorWidth: 1,
            decoration: new InputDecoration(
              contentPadding: new EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              hintText: '搜索歌曲、歌手、专辑',
              prefixIcon: new Icon(Icons.search, color: Colors.grey, size: 16.0),
              focusColor: Colors.black,
              hoverColor: Colors.black,
              filled: true,
              fillColor: new Color(0xffebecec),
              border: InputBorder.none,
              suffixIcon: new IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                icon: new Icon(Icons.clear, color: Colors.grey, size: 16.0),
                onPressed: () {
                  _formKey.currentState.reset();
                },
              )
            ),
            onSaved: (text) {
              setState(() {
                searchKey = text;
              });
            },
            onFieldSubmitted: (text) {
              _formKey.currentState.save();
              // TODO 搜索
            },
          ),
        ),
      ),
    );
    list.add(textField);
    
    getHotSearch();
  }

  getHotSearch() async {
    var tip = new Container(
      margin: new EdgeInsets.all(8.0),
      child: new Text('热门搜索', style: new TextStyle(fontSize: 12, color: Colors.grey)),
    );
    setState(() {
      list.add(tip);
    });
    
    List<Widget> _wrapList = [];
    Response response = await http.get('${MyUrl.prefix}/search/hot');
    Map<String, dynamic> res = json.decode(response.body);
    res['result']['hots'].forEach((item){
      var chip = new Chip(
        label: new Text('${item["first"]}'),
        labelStyle: new TextStyle(fontSize: 14, color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0.8,
      );
      _wrapList.add(chip);
    });
    var wrap = new Padding(
      padding: new EdgeInsets.only(left: 8, right: 8),
      child: new Wrap(
        spacing: 8.0,
        children: _wrapList
      ),
    );
    setState(() {
      list.add(wrap);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new SingleChildScrollView(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: list,
      ),
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}