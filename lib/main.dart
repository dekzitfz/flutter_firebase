import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

void main() {
  runApp(new MaterialApp(
    home: new MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _State();
  }
}

class _State extends State<MyApp> {

  String _status;

  @override
  void initState() {
    super.initState();
    _status = 'Not Authenticated';
  }

  void _handleGoogleLogin() {
    _signWithGoogle()
        .then((FirebaseUser user){
          setState(() {
            _status = 'Loged as ${user.email}';
          });
        })
        .catchError((e){
          print(e.toString());
          setState(() {
            _status = 'Login Failed';
          });
        });
  }

  Future<FirebaseUser> _signWithGoogle() async {
    final GoogleSignInAccount googleAccount = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken
    );

    final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
    return user;
  }

  void _loginAnonymously() async {
    FirebaseUser user = (await _auth.signInAnonymously()).user;
    if(user != null && user.isAnonymous){
      setState(() {
        _status = 'Signed In as anonymous';
      });
    }else{
      setState(() {
        _status = 'Sign In Failed!';
      });
    }
  }

  void _logout() async {
    await _auth.signOut();
    setState(() {
      _status = 'Signed Out';
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new  Text("Flutter Firebase"),
      ),
      body: new Container(
        padding: new EdgeInsets.all(10.0),
        child: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Text("Status: $_status"),
              new RaisedButton(
                onPressed: _logout,
                child: new Text("Logout"),
              ),
              new RaisedButton(
                onPressed: _loginAnonymously,
                child: new Text("Login as anon"),
              ),
              new RaisedButton(
                onPressed: _handleGoogleLogin,
                child: new Text("Login with google"),
              )
            ],
          ),
        ),
      ),
    );
  }

}