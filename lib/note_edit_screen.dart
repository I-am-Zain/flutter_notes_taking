import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'constants.dart';
import 'delete_popup.dart';
import 'note.dart';
import 'note_provider.dart';
import 'note_view screen.dart';

class NoteEditScreen extends StatefulWidget {
  static const route = '/edit-note';
  @override
  _NoteEditScreenState createState() => _NoteEditScreenState();
}
class _NoteEditScreenState extends State {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  File _image;
  final picker = ImagePicker();

  bool firstTime = true;
  Note selectedNote;
  int id;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (firstTime) {
      id = ModalRoute.of(this.context).settings.arguments;
      if (id != null) {
        selectedNote =
            Provider.of<NoteProvider>(this.context, listen: false).getNote(id);
        titleController.text = selectedNote?.title;
        contentController.text = selectedNote?.content;
        if (selectedNote?.imagePath != null) {
          _image = File(selectedNote.imagePath);

        }
      }
      firstTime = false;
    }
  }

  @override
  void dispose(){
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        elevation: 0.7,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
        ),
        actions: [

          IconButton(

            icon: Icon(Icons.save),
            color: Colors.black,
            onPressed: () {
                if (titleController.text.isEmpty)
                  titleController.text = 'Untitled Note';
                saveNote();
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: 10.0, right: 5.0, top: 10.0, bottom: 5.0),
              child: TextField(
                controller: titleController,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                style: createTitle,
                decoration: InputDecoration(
                    hintText: 'Enter Note Title', border: InputBorder.none),
              ),
            ),
            if(_image != null)
              Container(
                padding: EdgeInsets.all(10.0),
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                height: 250.0,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        image: DecorationImage(
                          image: FileImage(_image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Container(
                          height: 30.0,
                          width: 30.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: InkWell(
                            onTap: () {
                              setState(
                                    () {
                                  _image = null;
                                },
                              );
                            },
                            child: Icon(
                              Icons.delete,
                              size: 16.0,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 10.0, right: 5.0, top: 10.0, bottom: 5.0),
              child: TextField(
                controller: contentController,
                maxLines: null,
                style: createContent,
                decoration: InputDecoration(
                  hintText: 'Enter Something...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        backgroundColor: Colors.red,
        animatedIcon: AnimatedIcons.menu_close,
        children: [
          SpeedDialChild(
              child: Icon(Icons.camera_alt_outlined),
            label: 'Take A Picture',
            onTap: () {
          getImage(ImageSource.camera);
          },
          ),
          SpeedDialChild(
            child: Icon(Icons.insert_photo_outlined),
            label: 'Insert From Gallery',
            onTap: () {
              getImage(ImageSource.gallery);
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.share_outlined),
            label: 'Share',
            onTap: share,
          ),
        ],
      )
      // FloatingActionButton(
      //   onPressed: () {
      //     if (titleController.text.isEmpty)
      //       titleController.text = 'Untitled Note';
      //     saveNote();
      //   },
      //   child: Icon(Icons.save),
      // ),
    );
  }


  void saveNote() {
    String title = titleController.text.trim();
    String content = contentController.text.trim();
    String imagePath = _image != null ? _image.path : null;
    if (id != null) {
      Provider.of<NoteProvider>(this.context, listen: false)
          .addOrUpdateNote(id, title, content, imagePath, EditMode.UPDATE);
      Navigator.of(this.context).pop();
    } else {
      int id = DateTime
          .now()
          .millisecondsSinceEpoch;
      Provider.of<NoteProvider>(this.context, listen: false)
          .addOrUpdateNote(id, title, content, imagePath, EditMode.ADD);
      Navigator.of(this.context)
          .pushReplacementNamed(NoteViewScreen.route, arguments: id);
    }
  }



  void _showDialog() {
    showDialog(
        context: this.context,
        builder: (context) {
          return DeletePopUp(selectedNote: selectedNote);
        });
  }

  void getImage(ImageSource imageSource) async {
    PickedFile imageFile = await picker.getImage(source: imageSource);
    if (imageFile == null) return;
    File tmpFile = File(imageFile.path);
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = basename(imageFile.path);
    tmpFile = await tmpFile.copy('${appDir.path}/$fileName');
    setState(() {
      _image = tmpFile;

    });
  }

  Future<void> share() async {
    await FlutterShare.share(
      title: 'Example share',

      text: 'Note Title: ${titleController.text} \n Note Content: ${contentController.text}',

      //linkUrl: ,
      chooserTitle: 'Where to Share the Notes',
    );
  }

}