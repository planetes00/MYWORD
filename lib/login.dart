import 'dart:async';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
            SizedBox(height: 80.0),
            Column(
              children: <Widget>[
                Image.asset('assets/diamond.png'),
                SizedBox(height: 16.0),
                Text('SHRINE'),
              ],
            ),
            SizedBox(height: 120.0),
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

class MyPage extends StatelessWidget {
  Future<Null> signOutWithGoogle() async {
    // Sign out with firebase
    await _auth.signOut();
    // Sign out with google
    await _googleSignIn.signOut();

  }

  @override
  Widget build(BuildContext context) {
    Widget titleSection = Container(
      padding: const EdgeInsets.fromLTRB(32.0, 0, 10.0, 32.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    user_text,
                    style: new TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.mail,
                      size: 20.0,
                    ),
                    Text(
                      usermail,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return MaterialApp(
      title: '21800140',
      home: Scaffold(
        body: ListView(
          children: [
            Stack(
              children: <Widget>[
                Container(
                  child: Image.network(
                    userphoto,
                    width: 600,
                    height: 240,
                    fit: BoxFit.cover,
                  ),

                ),
                Positioned(
                  left: 0.0,
                  top: 0.0,
                  child:  IconButton(
                    icon: Icon(
                      Icons.navigate_before,
                      semanticLabel: 'menu',
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/home');
                    },
                  ),
                ),
                Positioned(
                  right: 0.0,
                  top: 0.0,
                  child:  IconButton(
                    icon: Icon(
                      Icons.exit_to_app,
                      semanticLabel: 'menu',
                    ),
                    onPressed: () async {
                      await signOutWithGoogle();
                      Navigator.pushNamed(context, '/login');
                    },
                  ),
                ),
              ],
            ),
            titleSection,
          ],
        ),
      ),
    );
  }
}
