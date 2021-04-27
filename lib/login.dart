import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'dart:convert';
import 'package:toast/toast.dart';

Future<void> logout(context) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if(await prefs.containsKey('token')){
    await prefs.remove('token');
    await prefs.remove('kurir');
  }
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (BuildContext context) {
      return Login();
    })
  );
}

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  void initState() {
    super.initState();
  }

  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  bool isRequestLogin = false;
  String loginText = "Login";

  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }

  Future<void> getToken() {
    setState(() {
      isRequestLogin = true;
      loginText = "Loading";
    });
    var apiLogin = Uri.http('dkurir.herokuapp.com', '/public/api/login');
    http.post(
      apiLogin,
      body: {
        'user_name': username.text,
        'user_password': password.text,
      },
    ).then((http.Response response) {
      setState(() {
        isRequestLogin = false;
        loginText = "Login";
      });
      Map<String, dynamic> result = json.decode(response.body);
      if (result['status'] == 'success') {
        this.saveToken(result['api_key'], result['kurir']);
      } else {
        showToast("Username dan Password salah !");
      }
    }).catchError((e) {
      print(e);
      showToast("Terjadi kesalahan! "+e.toString());
    });
  }

  saveToken(String token, String kurir) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('kurir', kurir);
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return Home();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                color: Colors.red[600],
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(100))),
            height: 160,
            width: 1 * MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Text("Login",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Ubuntu')),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Image(
                    image: AssetImage('assets/images/logo.jpg'),
                    width: 100,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                child: Container(
                  child: Card(
                    elevation: 5,
                    child: Container(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                child: TextField(
                                  controller: username,
                                  autofocus: true,
                                  decoration: InputDecoration(labelText: "Username", labelStyle: TextStyle(color: Colors.red[600]),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red[600] , width: 2.0),
                                    )
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                child: TextField(
                                  controller: password,
                                  obscureText : true,
                                  decoration: InputDecoration(labelText: "Password", labelStyle: TextStyle(color: Colors.red[600]),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red[600], width: 2.0),
                                    )
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: (isRequestLogin) ? Colors.red[100] : Colors.red[600], // background
                                      onPrimary: Colors.white, // foreground
                                    ),
                                    onPressed: (){
                                      this.getToken();
                                    },
                                    child: Text(loginText, style: TextStyle(color: Colors.white),),
                                  ),
                                )
                              ),
                            ],
                          ),
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(width: 2.0, color: Colors.red[600]),
                          ),
                        )),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: SizedBox(
              width: double.infinity,
              child: Container(
                color: Colors.red[600],
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text("Dikembangkan oleh ", style: TextStyle(
                      color: Colors.white
                    ),)),
                ),
              ),
            ),
          )
        ],
      )
    );
  }
}
