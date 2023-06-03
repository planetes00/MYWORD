import 'dart:async';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'model/product.dart';


final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn= new GoogleSignIn();

GoogleSignIn _googleSignIn = new GoogleSignIn(
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

String user_text = null;
String usermail=null;
String userphoto=null;


class _LoginPageState extends State<LoginPage> {
  Future<String> _testSignInAnonymously() async {
    final FirebaseUser user = (await _auth.signInAnonymously()).user;

    assert(user != null);
    assert(user.isAnonymous);
    assert(!user.isEmailVerified);
    assert(await user.getIdToken() != null);

    assert(user.providerData.length == 1);
    assert(user.providerData[0].providerId == 'firebase');
    assert(user.providerData[0].uid != null);
    assert(user.providerData[0].displayName == null);
    assert(user.providerData[0].photoUrl == null);
    assert(user.providerData[0].email == null);
    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    print(currentUser.uid);
    setState(() { user_text=currentUser.uid; });
    usermail='Anonymous';
    userphoto='http://handong.edu/site/handong/res/img/logo.png';
    Navigator.pushNamed(context, '/home');
    return 'signInAnonymously succeeded: $user';
  }

  Future<String> _testSignInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final AuthResult authResult = await _auth.signInWithCredential(credential);
    FirebaseUser user = authResult.user;
    assert(user.email != null);
    usermail=user.email;
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);
    userphoto=user.photoUrl;
    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    print(currentUser.uid);
    setState(() { user_text=currentUser.uid; });
    Navigator.pushNamed(context, '/home');
    return 'signInWithGoogle succeeded: $user';
  }

  Future<Null> get_uid() async{
    final FirebaseUser currentUser = await _auth.currentUser();
    print(currentUser);
    setState(() { user_text=currentUser.uid; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            SizedBox(height: 300.0),
            Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text('    내가'
                  ,textAlign: TextAlign.left, style: TextStyle(fontSize: 30.0,),),
                SizedBox(height: 20.0),
                Text('    단어 외우려고 만든'
                  ,textAlign: TextAlign.left, style: TextStyle(fontSize: 30.0,),),
                SizedBox(height: 20.0),
                Text('    어플',textAlign: TextAlign.left, style: TextStyle(fontSize: 30.0,),)

              ],
            ),
            SizedBox(height: 250.0),
          new RaisedButton(
            child: new Text("Sign Google"),
            color: Colors.redAccent,
            onPressed: _testSignInWithGoogle,
          ),
            SizedBox(height: 10.0),
          new RaisedButton(
            child: new Text("Guest"),
            color: Colors.blueAccent,
            onPressed:
              _testSignInAnonymously,
          ),
          ],
        ),

      ),
    );
  }
}

final List<Product> items=[];

class MyPage extends StatefulWidget {
MyPage({Key key}) : super(key: key);

@override
MyPageState createState() {
  return MyPageState();
}
}

class MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    final title = '쓰면서 외우기';

    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.navigate_before,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
          title: Text(title),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.menu ,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/myPage');
              },
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];

            return Dismissible(
              key: Key(item.word),
              onDismissed: (direction) {
                setState(() {
                  items.removeAt(index);
                });

              },
              child: ListTile(
                  title: Text(item.word+ " "+item.mean,textAlign: TextAlign.right)),

            );
          },
        ),
      ),
    );
  }
}

class askPage extends StatelessWidget{
  Widget build(BuildContext context) {
    final title = '쓰면서 외우기';

    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.navigate_before,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
          title: Text(title),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.playlist_add_check,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/ans');
              },
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
              return ListTile(title: Text(item.word,textAlign: TextAlign.right)
            );
          },
        ),
      ),
    );
  }
}