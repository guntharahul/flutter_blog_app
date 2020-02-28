import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blog_app/PhotoUpload.dart';
import 'Authentication.dart';
import 'Posts.dart';
import 'package:firebase_database/firebase_database.dart';

class HomePage extends StatefulWidget {
  HomePage({this.auth, this.onSignedOut});
  final AuthImplemetation auth;
  final VoidCallback onSignedOut;

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {

  //getting all the posts from database
  List<Posts> postsList=[];

  @override
  void initState() {
    super.initState();
    //get data from database when user visits homepage
    DatabaseReference postsRef=FirebaseDatabase.instance.reference().child("Posts");
    postsRef.once().then((DataSnapshot snap){
      //getting unique id of posts in database
      var KEYS = snap.value.keys;
      //getting values from database in each unique ID
      var DATA = snap.value;

      postsList.clear();
      for(var individualKey in KEYS){
        Posts posts = new Posts(
          DATA[individualKey]['image'],
          DATA[individualKey]['description'],
          DATA[individualKey]['date'],
          DATA[individualKey]['time'],
        );
        postsList.add(posts);
      }
      setState(() {
        print('Lenght: $postsList.length');
      });
    });
  }

  void _logoutUser() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print("Error = " + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: Center(
        child: Text('Home'),
      )),
      body: new Container(
        child: postsList.length == 0 ? new Text("No Blog Posts") : new ListView.builder(
          itemCount: postsList.length,
          itemBuilder: (_, index){
            return PostsUI(postsList[index].image,postsList[index].description,postsList[index].date,postsList[index].time);
          }
        ),
      ),
      bottomNavigationBar: new BottomAppBar(
        color: Colors.red,
        child: new Container(
          margin: const EdgeInsets.only(left: 70.0, right: 70.0),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              new IconButton(
                icon: new Icon(Icons.local_car_wash),
                iconSize: 50,
                color: Colors.white,
                onPressed: _logoutUser,
              ),
              new IconButton(
                icon: new Icon(Icons.add_a_photo),
                iconSize: 50,
                color: Colors.white,
                onPressed: (){
                  Navigator.push
                  (
                    context,
                    MaterialPageRoute(builder: (context){
                      return new UploadPhotoPage();
                    })
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
  Widget PostsUI(String image, String description, String date, String time){
    return new Card(
      elevation: 10.0,
      margin: EdgeInsets.all(15.0),
      child: new Container(
        padding: new EdgeInsets.all(14.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text(
                  date,
                  style: Theme.of(context).textTheme.subtitle,
                  textAlign: TextAlign.center
                ),
                new Text(
                  time,
                  style: Theme.of(context).textTheme.subtitle,
                  textAlign: TextAlign.center
                ),
              ],
            ),
            SizedBox(height:10.0,),
            new Image.network(image,fit:BoxFit.cover),
            SizedBox(height:10.0,),
            new Text(
                  description,
                  style: Theme.of(context).textTheme.subhead,
                  textAlign: TextAlign.center
                ),
          ],
        ),
      ),
    );
  }
}
