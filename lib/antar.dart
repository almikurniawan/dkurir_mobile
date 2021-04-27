import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:toast/toast.dart';
import 'login.dart';

class Antar extends StatefulWidget {
  @override
  _AntarState createState() => _AntarState();
}

class _AntarState extends State<Antar> {
  List data_today;
  List data_pending;
  List data_terkirim;
  bool isSort = false;
  int lastNumber = 1;
  dynamic data_urutan;

  int selected_item = 0;
  TextEditingController alasan_pending = TextEditingController();
  
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.getData();
    this.getPending();
    this.getTerkirim();
  }

  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }

  void giveNumber(index){
    if(data_today[index]['urutan']==null){
      data_today[index]['urutan'] = lastNumber.toString();
      setState(() {
        lastNumber++;
      });
    }else{
      data_today[index]['urutan'] = null;
      setState(() {
        lastNumber--;
      });
    }
  }

  Future<void> saveNumber() async{
    Map<String, dynamic> data_to_send = Map<String, dynamic>();
    data_today.forEach((element) {
      data_to_send[element['id_barang'].toString()] = (element['urutan']==null ? "kosong" : element['urutan'].toString());
    });

    String token = "";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = await prefs.getString('token');
    setState(() {
      isSort = false;
      lastNumber = 1;
      data_today = null;
    });

    var apiSaveUrutan = Uri.http('dkurir.herokuapp.com', '/public/api/saveUrutan');

    http.post(
        apiSaveUrutan,
        headers: {
          HttpHeaders.authorizationHeader: "Token " + token
        },
        body: {
          "data": json.encode(data_to_send)
        }
      ).then((http.Response response) {
        this.getData();
      });
  }

  Future<void> getData() async{
    setState(() {
      data_today = null;
    });
    String token = "";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = await prefs.getString('token');

    var apiToday =
        Uri.http('dkurir.herokuapp.com', '/public/api/antarBarang/');
    http.get(apiToday, headers: {
      HttpHeaders.authorizationHeader: "Token " + token
    }).then((http.Response response) {
      if(response.statusCode==401){
        logout(context);
      }else{
        dynamic antar = json.decode(response.body);
        this.setState(() {
          data_today = antar['barang'];
        });
      }
    });
  }

  Future<void> getPending() async{
    setState(() {
      data_pending = null;
    });
    String token = "";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = await prefs.getString('token');

    var apiToday =
        Uri.http('dkurir.herokuapp.com', '/public/api/antarBarangPending/');
    http.get(apiToday, headers: {
      HttpHeaders.authorizationHeader: "Token " + token
    }).then((http.Response response) {
      if(response.statusCode==401){
        logout(context);
      }else{
        dynamic antar = json.decode(response.body);
        this.setState(() {
          data_pending = antar['barang'];
        });
      }
    });
  }

  Future<void> getTerkirim() async{
    // ambilTglTerkirim
    setState(() {
      data_terkirim= null;
    });
    String token = "";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = await prefs.getString('token');
    String tanggal = DateFormat.y().format(selectedDate) + "-" + DateFormat.M().format(selectedDate) + "-" + DateFormat.d().format(selectedDate);

    var apiToday =
        Uri.http('dkurir.herokuapp.com', '/public/api/ambilTglTerkirim/'+tanggal);
    http.get(apiToday, headers: {
      HttpHeaders.authorizationHeader: "Token " + token
    }).then((http.Response response) {
      if(response.statusCode==401){
        logout(context);
      }else{
        dynamic antar = json.decode(response.body);
        this.setState(() {
          data_terkirim = antar['barang'];
        });
      }
    });
  }

  Future<void> pending(context) async{
    String token = "";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = await prefs.getString('token');
    var apiToday =
        Uri.http('dkurir.herokuapp.com', '/public/api/pending/'+selected_item.toString());
    http.post(apiToday, headers: {
        HttpHeaders.authorizationHeader: "Token " + token
      },
      body: {
        "id_barang" : selected_item.toString(),
        "alasan" : alasan_pending.text
      }
    ).then((http.Response response) {
      dynamic result = json.decode(response.body);
      if(result['success']){
        Navigator.pop(context);
        this.getData();
        this.getPending();
      }else{
        showToast(result['message']);
      }
    });
  }

  Future<void> terkirim(context, int jenis) async{
    String token = "";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = await prefs.getString('token');
    var apiTerkirim =
        Uri.http('dkurir.herokuapp.com', '/public/api/terkirim/'+selected_item.toString());
    http.post(apiTerkirim, headers: {
        HttpHeaders.authorizationHeader: "Token " + token
      },
      body: {
        "id_barang" : selected_item.toString(),
      }
    ).then((http.Response response) {
      dynamic result = json.decode(response.body);
      if(result['success']){
        Navigator.pop(context);
        if(jenis==1){
          this.getData();
        }else{
          this.getPending();
        }
        this.getTerkirim();
      }else{
        showToast(result['message']);
      }
    });
  }

  selectDate(BuildContext context) async{
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Refer step 1
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate){
      setState(() {
        selectedDate = picked;
      });
      this.getTerkirim();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Antar Barang",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red[600],
          elevation: 0.0,
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.today), child: Text("Today"),),
              Tab(icon: Icon(Icons.pending), child: Text("Pending"),),
              Tab(icon: Icon(Icons.send_and_archive), child: Text("Terkirim"),),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.red[600],
                        width: 3.0
                      )
                    )
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      (isSort) ? IconButton(icon: const Icon(Icons.check), onPressed: (){ 
                        this.saveNumber();
                      }, color: Colors.green[600],) : Container(),
                      IconButton(icon: const Icon(Icons.sort), onPressed: (){
                        setState(() {
                          isSort = !isSort;
                        });
                      },
                      color: Colors.amber[800],)
                    ],
                  ),
                ),
                (data_today==null) ? Expanded(
                  child: SizedBox(
                        width: double.infinity,
                        child: Align(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.red[600]),
                          ),
                        ),
                      ),
                ) : (data_today.length==0) ? SizedBox(width: double.infinity, child: Align(alignment: Alignment.center, child: Image(image: AssetImage('assets/images/not_found.jpg')))) :
                    Expanded(
                      child: ListView.builder(
                          itemCount: (data_today==null ? 0 : data_today.length),
                          itemBuilder: (context, index) =>
                              listToday(context, index)),
                    ),
              ],
            ),

            (data_pending==null) ? SizedBox(
                      width: double.infinity,
                      child: Align(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red[600]),
                        ),
                      ),
                    ) : (data_pending.length==0) ? SizedBox(width: double.infinity, child: Align(alignment: Alignment.center, child: Image(image: AssetImage('assets/images/not_found.jpg')))) :
                    ListView.builder(
                              itemCount: (data_pending==null ? 0 : data_pending.length),
                              itemBuilder: (context, index) =>
                                  listPending(context, index)),

              Column(
                children: [
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat.d().format(selectedDate) + " " + DateFormat.MMMM().format(selectedDate) + " " + DateFormat.y().format(selectedDate),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                // color: Colors.white,
                                fontFamily: 'Ubuntu'),
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
                  (data_terkirim==null) ? Expanded(
                    child: SizedBox(
                        width: double.infinity,
                        child: Align(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.red[600]),
                          ),
                        ),
                      ),
                  ) : (data_terkirim.length==0) ? SizedBox(width: double.infinity, child: Align(alignment: Alignment.center, child: Image(image: AssetImage('assets/images/not_found.jpg')))) :
                    Expanded(
                      child: ListView.builder(
                          itemCount: (data_terkirim==null ? 0 : data_terkirim.length),
                          itemBuilder: (context, index) =>
                              listTerkirim(context, index)),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget listToday(context, index){
    var curency = new NumberFormat.currency(locale: "id_ID",
      symbol: "Rp. ");
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(child: Container(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("No. Resi : "+data_today[index]['bar_kode'],style: TextStyle(fontWeight: FontWeight.bold),),
                          Text("Pengirim : "+data_today[index]['cust_nama']),
                          Text("Kec. "+(data_today[index]['kec_asal_nama']==null ? "" : data_today[index]['kec_asal_nama'])),
                          Text("Kota. "+data_today[index]['kota_asal_nama']),
                          Text("Harga B. "+curency.format((data_today[index]['bar_harga']==null) ? 0 : data_today[index]['bar_harga'])),
                          Text("Ongkir. "+curency.format((data_today[index]['bar_ongkir']==null) ? 0 : data_today[index]['bar_ongkir'])),
                          
                        ],
                      ),
                      )),
                      Expanded(child: Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("Penerima : "+data_today[index]['bar_penerima']),
                            Text("Alamat. "+(data_today[index]['bar_alamat']==null ? "" : data_today[index]['bar_alamat'])),
                            Text("Kec."+(data_today[index]['kec_tujuan_nama']==null ? "" : data_today[index]['kec_tujuan_nama'])),
                            Text("Kota. "+data_today[index]['kota_tujuan_nama']),
                          ],
                        ),
                      )),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.red[600]
                        )
                      )
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.send_sharp , color: Colors.green,), 
                          onPressed: (){
                            setState(() {
                              selected_item = data_today[index]['id_barang'];
                            });
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                  title: Text('Konfirmasi'),
                                  content: Text("Apakah benar data ini sudah terkirim?"),
                                  actions: [
                                    FlatButton(
                                      child: Text("Ya"),
                                      onPressed: () {
                                        this.terkirim(context, 1);
                                      },
                                    )
                                  ],
                              )
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.pending_actions , color: Colors.red,), 
                          onPressed: (){
                            setState(() {
                              selected_item = data_today[index]['id_barang'];
                            });
                            showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                    title: Text('Form Pending'),
                                    content: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TextField(
                                          controller: alasan_pending,
                                          autofocus: true,
                                          decoration: InputDecoration(labelText: "Masukan Alasan", labelStyle: TextStyle(color: Colors.red[600]),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: Colors.red[600] , width: 2.0),
                                            )
                                          ),
                                        ),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.red[600], // background
                                              onPrimary: Colors.white, // foreground
                                            ),
                                            onPressed: (){
                                              this.pending(context);
                                            }, 
                                            child: Text("Pending"),
                                          ),
                                        ),
                                      ],
                                    ),
                                )
                            );
                          },
                        ),
                        (isSort) ? InkWell(
                          onTap: (){
                            this.giveNumber(index);
                          },
                          child: Align( alignment: Alignment.bottomRight,
                            child: Container(
                              decoration: BoxDecoration(
                                color: (data_today[index]['urutan']==null ? Colors.black38 : Colors.red[600]),
                                shape: BoxShape.circle
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text((data_today[index]['urutan']==null ? "   " : data_today[index]['urutan'].toString()), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                              ),
                            )
                          ),
                        ) : Container(),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )),
    );
  }

  Widget listPending(context, index){
    var curency = new NumberFormat.currency(locale: "id_ID",
      symbol: "Rp. ");
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(child: Container(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("No. Resi : "+data_pending[index]['bar_kode'],style: TextStyle(fontWeight: FontWeight.bold),),
                          Text("Pengirim : "+data_pending[index]['cust_nama']),
                          Text("Kec. "+(data_pending[index]['kec_asal_nama']==null ? "" : data_pending[index]['kec_asal_nama'])),
                          Text("Kota. "+data_pending[index]['kota_asal_nama']),
                          Text("Harga B. "+curency.format((data_pending[index]['bar_harga']==null) ? 0 : data_pending[index]['bar_harga'])),
                          Text("Ongkir. "+curency.format((data_pending[index]['bar_ongkir']==null) ? 0 : data_pending[index]['bar_ongkir'])),
                          
                        ],
                      ),
                      )),
                      Expanded(child: Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("Penerima : "+data_pending[index]['bar_penerima']),
                            Text("Alamat. "+(data_pending[index]['bar_alamat']==null ? "" : data_pending[index]['bar_alamat'])),
                            Text("Kec."+(data_pending[index]['kec_tujuan_nama']==null ? "" : data_pending[index]['kec_tujuan_nama'])),
                            Text("Kota. "+data_pending[index]['kota_tujuan_nama']),
                          ],
                        ),
                      )),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.red[600]
                        )
                      )
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Alasan : "+(data_pending[index]['alasan']==null ? "" : data_pending[index]['alasan'])),
                        IconButton(
                          icon: const Icon(Icons.send_sharp , color: Colors.green,), 
                          onPressed: (){
                            setState(() {
                              selected_item = data_pending[index]['id_barang'];
                            });
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                  title: Text('Konfirmasi'),
                                  content: Text("Apakah benar data ini sudah terkirim?"),
                                  actions: [
                                    FlatButton(
                                      child: Text("Ya"),
                                      onPressed: () {
                                        this.terkirim(context, 2);
                                      },
                                    )
                                  ],
                              )
                            );
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )),
    );
  }

  Widget listTerkirim(context, index){
    var curency = new NumberFormat.currency(locale: "id_ID",
      symbol: "Rp. ");
    DateTime tgl = DateTime.parse(data_terkirim[index]['tgl_kirim']);
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(child: Container(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("No. Resi : "+data_terkirim[index]['bar_kode'],style: TextStyle(fontWeight: FontWeight.bold),),
                          Text("Pengirim : "+data_terkirim[index]['cust_nama']),
                          Text("Kec. "+(data_terkirim[index]['kec_asal_nama']==null ? "" : data_terkirim[index]['kec_asal_nama'])),
                          Text("Kota. "+data_terkirim[index]['kota_asal_nama']),
                          Text("Harga B. "+curency.format((data_terkirim[index]['bar_harga']==null) ? 0 : data_terkirim[index]['bar_harga'])),
                          Text("Ongkir. "+curency.format((data_terkirim[index]['bar_ongkir']==null) ? 0 : data_terkirim[index]['bar_ongkir'])),
                          
                        ],
                      ),
                      )),
                      Expanded(child: Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("Penerima : "+data_terkirim[index]['bar_penerima']),
                            Text("Alamat. "+(data_terkirim[index]['bar_alamat']==null ? "" : data_terkirim[index]['bar_alamat'])),
                            Text("Kec."+(data_terkirim[index]['kec_tujuan_nama']==null ? "" : data_terkirim[index]['kec_tujuan_nama'])),
                            Text("Kota. "+data_terkirim[index]['kota_tujuan_nama']),
                          ],
                        ),
                      )),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.red[600]
                        )
                      )
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Tanggal Terkirim : " + DateFormat.d().format(tgl) + " " + DateFormat.MMMM().format(tgl) + " " + DateFormat.y().format(tgl) ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )),
    );
  }
}