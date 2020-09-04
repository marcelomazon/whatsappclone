import 'package:flutter/material.dart';
import 'package:whatsapp/Login.dart';
import 'Routes.dart';
import 'dart:io';
//import 'package:flutter_localizations/flutter_localizations.dart';
//import 'package:intl/intl.dart';

final ThemeData temaIOS = ThemeData(
    primaryColor: Colors.grey[200],
    accentColor: Color(0xff25D366)
);

final ThemeData temaPadrao = ThemeData(
    primaryColor: Color(0xff075E54),
    accentColor: Color(0xff25D366)
);

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: Platform.isIOS ? temaIOS : temaPadrao,
    home: Login(),
    //localizationsDelegates: [
    //  GlobalMaterialLocalizations.delegate,
    //  GlobalWidgetsLocalizations.delegate
    //],
    //supportedLocales: [const Locale('pt', 'BR')],
    onGenerateRoute: Routes.generator, // toda vez que uma rota é chamada
  ));
}
