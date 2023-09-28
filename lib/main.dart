import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_flushbar/flutter_flushbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  //Declaration Part Starts
  TextEditingController txt = TextEditingController();
  TextEditingController rm = TextEditingController();
  List <File ?> _image = [];

  final pdf = pw.Document();
  //Declaration Part Ends

  // Picking Image From Gallery.
  void pickImageGallery() async
  {
    final picker = await ImagePicker().pickImage(source: ImageSource.gallery);
    if(picker != null)
        {
          setState(() {
            _image.add(File(picker.path));
          });
        }
  }

  // Picking Image From Camera
  void pickImageCamera() async
  {
    final picker = await ImagePicker().pickImage(source: ImageSource.camera);
    if(picker != null)
    {
      setState(() {
        _image.add(File(picker.path));
      });
    }
  }

  // Function To create pdf.
  void createPDF() async{

    for(var img in _image)
      {
        final image = pw.MemoryImage(img!.readAsBytesSync());

        pdf.addPage(pw.Page(pageFormat: PdfPageFormat.a4, build: (pw.Context context ){
          return pw.Center(child: pw.Image(image));
        }));
      }
  }

  //Function of Dialog box for saving pdf
  void saveDialog(){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        insetPadding: EdgeInsets.all(12),
          title: Text("Save As"),
          actions:[
            Container(
              child: Container(
                width: 600,
                child: TextField(
                  controller: txt,
                  decoration: InputDecoration(
                      labelText: "Enter File Name",
                      border: OutlineInputBorder()
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Center(child: TextButton(onPressed: (){
                if(txt.text.isNotEmpty)
                  {
                    savePDF();
                    txt.clear();
                    Navigator.pop(context);
                  }
              }, child: Text("Save", style: TextStyle(fontSize: 20, color: Colors.red)))),
            )
          ]
      );
    });
  }

  //Function for saving pdf
  void savePDF() async {
    try {
            final dir = Directory("/storage/emulated/0/Download");
            final file = File("${dir.path}/${txt.text}.pdf");
            if(await file.exists())
              {
                showPrintedMessage("Warning", "File name already exists");
              }
            else{
              await file.writeAsBytes(await pdf.save());
              showPrintedMessage("Success", "Your File is Saved Successfully in Your Downloads folder");
            }
    }
    catch(e){
      showPrintedMessage("error", e.toString());
    }
  }

  //Function for removing pages.
  void cleaning(){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        insetPadding: EdgeInsets.all(12),
        title: Text("Clear"),
        actions: [
          Container(
            child: TextField(
              controller: rm,
              decoration: InputDecoration(
                labelText: "Enter page number to remove",
                border: OutlineInputBorder()
              ),
            ),
          ),
          SizedBox(height: 30),
          Container(
            width: 500,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 10),
                child: TextButton(onPressed: (){
                  int  remove = int.parse(rm.text);
                  setState(() {
                    _image.remove(_image[remove-1]);
                  });
                  Navigator.pop(context);
                  rm.clear();
                  }, child: Text("clear", style: TextStyle(fontSize: 20, color: Colors.red))),
              ),

              SizedBox(width: 20),

              Container(
                margin: EdgeInsets.only(bottom: 10),
                child: TextButton(
                    onPressed: (){
                  setState(() {
                    _image.clear();
                  });
                  Navigator.pop(context);
                  }, child: Text("clear all", style: TextStyle(fontSize: 20, color: Colors.red))),
              )
            ],
          ),
          )
        ],
      );
    });
  }

  //Function of FlushBar for messages
  void showPrintedMessage(String title, String msg){
    Flushbar(
      title: title,
      message: msg,
      duration: Duration( seconds: 3),
      icon: Icon(Icons.info),
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 8,
        title: Text("PhotoDoc", style: TextStyle(fontFamily: "Times New Roman", color: Colors.black, fontSize: 28)),
        // centerTitle: true,
        actions: [
          IconButton(onPressed: (){

            if(_image.isNotEmpty)
              {
                saveDialog();
                createPDF();
              }
            else{
              showPrintedMessage("Failed", "Pick at least one image");
              }
            }, icon: Icon(Icons.picture_as_pdf, color: Colors.black,)),
          IconButton(onPressed: (){
            if(_image.isNotEmpty)
              {
                cleaning();
              }
            else{
              showPrintedMessage("Empty", "The Canvas is already empty");
            }
            }, icon: Icon(Icons.clear_all, color: Colors.black,)),
          // IconButton(onPressed: (){
          //   Navigator.push(context, MaterialPageRoute(builder: (context) => RecentFiles(increase: count, title: txt.text)));
          //  }, icon: Icon(Icons.history, color: Colors.black,))
        ],

      ),
      body: _image.isNotEmpty ? ListView.builder(itemBuilder: (context, index){
        return Container(
          margin: EdgeInsets.all(12),
          child: Image.file(_image[index]!),
        );
      }, itemCount: _image.length)
          : Center(child: Text("Pick An Image From Gallery", style: TextStyle(fontSize: 22, fontFamily: "Times New Roman", color: Colors.grey))),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: (){
          showModalBottomSheet(context: context, builder: (BuildContext context){
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.all(12),
                      padding: EdgeInsets.all(12),
                      child: IconButton(onPressed: (){
                        pickImageCamera();
                        Navigator.pop(context);
                        }, icon: Icon(Icons.camera_alt_outlined), iconSize: 40)),
                  Container(
                      margin: EdgeInsets.all(12),
                      padding: EdgeInsets.all(12),
                      child: IconButton(onPressed: (){
                        pickImageGallery();
                        Navigator.pop(context);
                        }, icon: Icon(Icons.photo_album), iconSize: 40, )),
                ],
              );
          });
          // pickImage();
        },
        child: Icon(Icons.add),
      ),

    );
  }
}

