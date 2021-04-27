import 'package:flutter/material.dart';
import 'login.dart';
import 'home.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<Widget> loadWidget() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(await prefs.containsKey('token')){
      return Home();
    }else{
      return Login();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: loadWidget(),
        builder: (BuildContext context, AsyncSnapshot<Widget> widget) {
          if (widget.hasData) {
            if (widget.data != null) {
              return widget.data;
            }else{
              return Home();
            }
          }else{
            return Home();
          }
        }
      )
    );
  }
}