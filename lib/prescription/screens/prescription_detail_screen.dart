import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hmz/utils/colors.dart';
import '../../auth/providers/auth.dart';
import '../../dashboard/dashboard.dart';
import '../../prescription/screens/user_prescriptions_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';

import 'dart:io';
import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PrescriptionDetails {
  final String id;
  final String patient_name;
  final String patient_id;

  final String doctor_name;
  final String doctor_id;
  final String date;
  final String state;
  final String symptom;
  final String advice;
  final String medicine;
  final String note;
  final String age;
  final String gender;
  final String hospital_title;
  final String hospital_address;
  final String hospital_phone;
  final String hospital_patient_id;
  final String hospital_prescription_id;

  PrescriptionDetails({
    this.id,
    this.patient_name,
    this.patient_id,
    this.doctor_name,
    this.doctor_id,
    this.date,
    this.state,
    this.symptom,
    this.advice,
    this.medicine,
    this.note,
    this.age,
    this.gender,
    this.hospital_title,
    this.hospital_address,
    this.hospital_phone,
    this.hospital_patient_id,
    this.hospital_prescription_id,
  });
}

class MedicineDetails {
  final String id;
  final String name;
  final String gram;
  final String schedule;

  final String days;
  final String time;

  MedicineDetails({
    this.id,
    this.name,
    this.gram,
    this.schedule,
    this.days,
    this.time,
  });
}

class PrescriptionDetailScreen extends StatefulWidget {
  static const routeName = '/prescription-detail';
  var prescriptionid;
  String idd;
  String useridd;

  PrescriptionDetailScreen(this.idd, this.useridd, {this.prescriptionid});

  @override
  _PrescriptionDetailScreenState createState() =>
      _PrescriptionDetailScreenState(
          this.idd, this.useridd, this.prescriptionid);
}

class _PrescriptionDetailScreenState extends State<PrescriptionDetailScreen> {
  var prescriptionid;
  String idd;
  String useridd;

  List<MedicineDetails> medicines = List();
  String full_medicine_String = "";

  Future<PrescriptionDetails> prescriptionDetails;

  _PrescriptionDetailScreenState(this.idd, this.useridd, this.prescriptionid);

  Future<String> getMedicineByID(var medicineid, var ionid) async {
    // var medicinedata = await http.get(Auth().linkURL +
    //     "api/getMedicineById?id=${medicineid}&ion_id=" +
    //     ionid);
    final url = Auth().linkURL + "api/getMedicineById";
    var medicinedata = await http.post(
      Uri.parse(url),
      body: {
        'id': medicineid,
        'ion_id': ionid,
      },
    );

    var jsondatax = json.decode(medicinedata.body);

    return jsondatax["name"];
  }

  Future<PrescriptionDetails> _responseFuture() async {
    // var data = await http.get(Auth().linkURL +
    //     "api/viewPrescription?id=${prescriptionid}&user_ion_id=" +
    //     useridd);

    final url = Auth().linkURL + "api/viewPrescription";

    final data = await http.post(
      Uri.parse(url),
      body: {
        'id': prescriptionid,
        'user_ion_id': useridd,
      },
    );

    var jsondata = json.decode(data.body);
    var ini_prescription = jsondata["prescription"];
    var ini_setting = jsondata["settings"];
    var ini_user = jsondata["user"];

    var timestamp = int.parse(ini_prescription["date"]);

    var datess = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    var datesss = "${datess.day}-${datess.month}-${datess.year}";

    var currenttime = DateTime.now();
    var parsaage = ini_user["birthdate"];
    var agearray = parsaage.split("-");

    var borntime = DateTime(
        int.parse(agearray[2]), int.parse(agearray[1]), int.parse(agearray[0]));
    var currentage = currenttime.difference(borntime).inDays / 365;
    var currentage_F = currentage.floor();

    if (ini_prescription["medicine"] != "") {
      var medicine_sort = ini_prescription["medicine"];
      var medicine_sortList = medicine_sort.split("###");

      for (var sorti in medicine_sortList) {
        var temp_medicine_sortList = sorti.split("***");

        String medicinename =
            await getMedicineByID(temp_medicine_sortList[0], useridd);

        MedicineDetails md = new MedicineDetails(
          id: temp_medicine_sortList[0],
          name: medicinename,
          gram: temp_medicine_sortList[1],
          schedule: temp_medicine_sortList[2],
          days: temp_medicine_sortList[3],
          time: temp_medicine_sortList[4],
        );

        full_medicine_String = full_medicine_String +
            "${medicinename} - ${temp_medicine_sortList[1]} - ${temp_medicine_sortList[2]} - ${temp_medicine_sortList[3]} - ${temp_medicine_sortList[4]} \n";

        medicines.add(md);
      }
    }

    var historyz = ini_prescription["symptom"]
        .replaceAll("<p>", "")
        .replaceAll("</p>", "\n")
        .replaceAll("<h1>", "")
        .replaceAll("</h1>", "\n")
        .replaceAll("<h2>", "")
        .replaceAll("</h2>", "\n")
        .replaceAll("<h3>", "")
        .replaceAll("</h3>", "\n")
        .replaceAll("<h4>", "")
        .replaceAll("</h4>", "\n");

    var notez = ini_prescription["note"]
        .replaceAll("<p>", "")
        .replaceAll("</p>", "\n")
        .replaceAll("<h1>", "")
        .replaceAll("</h1>", "\n")
        .replaceAll("<h2>", "")
        .replaceAll("</h2>", "\n")
        .replaceAll("<h3>", "")
        .replaceAll("</h3>", "\n")
        .replaceAll("<h4>", "")
        .replaceAll("</h4>", "\n");

    PrescriptionDetails subdata = PrescriptionDetails(
      id: ini_prescription["id"],
      hospital_prescription_id: ini_prescription["hospital_prescription_id"],
      hospital_patient_id: ini_prescription["hospital_patient_id"],
      patient_name: ini_prescription["patientname"],
      patient_id: ini_prescription["patient"],
      doctor_name: ini_prescription["doctorname"],
      doctor_id: ini_prescription["doctor"],
      date: datesss,
      state: ini_prescription["state"],
      symptom: historyz,
      advice: ini_prescription["advice"],
      medicine: full_medicine_String,
      note: notez,
      age: currentage_F.toString(),
      gender: ini_user["sex"],
      hospital_title: ini_setting["title"],
      hospital_address: ini_setting["address"],
      hospital_phone: ini_setting["phone"],
    );

    return subdata;
  }

