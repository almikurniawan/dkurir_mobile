import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:toast/toast.dart';
import 'resume.dart';

class Formambil extends StatefulWidget {
  @override
  _FormambilState createState() => _FormambilState();
}

class _FormambilState extends State<Formambil> {
  List<DropdownMenuItem> kecamatan = [];
  List<DropdownMenuItem> customers = [];
  int selectedCustomer = 0;
  int selectedKecamatanTujuan = 0;

  TextEditingController penerima = TextEditingController();
  TextEditingController catatan = TextEditingController();
  TextEditingController harga_barang = TextEditingController();
  TextEditingController berat_barang = TextEditingController();
  TextEditingController alamat = TextEditingController();
  
  bool isRequestKirim = false;

  void initState() {
    super.initState();
    this.getReferensi();
  }

  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }

  Future<void> ambilBarang() async {
    if(selectedCustomer>0 && selectedKecamatanTujuan>0 && penerima.text!='' && catatan.text!='' && harga_barang.text!='' && berat_barang.text!='' && alamat.text!=''){
      setState(() {
        isRequestKirim = true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = await prefs.getString('token');
      var apiLogin = Uri.http('dkurir.herokuapp.com', '/public/api/barang');
      http.post(
        apiLogin,
        headers: {
          HttpHeaders.authorizationHeader: "Token " + token
        },
        body: {
          "bar_penerima": penerima.text,
          "bar_cust_id": selectedCustomer.toString(),
          "bar_kec_tujuan": selectedKecamatanTujuan.toString(),
          "bar_catatan": catatan.text,
          "bar_harga": harga_barang.text.replaceAll("Rp.","").replaceAll(".", "").trim(),
          "bar_berat": berat_barang.text,
          "bar_alamat": alamat.text
        },
      ).then((http.Response response) {
        Map<String, dynamic> result = json.decode(response.body);
        setState(() {
          isRequestKirim = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (BuildContext context) {
            return Resume(trx_id : result['id'] );
          })
        );
      });
    }else{
      showToast("Harap isi semua field.");
    }
  }

  Future<void> getReferensi() async {
    String token = "";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = await prefs.getString('token');

    var apiKecamatan =
        Uri.http('dkurir.herokuapp.com', '/public/api/kecamatan');
    http.get(apiKecamatan, headers: {
      HttpHeaders.authorizationHeader: "Token " + token
    }).then((http.Response response) {
      Map<String, dynamic> result = json.decode(response.body);
      result['kecamatan'].forEach((value) => {
        kecamatan.add(DropdownMenuItem(
          child: Text(value['kec_nama'] + " -> " + value['kota_nama']),
          value: value['kec_nama'] + " -> " + value['kota_nama']+"::"+value['id'].toString(),
        ))
      });
    });

    var apiCustomers = Uri.http('dkurir.herokuapp.com', '/public/api/customer');
    http.get(apiCustomers, headers: {
      HttpHeaders.authorizationHeader: "Token " + token
    }).then((http.Response response) {
      Map<String, dynamic> result = json.decode(response.body);
      result['customer'].forEach((value) => {
        customers.add(DropdownMenuItem(
          child: Text(value['cust_nama'] + " - " + value['cust_alamat']),
          value: value['cust_nama'] + " - " + value['cust_alamat']+"::"+value['cust_id'].toString(),
        ))
      });
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Form Ambil Barang",
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
                          Text("Masukan Detail Pengiriman"),
                          SearchableDropdown.single(
                            items: customers,
                            value: selectedCustomer,
                            hint: "Pilih Customer",
                            searchHint: "Pilih Customer",
                            onChanged: (value) {
                              if(value!=null){
                                List selected = value.split("::");
                                setState(() {
                                  selectedCustomer = int.parse(selected[1]);
                                });
                              }
                            },
                            isExpanded: true,
                          ),
                          SearchableDropdown.single(
                            items: kecamatan,
                            value: selectedKecamatanTujuan,
                            hint: "Pilih Kecamatan Tujuan",
                            searchHint: "Pilih Kecamatan Tujuan",
                            onChanged: (value) {
                              if(value!=null){
                                List selected = value.split("::");
                                setState(() {
                                  selectedKecamatanTujuan = int.parse(selected[1]);
                                });
                              }
                            },
                            isExpanded: true,
                          ),
                          TextField(
                            controller: penerima,
                            autofocus: true,
                            decoration: InputDecoration(
                                labelText: "Penerima",
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.red[600], width: 2.0),
                                ),
                                labelStyle: TextStyle(color: Colors.red[600])),
                            textAlign: TextAlign.start,
                          ),
                          TextField(
                            maxLines: 4,
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
                          TextField(
                            maxLines: 2,
                            controller: catatan,
                            autofocus: true,
                            decoration: InputDecoration(
                                labelText: "Catatan",
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.red[600], width: 2.0),
                                ),
                                labelStyle: TextStyle(color: Colors.red[600])),
                            textAlign: TextAlign.start,
                          ),
                          TextField(
                            controller: harga_barang,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              CurrencyTextInputFormatter(
                                locale: 'id',
                                decimalDigits: 0,
                                symbol: 'Rp. ',
                              )
                            ],
                            autofocus: true,
                            decoration: InputDecoration(
                                labelText: "Harga Barang",
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.red[600], width: 2.0),
                                ),
                                labelStyle: TextStyle(color: Colors.red[600])),
                            textAlign: TextAlign.start,
                          ),
                          TextField(
                            controller: berat_barang,
                            inputFormatters: [
                              WhitelistingTextInputFormatter.digitsOnly
                            ],
                            keyboardType: TextInputType.number,
                            autofocus: true,
                            decoration: InputDecoration(
                                labelText: "Berat Barang (Kg)",
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
                                (isRequestKirim) ? null : this.ambilBarang();
                              },
                              child: Text(
                                "Kirim",
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
}
