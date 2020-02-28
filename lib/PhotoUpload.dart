import 'package:flutter/material.dart';
import 'package:flutter_blog_app/HomePage.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UploadPhotoPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _UploadPhotoPageState();
  }
}

class _UploadPhotoPageState extends State<UploadPhotoPage>{

  File sampleImage;
  String _myValue;
  String url;
  final formKey=new GlobalKey<FormState>();

  Future getImage() async{
    var tempImage=await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      sampleImage=tempImage;
    });
  }

  bool validateAndSave(){
    final form=formKey.currentState;
    if(form.validate()){
      form.save();
      return true;
    }
    else{
      return false;
    }
  }

  void UploadStatusImage() async{ 
    if(validateAndSave()){
      final StorageReference postImageRef=FirebaseStorage.instance.ref().child("Post Images");

      //creating unique key for image to avoid overlap
      var timeKey=new DateTime.now();
      final StorageUploadTask uploadTask = postImageRef.child(timeKey.toString()+ ".jpg").putFile(sampleImage);
      //saving in firebase
      var ImageUrl= await (await uploadTask.onComplete).ref.getDownloadURL(); //getting the url of the image which is the unique id of the image
      url=ImageUrl.toString();
      print("Image Url =" + url);

      //after saving go to home page
      gotoHomePage();
      saveToDatabase(url);
      
    }
  }

  void saveToDatabase(url){
    //give unique key while storing in database
    var dbTimeKey=new DateTime.now();
    var formatDate= new DateFormat('MMM d, yyyy'); // to get date
    var formatTime= new DateFormat('EEEE, hh:mm aaa'); //to get the exact time.
    
    String date=formatDate.format(dbTimeKey);
    String time=formatTime.format(dbTimeKey);
    DatabaseReference ref=FirebaseDatabase.instance.reference();
    var data={
      "image": url,
      "description":_myValue,
      "date": date,
      "time": time,
    };
    
    //storing to database
    ref.child("Posts").push().set(data);
  }

  void gotoHomePage(){
    Navigator.push(context, MaterialPageRoute(builder: (context)
      {
        return new HomePage();
      })
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Upload Image"),
        centerTitle:true
      ),
      body: new Center(
        child: sampleImage == null ? Text("select image"): enableUpload(),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Add Image',
        child: new Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget enableUpload(){
    return Container(
      child: new Form(
        key: formKey,
          child: Column(
            children: <Widget>[
              Image.file(sampleImage, height: 330.00, width: 660.00),
              SizedBox(height:15.0),
              TextFormField(
                decoration: new InputDecoration(labelText: "Description"),
                validator: (value){
                  return value.isEmpty ? 'Description is required' : null;
                },
                onSaved: (value){
                  return _myValue=value;
                },
              ),
              SizedBox(height:15.0),
              RaisedButton(
                elevation: 10.0,
                child: Text("Add new Post"),
                textColor: Colors.white,
                color: Colors.red,
                onPressed: UploadStatusImage,
              )
            ],
          ),
      ),
    );
  }
}