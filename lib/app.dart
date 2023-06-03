import 'package:flutter/material.dart';

import 'home.dart';
import 'login.dart';
import 'add.dart';
import 'model/product.dart';
import 'package:provider/provider.dart';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:get_it/get_it.dart';
import 'dart:async';

class ShrineApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(builder: (_) => locator<CRUDModel>()),
      ],
      child:MaterialApp(
        title: 'Shrine',
        home: HomePage(),
        initialRoute: '/login',
        routes: {
          '/home': (context) => HomePage(),
          //'/search': (context) => SearchPage(),
          '/add': (context) => addPage(),
          '/myPage': (context) => MyPage(),
        },
        onGenerateRoute: _getRoute,
      ),
    );
  }

  Route<dynamic> _getRoute(RouteSettings settings) {
    if (settings.name != '/login') {
      return null;
    }
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (BuildContext context) => LoginPage(),
      fullscreenDialog: true,
    );
  }
}