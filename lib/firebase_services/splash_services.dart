import 'dart:async';

import 'package:fibauth/ui/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../ui/posts/post_screen.dart';

class SplashServices{
  void isLogin(BuildContext context){
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    if(user!=null){
      Timer(Duration(seconds: 3),
              ()=> Navigator.push(context, MaterialPageRoute(builder: (context) =>const PostScreen()))
      );
    }else{
      Timer(Duration(seconds: 3),
              ()=> Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()))
      );
    }
  }
}