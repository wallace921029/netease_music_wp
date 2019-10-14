import 'package:flutter/material.dart';
import 'play_music.dart';

class ListSongItem extends StatefulWidget {
  final num id;
  final String name;
  final String description;
  final String artist;
  final String album;
  final Widget leading;
  ListSongItem(
      {Key key,
      this.id,
      this.name,
      this.description,
      this.artist,
      this.album,
      this.leading})
      : super(key: key);

  _ListSongItemState createState() => _ListSongItemState();
}

class _ListSongItemState extends State<ListSongItem> {
  @override
  Widget build(BuildContext context) {
    return new ListTile(
      dense: true,
      contentPadding: new EdgeInsets.fromLTRB(8, 0, 8, 0),
      leading: widget.leading != null ? widget.leading : null,
      title: new RichText(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        text: new TextSpan(children: <TextSpan>[
          new TextSpan(
              text: widget.name,
              style: new TextStyle(fontSize: 16, color: Colors.black)),
          new TextSpan(
              text: widget.description,
              style: new TextStyle(fontSize: 16, color: Colors.grey))
        ]),
      ),
      subtitle: new Text('${widget.artist} - ${widget.album}',
          maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: new IconButton(
        icon: new Icon(Icons.play_circle_filled),
        onPressed: () {
          Navigator.of(context)
              .push(new MaterialPageRoute(builder: (buildContext) {
            return new PlayMusic(id: widget.id);
          }));
        },
      ),
    );
  }
}
