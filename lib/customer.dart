import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'login.dart';
import 'dart:convert';
import 'formcustomer.dart';

class Customer extends StatefulWidget {
  @override
  _CustomerState createState() => _CustomerState();
}

class _CustomerState extends State<Customer> {

  List data;
  TextEditingController nama = TextEditingController();

  @override
    void initState() {
      // TODO: implement initState
      super.initState();
      this.getData();
    }

  getData() async{
    setState(() {
      data = null;      
    });
    String token = "";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = await prefs.getString('token');

    var apiAmbil =
        Uri.http('dkurir.herokuapp.com', '/public/api/customer', {'cust_nama': nama.text});
    http.get(apiAmbil, headers: {
      HttpHeaders.authorizationHeader: "Token " + token
    }).then((http.Response response) {
      if(response.statusCode==401){
        logout(context);
      }else{
        dynamic customer = json.decode(response.body);
        this.setState(() {
          data = customer['customer'];
        });
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          backgroundColor: Colors.red[600],
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context){
              return FormCustomer();
            }));
          },
        ),
        appBar: AppBar(
          title: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: nama,
                  autofocus: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelStyle: TextStyle(color: Colors.white),
                    focusColor: Colors.white,
                    hintText: "Pencarian",
                    hintStyle: TextStyle(color: Colors.white),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    )
                  ),
                ),
              ),
              IconButton(icon: Icon(Icons.search), onPressed: (){
                this.getData();
              })
            ],
          ),
          backgroundColor: Colors.red[600],
          elevation: 0.0,
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            // borderRadius: BorderRadius.circular(25)
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: (data==null) ? SizedBox(
              width: double.infinity,
              child: Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red[600]),
                ),
              ),
            ) : (data.length==0) ? SizedBox(width: double.infinity, child: Align(alignment: Alignment.center, child: Image(image: AssetImage('assets/images/not_found.jpg')))) : ListView.builder(
                itemCount: data == null ? 0 : data.length,
                itemBuilder: (context, index) =>
                    listCustomer(context, index)),
          ),
        ));
  }

  Widget listCustomer(context, index) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Card(
          elevation: 5,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                    width: 2.0, color: Colors.red[600]),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 0.2 * MediaQuery.of(context).size.width,
                          child: Text("Nama")),
                        Expanded(child: Text(
                          " : "+data[index]['cust_nama']
                        ))
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 0.2 * MediaQuery.of(context).size.width,
                          child: Text("Alamat")),
                        Expanded(child: Text(
                          " : "+data[index]['cust_alamat']
                        ))
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 0.2 * MediaQuery.of(context).size.width,
                          child: Text("Kota")),
                        Expanded(child: Text(
                          " : "+data[index]['kec_nama']+" - "+data[index]['kota_nama']
                        ))
                      ],
                    ),
                  )
                ],
              ),
            )
          )),
    );
  }
}