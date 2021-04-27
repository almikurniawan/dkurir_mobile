import 'dart:convert';
import 'dart:io';
import 'resume.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'formambil.dart';
import 'package:http/http.dart' as http;
import 'login.dart';

class Ambil extends StatefulWidget {
  @override
  _AmbilState createState() => _AmbilState();
}

class _AmbilState extends State<Ambil> {
  DateTime selectedDate = DateTime.now();
  List data;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.getData();
  }

  Future<void> getData() async{
    setState(() {
      data = null;      
    });
    String token = "";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = await prefs.getString('token');

    String tanggal = DateFormat.y().format(selectedDate) + "-" + DateFormat.M().format(selectedDate) + "-" + DateFormat.d().format(selectedDate);

    var apiAmbil =
        Uri.http('dkurir.herokuapp.com', '/public/api/ambilTgl/'+tanggal);
    http.get(apiAmbil, headers: {
      HttpHeaders.authorizationHeader: "Token " + token
    }).then((http.Response response) {
      if(response.statusCode==401){
        logout(context);
      }else{
        dynamic ambil = json.decode(response.body);
        this.setState(() {
          data = ambil['barang'];
        });
      }
    });
  }

  selectDate(BuildContext context) async{
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate){
      setState(() {
        selectedDate = picked;
      });
      this.getData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          backgroundColor: Colors.red[600],
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context){
              return Formambil();
            }));
          },
        ),
        appBar: AppBar(
          title: Text(
            "Ambil Barang",
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
        body: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 8),
                child: Text(
                  "Filter",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      // color: Colors.white,
                      fontFamily: 'Ubuntu'),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.red[600],
                      width: 3.0
                    )
                  )
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 2.0, color: Colors.red[600]),
                          ),
                        ),
                        child: Text(
                          DateFormat.d().format(selectedDate) + " " + DateFormat.MMMM().format(selectedDate) + " " + DateFormat.y().format(selectedDate),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              // color: Colors.white,
                              fontFamily: 'Ubuntu'),
                        ),
                      ),
                      IconButton(
                        icon:  const Icon(Icons.date_range), 
                        onPressed: (){
                          this.selectDate(context);
                        },
                        color: Colors.red[600],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
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
                            listAmbil(context, index)),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget listAmbil(context, index) {
    var curency = new NumberFormat.currency(locale: "id_ID",
      symbol: "Rp. ");
    return InkWell(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (BuildContext context) {
            return Resume(trx_id : data[index]['id_barang']);
          })
        );
      },
      child: Padding(
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(child: Container(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("No. Resi : "+data[index]['bar_kode'],style: TextStyle(fontWeight: FontWeight.bold),),
                        Text("Pengirim : "+data[index]['cust_nama']),
                        Text("Kec. "+(data[index]['kec_asal_nama']==null ? "" : data[index]['kec_asal_nama'])),
                        Text("Kota. "+data[index]['kota_asal_nama']),
                        Text("Harga B. "+curency.format((data[index]['bar_harga']==null) ? 0 : data[index]['bar_harga'])),
                        Text("Ongkir. "+curency.format((data[index]['bar_ongkir']==null) ? 0 : data[index]['bar_ongkir']))
                      ],
                    ),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(width: 1, color: Colors.red[600]),
                        )
                      ),
                    )),
                    Expanded(child: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Penerima : "+data[index]['bar_penerima']),
                          Text("Alamat. "+(data[index]['bar_alamat']==null ? "" : data[index]['bar_alamat'])),
                          Text("Kec."+(data[index]['kec_tujuan_nama']==null ? "" : data[index]['kec_tujuan_nama'])),
                          Text("Kota. "+data[index]['kota_tujuan_nama']),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
