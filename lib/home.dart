import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ambil.dart';
import 'antar.dart';
import 'login.dart';
import 'customer.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String nama = "";

  Future<void> getSession() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(await prefs.containsKey('kurir')){
      setState(() {
        nama = prefs.getString("kurir");
      });
    }
  }

  void initState() {
    // TODO: implement initState
    super.initState();
    this.getSession();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.red[600],
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, top:20, right: 8.0 ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image(
                        image: AssetImage('assets/images/logo.jpg'),
                          width: 100,
                          fit: BoxFit.fitWidth,
                      ),
                      GestureDetector(
                        onTap: (){
                          this.logout(context);
                        },
                        child: Row(
                          children: [
                            Text("Logout", style: TextStyle(color: Colors.white),),
                            IconButton(
                              icon: const Icon(Icons.logout),
                              tooltip: 'Logout',
                              color: Colors.white,
                              onPressed: () {
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Text("Hallo " + nama, style: TextStyle(
                    color: Colors.white70,
                    fontSize: 20,
                    fontFamily: 'Ubuntu'
                  ),),
                  Text("Selamat bekerja, antarkan barang pelanggan dengan baik dan selamat.", style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontFamily: 'Ubuntu'
                  ),)
                ],
              ),
            ),
          ),
          Positioned(
            top: 150,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                color: Colors.white
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text("Menu Kurir", style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Ubuntu',
                        fontWeight: FontWeight.bold,
                        color: Colors.red[800]
                      ),),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context){
                                  return Ambil();
                                }));
                              },
                              child: Container(
                                // height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.deepOrange[400],
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    spreadRadius: 3,
                                    blurRadius: 6,
                                    offset: Offset(0, 3), 
                                  )]
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Image(
                                        image: AssetImage('assets/images/ambil.png'),
                                            width: 130,
                                            fit: BoxFit.fitWidth,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Text("Ambil Barang", style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                          fontFamily: 'Ubuntu',
                                        ),),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context){
                                  return Antar();
                                }));
                              },
                              child: Container(
                                // height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.deepOrange[400],
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    spreadRadius: 3,
                                    blurRadius: 6,
                                    offset: Offset(0, 3), 
                                  )]
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Image(
                                        image: AssetImage('assets/images/antar.png'),
                                            width: 130,
                                            fit: BoxFit.fitWidth,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Text("Antar Barang", style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                          fontFamily: 'Ubuntu',
                                        ),),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context){
                                  return Customer();
                                }));
                              },
                              child: Container(
                                // height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.deepOrange[400],
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    spreadRadius: 3,
                                    blurRadius: 6,
                                    offset: Offset(0, 3), 
                                  )]
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Image(
                                        image: AssetImage('assets/images/customer.png'),
                                            width: 100,
                                            fit: BoxFit.fitWidth,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Text("Master Customer", style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                          fontFamily: 'Ubuntu',
                                        ),),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      )
    );
  }
}