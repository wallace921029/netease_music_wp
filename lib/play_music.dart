import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:netease_music_wp/color.dart';
import 'package:netease_music_wp/my_url.dart';

class PlayMusic extends StatefulWidget {
  final int id;

  PlayMusic({Key key, this.id}) : super(key: key);

  _PlayMusicState createState() => _PlayMusicState();
}

class _PlayMusicState extends State<PlayMusic>
    with SingleTickerProviderStateMixin {
  String name = '';
  String albumPictureUrl;
  String songUrl;
  int songDurationValue;
  String songDurationString = '00:00';
  Duration currentDuration;
  String currentDurationString = '00:00';
  Widget controllerButton;
  double sliderValue = 0;
  List<Widget> lyricsList = [];

  AudioPlayer audioPlayer;

  AnimationController _animationController;
  Animation _animation;

  @override
  void initState() {
    audioPlayer = new AudioPlayer();

    audioPlayer.onAudioPositionChanged.listen((Duration duration) {
      var persent = double.parse(
          ((duration.inMilliseconds / songDurationValue) * 100)
              .toStringAsFixed(0));
      var minutes = duration.inMinutes < 10
          ? '0' + duration.inMinutes.toString()
          : duration.inMinutes.toString();
      var seconds = duration.inSeconds % 60 < 10
          ? '0' + (duration.inSeconds % 60).toString()
          : (duration.inSeconds % 60).toString();
      setState(() {
        currentDuration = duration;
        currentDurationString = '$minutes:$seconds';
        sliderValue = persent;
      });
    });

    audioPlayer.onPlayerStateChanged.listen((state) {
      switch (state) {
        case AudioPlayerState.PLAYING:
          _animationController.repeat(min: 0.0, max: 1.0, reverse: false);
          setState(() {
            controllerButton = new IconButton(
              icon: new Icon(Icons.pause),
              iconSize: 40,
              onPressed: () {
                audioPlayer.pause();
              },
            );
          });
          break;
        default:
          _animationController.stop();
          setState(() {
            controllerButton = new IconButton(
              icon: new Icon(Icons.play_arrow),
              iconSize: 40,
              onPressed: () {
                audioPlayer.resume();
              },
            );
          });
          break;
      }
    });

    _animationController = new AnimationController(
        duration: new Duration(milliseconds: 30000), vsync: this);
    _animation = new Tween(begin: 0.0, end: 1.0).animate(new CurvedAnimation(
        parent: _animationController, curve: Curves.linear));
    _animationController.repeat(min: 0.0, max: 1.0, reverse: false);

    getSongDetails();
    getSongUrl();
    getLyrics();
    super.initState();
  }

  getSongDetails() async {
    Response response =
        await http.get('${MyUrl.prefix}/song/detail?ids=${widget.id}');
    Map<String, dynamic> res = json.decode(response.body);
    setState(() {
      name = res['songs'][0]['name'];
      albumPictureUrl = res['songs'][0]['al']['picUrl'];
    });
  }

  getSongUrl() async {
    Response response =
        await http.get('${MyUrl.prefix}/song/url?id=${widget.id}');
    Map<String, dynamic> res = json.decode(response.body);
    setState(() {
      songUrl = res['data'][0]['url'];
    });
    await audioPlayer.setUrl(songUrl);
    int duration = await audioPlayer.getDuration();
    print('duration: $duration');
    var minutes = new Duration(milliseconds: duration).inMinutes < 10
        ? '0' + new Duration(milliseconds: duration).inMinutes.toString()
        : new Duration(milliseconds: duration).inMinutes.toString();
    var seconds = new Duration(milliseconds: duration).inSeconds % 60 < 10
        ? '0' + (new Duration(milliseconds: duration).inSeconds % 60).toString()
        : (new Duration(milliseconds: duration).inSeconds % 60).toString();
    setState(() {
      songDurationValue = duration;
      songDurationString = '$minutes:$seconds';
    });

    audioPlayer.resume();
  }

  getLyrics() async {
    Response response = await http.get('${MyUrl.prefix}/lyric?id=${widget.id}');
    Map<String, dynamic> res = json.decode(response.body);
    var lyric = res['lrc']['lyric'];

    List<String> lyrics = lyric.split('\n');
    List<Text> _lyricsList = [];
    lyrics.forEach((item){
      if (item.isNotEmpty) {
        item = item.replaceRange(0, 11, '');
      }
      _lyricsList.add(new Text(item, textAlign: TextAlign.center, style: new TextStyle(fontSize: 14.0, color: Colors.grey)));
    });
    setState(() {
      lyricsList = _lyricsList;
    });
  }

  playMusic() async {
    await audioPlayer.resume();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('$name'),
        backgroundColor: NetEaseColor.red,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back_ios),
          onPressed: () async {
            await audioPlayer.stop();
            await audioPlayer.release();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: new SafeArea(
        child: new Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            new Container(
                margin: new EdgeInsets.only(top: 20, bottom: 20),
                alignment: Alignment.center,
                child: new RotationTransition(
                  turns: _animation,
                  child: new ClipOval(
                    child: albumPictureUrl == null
                        ? null
                        : new Image.network(albumPictureUrl,
                            width: MediaQuery.of(context).size.width / 2,
                            height: MediaQuery.of(context).size.width / 2),
                  ),
                )),
            new Expanded(
              child: new ListView(
                children: lyricsList,
              ),
            ),
            new Divider(height: 0),
            new Row(
              children: <Widget>[
                new Padding(
                    padding: new EdgeInsets.only(left: 20, top: 20),
                    child: new Text(currentDurationString,
                        style: new TextStyle(color: Colors.grey))),
                new Expanded(
                  child: new Padding(
                      padding:
                          new EdgeInsets.only(left: 20, top: 20, right: 20),
                      child: new Text(name,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: new TextStyle(
                              color: Colors.grey, fontSize: 14.0))),
                ),
                new Padding(
                  padding: new EdgeInsets.only(right: 20, top: 20),
                  child: new Text(songDurationString,
                      textAlign: TextAlign.right,
                      style: new TextStyle(color: Colors.grey)),
                )
              ],
            ),
            new Slider(
              min: 0,
              max: 100,
              value: sliderValue,
              activeColor: NetEaseColor.red,
              inactiveColor: NetEaseColor.grey,
              onChanged: (double value) {
                var v = value.toInt();
                setState(() {
                  sliderValue = v.toDouble();
                });
                audioPlayer.seek(
                    new Duration(milliseconds: songDurationValue * v ~/ 100));
              },
            ),
            new Container(
              child: controllerButton,
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
