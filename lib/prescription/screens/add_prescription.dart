import 'dart:io';

import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:hmz/prescription/screens/user_prescriptions_screen.dart';
import 'package:hmz/utils/colors.dart';
import 'package:intl/intl.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import '../../auth/providers/auth.dart';
import '../../dashboard/dashboard.dart';
import 'prescription_detail_screen.dart';
import 'package:provider/provider.dart';
import '../../home/widgets/app_drawer.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';

class AddedMedicineDetails {
  String id;
  String name;
  TextEditingController dosage;
  TextEditingController freq;
  TextEditingController days;
  TextEditingController instruction;

  AddedMedicineDetails({
    this.id,
    this.name,
    this.dosage,
    this.freq,
    this.days,
    this.instruction,
  });
}

class AddUserPrescriptionsScreen extends StatefulWidget {
  static const routeName = '/adduserPrescriptions';
  String idd;
  String useridd;

  AddUserPrescriptionsScreen(this.idd, this.useridd);

  @override
  _AddUserPrescriptionsScreenState createState() =>
      _AddUserPrescriptionsScreenState(this.idd, this.useridd);
}

class _AddUserPrescriptionsScreenState
    extends State<AddUserPrescriptionsScreen> {
  String idd;
  String useridd;

  _AddUserPrescriptionsScreenState(this.idd, this.useridd);

  bool errorpatientselect = false;
  bool errorselecteddate = false;

  final _formKey = GlobalKey<FormState>();
  DateTime selectedDate1;
  String patient;
  String doctor;
  String _date;
  String _fullMedicineString;
  List patientList = List();
  List doctorList = List();
  List medicineList = List();
  List<AddedMedicineDetails> selectedmedicineList = [];
  List<TextEditingController> dosage1 = [];
  List<TextEditingController> freq1 = [];
  List<TextEditingController> days1 = [];
  List<TextEditingController> instruc1 = [];

  bool _isloading = true;
  String _mySelectionpatient;
  String _mySelectiondoctor;

  TextEditingController _history = TextEditingController();
  TextEditingController _note = TextEditingController();
  TextEditingController _advice = TextEditingController();
  TextEditingController _medicine = TextEditingController();

  Future<List<AppintmentDetails>> _responseFuture() async {
    String doctor_id = this.idd;

    // var data = await http.get(Auth().linkURL +
    //     "api/getMyAllAppoinmentList?group=doctor&id=" +
    //     doctor_id);

    // final url = Auth().linkURL + "api/getMyAllAppoinmentList";
    //
    // final data = await http.post(
    //   Uri.parse(url),
    //   body: {
    //     'group': "doctor",
    //     'id': doctor_id,
    //   },
    // );
    //
    // var jsondata = json.decode(data.body);

    final url = Auth().linkURL + "api/getMyAllAppoinmentList?id=$doctor_id&group=doctor";

    final response = await http.get(Uri.parse(url));

    var jsondata = json.decode(response.body);

    List<AppintmentDetails> _lcdata = [];

    for (var u in jsondata) {
      AppintmentDetails subdata = AppintmentDetails(
        id: u["id"],
        patient_name: u["patient_name"],
        doctor_name: u["doctor_name"],
        date: u["date"],
        start_time: u["start_time"],
        end_time: u["end_time"],
        remarks: u["remarks"],
        status: u["status"],
        jitsi_link: u["jitsi_link"],
      );
      _lcdata.add(subdata);
    }

    return _lcdata;
  }

  Future<String> getPatient() async {
    final String url = Auth().linkURL + "api/getPatientList?id=";
    String urrr1 = url + "${this.useridd}";
    var res = await http.get(urrr1, headers: {"Accept": "application/json"});
    var resBody = json.decode(res.body);

    setState(() {
      patientList = resBody;
      _isloading = false;
    });

    return "Sucess";
  }

  Future<String> getDoctor() async {
    final String url = Auth().linkURL + "api/getDoctorList?id=${this.useridd}";

    var res = await http.get(url, headers: {"Accept": "application/json"});
    var resBody = json.decode(res.body);

    setState(() {
      doctorList = resBody;
      _isloading = false;
    });

    return "Sucess";
  }

  @override
  void initState() {
    super.initState();
    this.doctor = this.idd;

    this.getPatient();
    this.getDoctor();
  }

  Future<String> searchMedicine(var medicine) async {
    var medicinedata = await http.get(Auth().linkURL +
        "api/getMedicineBySearch?search=${medicine}&ion_id=" +
        useridd);

    var jsondatax = json.decode(medicinedata.body);

    setState(() {
      if (medicine == "") {
        medicineList.clear();
      } else {
        medicineList = jsondatax;
      }
    });
  }

  Future<String> addPrescription(context) async {
    String posturl = Auth().linkURL + "api/addNewPrescription";
    var success;

    final res = await http.post(
      posturl,
      body: {
        'ion_id': this.useridd,
        'patient': this.patient,
        'doctor': this.doctor,
        'date': this._date,
        'note': "<p>${this._note.text}</p>",
        'symptom': "<p>${this._history.text}</p>",
        'medicine': this._fullMedicineString,
        'advice': this._advice.text,
      },
    );

    if (res.statusCode == 200) {
      success = "success";

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context).success),
              content:
                  Text(AppLocalizations.of(context).prescriptionHasBeenCreated),
              actions: [
                FlatButton(
                  child: Text(AppLocalizations.of(context).ok),
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(
                        UserPrescriptionsScreen.routeName);
                  },
                )
              ],
            );
          });

      return 'success';
    } else {
      return "error";
    }
  }

  AppColor appcolor = new AppColor();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).createPrescription,
          style: TextStyle(
            color: appcolor.appbartext(),
            fontWeight: appcolor.appbarfontweight(),
          ),
        ),
        centerTitle: true,
        backgroundColor: appcolor.appbarbackground(),
        elevation: 0,
        bottomOpacity: .1,
        iconTheme: IconThemeData(color: appcolor.appbaricontheme()),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context)
              .pushReplacementNamed(UserPrescriptionsScreen.routeName),
        ),
      ),
      drawer: AppDrawer(),
      body: Container(
          padding: EdgeInsets.only(top: 10),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      child: Center(
                        child: DateTimeField(
                            dateFormat: DateFormat("y/M/d"),
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context).date,
                            ),
                            selectedDate: selectedDate1,
                            mode: DateTimeFieldPickerMode.date,
                            onDateSelected: (DateTime value) {
                              setState(() {
                                selectedDate1 = value;
                                String formattedDate =
                                    DateFormat('yyyy-MM-dd').format(value);
                                this._date = formattedDate;
                              });
                            }),
                      ),
                    ),
                  ),
                ),
                (errorselecteddate)
                    ? Container(
                        padding: EdgeInsets.only(left: 20),
                        child: Text(
                          " No date selected",
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      )
                    : Container(),
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: SearchableDropdown.single(
                    displayClearIcon: false,
                    items: patientList.map((item) {
                      return new DropdownMenuItem(
                        child: Container(
                          padding: EdgeInsets.only(top: 15, bottom: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                child: Image.network(
                                    "https://image.flaticon.com/icons/png/512/147/147144.png"),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(item['name']),
                            ],
                          ),
                        ),
                        value: item,
                      );
                    }).toList(),
                    value: _mySelectionpatient,
                    hint: Container(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Text(
                        AppLocalizations.of(context).chooseapatient,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    searchHint: AppLocalizations.of(context).searchpatient,
                    onChanged: (value) {
                      setState(() {
                        errorpatientselect = false;
                        _mySelectionpatient = value["id"];
                        patient = value["id"];
                      });
                    },
                    isExpanded: true,
                  ),
                ),
                (errorpatientselect)
                    ? Container(
                        padding: EdgeInsets.only(left: 20),
                        child: Text(
                          " No patient selected",
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      )
                    : Container(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      child: TextFormField(
                        controller: _history,
                        decoration: InputDecoration(
                            labelText: AppLocalizations.of(context).history,
                            hintText: AppLocalizations.of(context).history),
                        validator: (value) {
                          if (value.isEmpty) {
                            return AppLocalizations.of(context).invalidInput;
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      child: TextFormField(
                        controller: _advice,
                        decoration: InputDecoration(
                            labelText: AppLocalizations.of(context).advice,
                            hintText: AppLocalizations.of(context).advice),
                        validator: (value) {
                          if (value.isEmpty) {
                            return AppLocalizations.of(context).invalidInput;
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      child: TextFormField(
                        controller: _note,
                        decoration: InputDecoration(
                            labelText: AppLocalizations.of(context).note,
                            hintText: AppLocalizations.of(context).note),
                        validator: (value) {
                          if (value.isEmpty) {
                            return AppLocalizations.of(context).invalidInput;
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      child: TextFormField(
                        controller: _medicine,
                        decoration: InputDecoration(
                            labelText:
                                AppLocalizations.of(context).searchMedicine,
                            hintText:
                                AppLocalizations.of(context).searchMedicine),
                        onChanged: (value) {
                          searchMedicine(value);

                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          border:
                              Border.all(width: 0.05, color: Colors.black54)),
                      child: ListView.builder(
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount: medicineList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Row(
                              children: [
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width * .2,
                                    child:
                                        Text("${medicineList[index]['id']}")),
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width * .2,
                                    child:
                                        Text("${medicineList[index]['name']}")),
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width * .2,
                                    child: TextButton(
                                      child: Text(
                                          AppLocalizations.of(context).add),
                                      onPressed: () {
                                        setState(() {
                                          bool dataInside = false;
                                          if (selectedmedicineList.length > 0) {
                                            for (var check = 0;
                                                check <
                                                    selectedmedicineList.length;
                                                check++) {
                                              if (selectedmedicineList[check]
                                                      .id ==
                                                  medicineList[index]['id']) {
                                                dataInside = true;
                                              }
                                            }
                                          }
                                          if (!dataInside ||
                                              selectedmedicineList.length ==
                                                  0) {
                                            AddedMedicineDetails adm =
                                                new AddedMedicineDetails();
                                            adm.id = medicineList[index]['id'];
                                            adm.name =
                                                medicineList[index]['name'];

                                            selectedmedicineList.add(adm);
                                          }
                                        });
                                      },
                                    )),
                              ],
                            );
                          }),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Center(
                    child: Container(
                        width: double.infinity,
                        child: Text(
                          AppLocalizations.of(context).medicines,
                          style: TextStyle(fontSize: 18),
                        )),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.blue),
                      ),
                      child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 5),
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount: selectedmedicineList.length,
                          itemBuilder: (BuildContext context, int index) {
                            dosage1.add(new TextEditingController(text: ""));
                            freq1.add(new TextEditingController(text: ""));
                            days1.add(new TextEditingController(text: ""));
                            instruc1.add(new TextEditingController(text: ""));

                            return Row(
                              children: [
                                Container(
                                    width: 50,
                                    child: Text(
                                        "${selectedmedicineList[index].name}")),
                                SizedBox(width: 5),
                                Container(
                                    width: 50,
                                    child: TextFormField(
                                      controller: dosage1[index],
                                      style: TextStyle(
                                        fontSize: 13,
                                      ),
                                      decoration: InputDecoration(
                                          hintText: "500mg",
                                          hintStyle: TextStyle(
                                            fontSize: 12,
                                          )),
                                      validator: (value) {
                                        if (value.length > 0) {}

                                        return null;
                                      },
                                      onSaved: (value) {
                                        selectedmedicineList[index].dosage =
                                            TextEditingController(text: value);
                                      },
                                    )),
                                SizedBox(width: 5),
                                Container(
                                    width: 50,
                                    child: TextFormField(
                                      controller: freq1[index],
                                      style: TextStyle(
                                        fontSize: 13,
                                      ),
                                      decoration: InputDecoration(
                                          hintText: "1+0+1",
                                          hintStyle: TextStyle(
                                            fontSize: 12,
                                          )),
                                      validator: (value) {
                                        if (value.length > 0) {}

                                        return null;
                                      },
                                      onSaved: (value) {
                                        setState(() {
                                          selectedmedicineList[index].freq =
                                              TextEditingController(
                                                  text: value);
                                        });
                                      },
                                    )),
                                SizedBox(width: 5),
                                Container(
                                    width: 35,
                                    child: TextFormField(
                                      controller: days1[index],
                                      style: TextStyle(
                                        fontSize: 13,
                                      ),
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                          hintText:
                                              "5 ${AppLocalizations.of(context).days}",
                                          hintStyle: TextStyle(
                                            fontSize: 12,
                                          )),
                                      validator: (value) {
                                        if (value.length > 0) {}

                                        return null;
                                      },
                                      onSaved: (value) {
                                        selectedmedicineList[index].days =
                                            TextEditingController(text: value);
                                      },
                                    )),
                                SizedBox(width: 5),
                                Expanded(
                                  child: Container(
                                      width: 80,
                                      child: TextFormField(
                                        controller: instruc1[index],
                                        style: TextStyle(
                                          fontSize: 13,
                                        ),
                                        decoration: InputDecoration(
                                            hintText:
                                                AppLocalizations.of(context)
                                                    .afterfood,
                                            hintStyle: TextStyle(
                                              fontSize: 12,
                                            )),
                                        validator: (value) {
                                          if (value.length >= 1) {}

                                          return null;
                                        },
                                        onSaved: (value) {
                                          selectedmedicineList[index]
                                                  .instruction =
                                              TextEditingController(
                                                  text: value);
                                        },
                                      )),
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                  child: Container(
                                      width: 50,
                                      child: TextButton(
                                        child: Icon(Icons.delete),
                                        onPressed: () {
                                          setState(() {
                                            var dataInsideid;

                                            for (var check = 0;
                                                check <
                                                    selectedmedicineList.length;
                                                check++) {
                                              if (selectedmedicineList[check]
                                                      .id ==
                                                  selectedmedicineList[index]
                                                      .id) {
                                                dataInsideid = check;
                                              }
                                            }

                                            selectedmedicineList.remove(
                                                selectedmedicineList[
                                                    dataInsideid]);
                                          });
                                        },
                                      )),
                                ),
                              ],
                            );
                          }),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Center(
                    child: Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              var tempmedSend = "";
                              var triplehash = "###";

                              for (var check = 0;
                                  check < selectedmedicineList.length;
                                  check++) {
                                if (check == selectedmedicineList.length - 1) {
                                  triplehash = "";
                                }

                                tempmedSend = tempmedSend +
                                    "${selectedmedicineList[check].id}***${dosage1[check].text}***${freq1[check].text}***${days1[check].text}***${instruc1[check].text}${triplehash}";
                              }
                              setState(() {
                                _fullMedicineString = tempmedSend;
                              });

                              if (patient == "" || patient == null) {
                                errorpatientselect = true;
                              } else if (selectedDate1 == "" ||
                                  selectedDate1 == null) {
                                errorselecteddate = true;
                              } else {
                                addPrescription(context);
                              }
                            }
                          },
                          child: Text(AppLocalizations.of(context).create),
                        )),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
