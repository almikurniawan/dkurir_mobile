import 'dart:typed_data';
import "package:intl/intl.dart";
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:share/share.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class Resume extends StatefulWidget {
  final int trx_id;

  const Resume({Key key, this.trx_id}) : super(key: key);

  @override
  _ResumeState createState() => _ResumeState();
}

class _ResumeState extends State<Resume> {
  String kode_trx = "";
  String pengirim = "";
  String kurir = "";
  String tanggal = "";
  String penerima = "";
  String catatan = "";
  String harga_barang = "";
  String berat_barang = "";
  String ongkir = "";
  String total_bayar = "";
  String kec_asal = "";
  String kec_tujuan = "";
  String kota_asal = "";
  String kota_tujuan = "";
  String alamat = "";
  String status = "";
  String alasan_pending = "";
  int ongkir_number = 0;

  Uint8List _imageFile;

  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    this.getResume();
    // TODO: implement initState
    super.initState();
    this._requestPermission();
  }

  Future<void> capture() async {
    screenshotController.capture().then((Uint8List image) {
      this.shareImage(image);
    }).catchError((onError) {
    });
  }

  shareImage(image) async {
    final result = await ImageGallerySaver.saveImage(
           Uint8List.fromList(image),
           quality: 100,
           name: "ss_dkurir");
    Share.shareFiles([result['filePath'].toString().replaceAll("file://","")], text: 'Bukti Transaksi');
  }

  _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();
    final info = statuses[Permission.storage].toString();
  }

  Future<void> getResume() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = await prefs.getString('token');
    var apiLogin = Uri.http('dkurir.herokuapp.com',
        '/public/api/barang/' + widget.trx_id.toString());
    http.get(apiLogin, headers: {
      HttpHeaders.authorizationHeader: "Token " + token
    }).then((http.Response response) {
      Map<String, dynamic> result = json.decode(response.body);
      print(result);
      var curency = new NumberFormat.currency(locale: "id_ID", symbol: "Rp. ");
      DateTime tgl = DateTime.parse(result['barang']['bar_tgl']);
      setState(() {
        kode_trx = (result['barang']['bar_kode'] == null
            ? ""
            : result['barang']['bar_kode']);
        pengirim = (result['barang']['cust_nama'] == null
            ? ""
            : result['barang']['cust_nama']);
        kurir = (result['barang']['kur_nama'] == null
            ? ""
            : result['barang']['kur_nama']);
        tanggal = DateFormat.d().format(tgl) +
            " " +
            DateFormat.MMM().format(tgl) +
            " " +
            DateFormat.y().format(tgl);
        penerima = (result['barang']['bar_penerima'] == null
            ? ""
            : result['barang']['bar_penerima']);
        catatan = (result['barang']['bar_catatan'] == null
            ? ""
            : result['barang']['bar_catatan']);
        harga_barang = (result['barang']['bar_harga'] == null
            ? ""
            : curency.format(result['barang']['bar_harga']));
        berat_barang = (result['barang']['bar_berat'] == null
            ? ""
            : result['barang']['bar_berat']);
        ongkir = (result['barang']['bar_ongkir'] == null
            ? ""
            : curency.format(result['barang']['bar_ongkir']));
        ongkir_number = result['barang']['bar_ongkir'];
        total_bayar = (result['barang']['bar_total_bayar'] == null
            ? ""
            : curency.format(result['barang']['bar_total_bayar']));
        kec_asal = (result['barang']['kec_asal_nama'] == null
            ? ""
            : result['barang']['kec_asal_nama']);
        kec_tujuan = (result['barang']['kec_tujuan_nama'] == null
            ? ""
            : result['barang']['kec_tujuan_nama']);
        kota_asal = (result['barang']['kota_asal_nama'] == null
            ? ""
            : result['barang']['kota_asal_nama']);
        kota_tujuan = (result['barang']['kota_tujuan_nama'] == null
            ? ""
            : result['barang']['kota_tujuan_nama']);
        alamat = (result['barang']['bar_alamat'] == null
            ? ""
            : result['barang']['bar_alamat']);
        status = (result['barang']['status_label'] == null
            ? ""
            : result['barang']['status_label']);
        alasan_pending = (result['barang']['status_alasan'] == null
            ? ""
            : result['barang']['status_alasan']);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Resume",
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
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.infinity,
            child: Screenshot(
              controller: screenshotController,
              child: Card(
                  elevation: 5,
                  child: Container(
                      decoration: BoxDecoration(
                          border: Border(
                        top: BorderSide(width: 2.0, color: Colors.red[600]),
                      )),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 5),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Image(
                                    image: AssetImage('assets/images/logo.jpg'),
                                    width: 100,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ),
                              ((ongkir_number == 0 || ongkir_number == null)
                                  ? Container(
                                      decoration: BoxDecoration(
                                          color: Colors.yellow[600],
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                                "Ongkos kirim masih belum di setting, mohon follow up admin.")),
                                      ),
                                    )
                                  : Container()),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 5),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "No. Resi",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(
                                        child: Text(
                                      kode_trx,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 5),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Dikirim dari",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(
                                        child:
                                            Text(kec_asal + " - " + kota_asal)),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 5),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Dikirim ke",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(
                                        child: Text(alamat +
                                            " - " +
                                            kec_tujuan +
                                            " - " +
                                            kota_tujuan)),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 5),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Pengirim",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(child: Text(pengirim)),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 5),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Kurir",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(child: Text(kurir)),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 5),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Tanggal",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(child: Text(tanggal)),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 5),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Penerima",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(child: Text(penerima)),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 5),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Catatan",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(child: Text(catatan)),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 5),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Harga Barang",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(child: Text(harga_barang)),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 5),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Berat Barang",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(child: Text(berat_barang + " Kg")),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 5),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Ongkir",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(child: Text(ongkir)),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 5),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Total Bayar",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(child: Text(total_bayar)),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 5),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Status",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(child: Text(status)),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 5),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Keterangan",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(child: Text(alasan_pending)),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: ElevatedButton.icon(
                                  icon: Icon(Icons.share),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.red[600], // background
                                    onPrimary: Colors.white, // foreground
                                  ),
                                  onPressed: () {
                                    this.capture();
                                  },
                                  label: Text(
                                    "Share",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ))),
            ),
          ),
        )));
  }
}
