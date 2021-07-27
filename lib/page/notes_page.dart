import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:example/db/notes_database.dart';
import 'package:example/model/note.dart';
import 'package:example/page/edit_note_page.dart';
import 'package:example/page/note_detail_page.dart';
import 'package:example/widget/note_card_widget.dart';
import 'package:flutter_offline/flutter_offline.dart';

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late List<Note> notes;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshNotes();
  }

  @override
  void dispose() {
    NotesDatabase.instance.close();

    super.dispose();
  }

  Future refreshNotes() async {
    setState(() => isLoading = true);

    this.notes = await NotesDatabase.instance.readAllNotes();

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            'Notes',
            style: TextStyle(fontSize: 24),
          ),
          actions: [Icon(Icons.search), SizedBox(width: 12)],
        ),
        body: OfflineBuilder(
            connectivityBuilder: (
              BuildContext context,
              ConnectivityResult connectivity,
              Widget child,
            ) {
              final bool connected = connectivity != ConnectivityResult.none;
              return new Stack(fit: StackFit.expand, children: [
                Positioned(
                  height: 24.0,
                  left: 0.0,
                  right: 0.0,
                  child: Container(
                    color: connected ? Color(0xFF00EE44) : Color(0xFFEE4400),
                    child: Center(
                      child: Text("${connected ? 'ONLINE' : 'OFFLINE'}"),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Center(
                      child: isLoading
                          ? CircularProgressIndicator()
                          : notes.isEmpty
                              ? Text(
                                  'No Notes',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 24),
                                )
                              : buildNotes()),
                )
              ]);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(
                  'There are no bottons to push :)',
                ),
                new Text(
                  'Just turn off your internet.',
                ),
              ],
            )),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          child: Icon(Icons.add),
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => AddEditNotePage()),
            );

            refreshNotes();
          },
        ),
      );

  Widget buildNotes() => StaggeredGridView.countBuilder(
        padding: EdgeInsets.all(8),
        itemCount: notes.length,
        staggeredTileBuilder: (index) => StaggeredTile.fit(2),
        crossAxisCount: 4,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        itemBuilder: (context, index) {
          final note = notes[index];

          return GestureDetector(
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => NoteDetailPage(noteId: note.id!),
              ));

              refreshNotes();
            },
            child: NoteCardWidget(note: note, index: index),
          );
        },
      );
}
