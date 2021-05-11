import 'package:flutter/material.dart';
import 'package:flutter_notes_taking/note_provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'list_item.dart';
import 'note_edit_screen.dart';
import 'note.dart';
class NoteListScreen extends StatefulWidget {
  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  bool isSearching=false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<NoteProvider>(context,listen:false).getNotes(),
      builder: (context,snapshot){
        if(snapshot.connectionState== ConnectionState.waiting){
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        else {
          if(snapshot.connectionState==ConnectionState.done){
            return Scaffold(
              body: Consumer<NoteProvider>(
                child: noNotesUI(context),
                builder: (context, noteprovider, child) =>
                noteprovider.items.length <= 0
                    ? child
                    : ListView.builder(
                  itemCount: noteprovider.items.length + 1,
                  itemBuilder: (context, index)
                  {
                    if (index == 0)
                    {
                      return header();
                    }
                    else
                    {
                      final i = index - 1;
                      final item = noteprovider.items[i];
                      return Dismissible(key: Key('$item'),
                          onDismissed: (direction){
                              setState(() {
                                Provider.of<NoteProvider>(context, listen: false)
                                    .deleteNote(item.id);
                               // item.removeAt(i);
                              });
                              Scaffold.of(context)
                                  .showSnackBar(SnackBar(content: Text("Deleted Successfully ")));
                          },
                          background: Container(color: Colors.red),
                          child: ListItem(
                            id: item.id,
                            title: item.title,
                            content: item.content,
                            imagePath: item.imagePath,
                            date: item.date,
                          ),
                      );

                    }
                  },
                ),
              ),
              floatingActionButton: SpeedDial(
                backgroundColor: Colors.red,
                animatedIcon: AnimatedIcons.menu_close,
                children: [
                  SpeedDialChild(
                    child: Icon(Icons.add),
                    label: 'Add note',
                    onTap: () {
                      goToNoteEditScreen(context);
                    },
                  ),
                  SpeedDialChild(
                    child: Icon(Icons.search),
                      label: 'search',
                      onTap: (){
                        setState(() {
                          this.isSearching=true;
                        });
                      }
                  ),

                ],
              )
            //   FloatingActionButton(
            //
            //     onPressed:(){
            //       goToNoteEditScreen(context);
            // },
            //   child: Icon(Icons.add),
            // ),
            );
          }
        }
        return Container();
      }

    );
  }

  Widget header() {
   return Container(
        decoration: BoxDecoration(
          color: headerColor,
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(75.0),
            //bottomLeft: Radius.circular(75.0),
          ),
        ),
        height: 150,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text(
              'ZaYnee\'S',
              style: headerRideStyle,
            ),
            Text(
              'NOTES',
              style: headerNotesStyle,
            ),
          ],
        ),
      );
  }

  Widget noNotesUI(BuildContext context) {
    return ListView(
      children: [
        header(),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Image.asset(
                'crying_emoji.png',
                fit: BoxFit.cover,
                width: 200,
                height: 200,
              ),
            ),
            RichText(
              text: TextSpan(
                style: noNotesStyle,
                children: [
                  TextSpan(text: ' There is no note available\nTap on "'),
                  TextSpan(
                      text: '+',
                      style: boldPlus,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          goToNoteEditScreen(context);
                        }),
                  TextSpan(text: '" to add new note'),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }

  void goToNoteEditScreen(BuildContext context) {
    Navigator.of(context).pushNamed(NoteEditScreen.route);
  }
}