  @override
  void initState() {
    super.initState();
  }

  AppColor appcolor = new AppColor();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).prescriptionDetail,
          style: TextStyle(
            color: appcolor.appbartext(),
            fontWeight: appcolor.appbarfontweight(),
          ),
        ),
        centerTitle: true,
        backgroundColor: appcolor.appbarbackground(),
        elevation: 0.0,
        iconTheme: IconThemeData(color: appcolor.appbaricontheme()),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context)
              .pushReplacementNamed(UserPrescriptionsScreen.routeName),
        ),
        actions: <Widget>[],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(top: 10),
          child: new FutureBuilder(
            future: _responseFuture(),
            builder: (BuildContext context, AsyncSnapshot response) {
              if (response.data == null) {
                return Container(
                  child: Center(child: CircularProgressIndicator()),
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 1,
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Text(
                        "${response.data.doctor_name}",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Text(
                                "${AppLocalizations.of(context).date}: ${response.data.date}"),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            child: Text(
                                "${AppLocalizations.of(context).prescriptionId}: ${response.data.hospital_prescription_id}"),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Text(
                                "${AppLocalizations.of(context).patient}: ${response.data.patient_name}"),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            child: Text(
                                "${AppLocalizations.of(context).patientId}: ${response.data.hospital_patient_id}"),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Text(
                                "${AppLocalizations.of(context).age}: ${response.data.age} "),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            child: Text(
                                "${AppLocalizations.of(context).gender}: ${response.data.gender}"),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 1,
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Text(
                        "${AppLocalizations.of(context).rx}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 1,
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Text(
                        "${response.data.medicine}",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Divider(),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 1,
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Text(
                        AppLocalizations.of(context).history,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 1,
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Html(
                        data: "${response.data.symptom}",
                        // style: TextStyle(
                        //   fontSize: 15,
                        // ),
                      ),
                    ),
                    Divider(),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 1,
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Text(
                        AppLocalizations.of(context).advice,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 1,
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Html(
                        data: "${response.data.advice}",
                        // style: TextStyle(
                        //   fontSize: 15,
                        // ),
                      ),
                    ),
                    Divider(),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 1,
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Text(
                        AppLocalizations.of(context).note,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 1,
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Html(
                        data: "${response.data.note}",
                        // style: TextStyle(
                        //   fontSize: 15,
                        // ),
                      ),
                    ),
                    Divider(),
                    SizedBox(
                      height: 50,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Column(
                              children: [
                                Text(
                                  "__________",
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(AppLocalizations.of(context).signature),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * .5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                    child: Text(
                                  "${response.data.hospital_title}",
                                  style: TextStyle(fontSize: 20),
                                )),
                                Container(
                                  child: Text(
                                    " ${response.data.hospital_address}",
                                    style: TextStyle(fontSize: 11),
                                  ),
                                ),
                                Container(
                                    child: Text(
                                  "${response.data.hospital_phone}",
                                  style: TextStyle(fontSize: 12),
                                )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
