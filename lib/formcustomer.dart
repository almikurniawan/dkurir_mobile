import 'dart:convert';
import 'dart:io';
import 'package:dkurir/customer.dart';

import 'login.dart';
import 'package:flutter/material.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'customer.dart';
import 'package:toast/toast.dart';

class FormCustomer extends StatefulWidget {
  @override
  _FormCustomerState createState() => _FormCustomerState();
}

class _FormCustomerState extends State<FormCustomer> {
  List<DropdownMenuItem> kecamatan = [];
  int selectedKecamatan = 0;
  bool isRequestKirim = false;

  TextEditingController nama = TextEditingController();
  TextEditingController alamat = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.getReferensi();
  }

  Future<void> getReferensi() async{
    String token = "";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = await prefs.getString('token');

    var apiKecamatan =
        Uri.http('dkurir.herokuapp.com', '/public/api/kecamatan');
    http.get(apiKecamatan, headers: {
      HttpHeaders.authorizationHeader: "Token " + token
    }).then((http.Response response) {
      if(response.statusCode==401){
        logout(context);
      }else{
        Map<String, dynamic> result = json.decode(response.body);
        result['kecamatan'].forEach((value) => {
          kecamatan.add(DropdownMenuItem(
            child: Text(value['kec_nama'] + " -> " + value['kota_nama']),
            value: value['kec_nama'] + " -> " + value['kota_nama']+"::"+value['id'].toString(),
          ))
        });
        setState(() {});
      }
    });
  }

  Future<void> simpan() async{
    if(alamat.text!='' && nama.text!='' && selectedKecamatan>0){
      setState(() {
        isRequestKirim = true;
      });
      String token = "";
      SharedPreferences prefs = await SharedPreferences.getInstance();
      token = await prefs.getString('token');
      var apiCustomerAdd = Uri.http('dkurir.herokuapp.com', '/public/api/customer');
      http.post(
        apiCustomerAdd,
        headers: {
          HttpHeaders.authorizationHeader: "Token " + token
        },
        body: {
          "cust_nama": nama.text,
          "cust_alamat": alamat.text,
          "cust_kec_id": selectedKecamatan.toString()
        },
      ).then((http.Response response) {
        Map<String, dynamic> result = json.decode(response.body);
        setState(() {
          isRequestKirim = false;
        });
        Navigator.pop(
          context,
          MaterialPageRoute(builder: (BuildContext context) {
            return Customer();
          })
        );
      });
    }else{
      showToast("Harap isi semua field.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Form Customer",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Ubuntu',
          ),
        ),
        backgroundColor: Colors.red[600],
        elevation: 0.0,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 2.0, color: Colors.red[600]),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Masukan Identitas Customer"),
                          SearchableDropdown.single(
                            items: kecamatan,
                            value: selectedKecamatan,
                            hint: "Pilih Kecamatan",
                            searchHint: "Pilih Kecamatan",
                            onChanged: (value) {
                              if(value!=null){
                                List selected = value.split("::");
                                setState(() {
                                  selectedKecamatan = int.parse(selected[1]);
                                });
                              }
                            },
                            isExpanded: true,
                          ),
                          TextField(
                            controller: nama,
                            autofocus: true,
                            decoration: InputDecoration(
                                labelText: "Nama",
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.red[600], width: 2.0),
                                ),
                                labelStyle: TextStyle(color: Colors.red[600])),
                            textAlign: TextAlign.start,
                          ),
                          TextField(
                            controller: alamat,
                            autofocus: true,
                            decoration: InputDecoration(                              
                                labelText: "Alamat",
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.red[600], width: 2.0),
                                ),
                                labelStyle: TextStyle(color: Colors.red[600])),
                            textAlign: TextAlign.start,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: (isRequestKirim)
                                    ? Colors.red[100]
                                    : Colors.red[600], // background
                                onPrimary: Colors.white, // foreground
                              ),
                              onPressed: () {
                                (isRequestKirim) ? null : this.simpan();
                              },
                              child: Text(
                                "Simpan",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }
}