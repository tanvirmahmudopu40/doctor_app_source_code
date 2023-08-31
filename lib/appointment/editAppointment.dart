import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hmz/auth/providers/auth.dart';
import 'package:hmz/home/widgets/app_drawer.dart';
import 'package:hmz/utils/colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:date_field/date_field.dart';

import 'dart:async';
import 'dart:convert';
import 'showAppointment.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Patient {
  final String id;
  final String image;
  final String name;

  Patient({
    this.id,
    this.image,
    this.name,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

class EditAppointmentDetailsScreen extends StatefulWidget {
  static const routeName = '/editAppointmentdetail';

  String idd;
  String useridd;
  String appiontmentid;
  EditAppointmentDetailsScreen(this.idd, this.useridd,this.appiontmentid);

  @override
  EditAppointmentDetailsScreenState createState() =>
      EditAppointmentDetailsScreenState(this.idd, this.useridd,this.appiontmentid);
}

class EditAppointmentDetailsScreenState extends State<EditAppointmentDetailsScreen> {
  String idd;
  String useridd;
  String appiontmentid;
  EditAppointmentDetailsScreenState(this.idd, this.useridd,this.appiontmentid);

  final _formKey = GlobalKey<FormState>();
  String patient;
  var patientlist = "";
  Future<List<Patient>> users;

  String _mySelection;
  String _mySelection2;
  String _mySelection3;

  List<Patient> patientDataList = List();
  List<DropdownMenuItem<Patient>> dropdownPatientItems;
  Patient selectedPatient;

  List doctorSlotList ;
  List<DropdownMenuItem> dropdownDoctorSlotItems;
  var selectedDoctorSlot;

  final String url = Auth().linkURL +"api/getPatientList?id=";

  List<Patient> paientList = List();

  var appointmentstore ;


  var data ;
  List data2 = List();
  List data3 = ['Confirmed', 'Pending Confirmation', 'Treated','Cancelled', 'Requested'];
  String availableSlot = '';
  String appointmentStatus;
  TextEditingController _doctor = TextEditingController();
  DateTime selectedDate;
  bool _isloading =true;



  String _date = "";
  final _remarks = TextEditingController();

  List<DropdownMenuItem<Patient>> buildPatientMenuItems(List patients){
    List<DropdownMenuItem<Patient>> itemss =List();
    for (Patient zpatient in patients ){
      itemss.add(
        DropdownMenuItem(
          value: zpatient,
          child: Text(zpatient.name))
      );

    }
    return itemss;


  }

  List<DropdownMenuItem>  buildDoctorSlotMenuItems(List doctorslot){
    List<DropdownMenuItem> itemss =List();
    for (var zdoctor in doctorslot ){

      itemss.add(
        DropdownMenuItem(
          value: zdoctor['s_time'] + " To " + zdoctor['e_time'],
          child: Text(zdoctor['s_time'] + " To " + zdoctor['e_time']+ " SL " + zdoctor['serial_no'] ))
      );


    }

    return itemss;


  }

  onchangedDropdownDoctorSlotItem(var selectedDoctorSlot1 ){
        setState(() {
          selectedDoctorSlot = selectedDoctorSlot1;
          availableSlot = selectedDoctorSlot.toString();


        });

      }



  Future<String> getDoctorSlot(getslot, selectedDoctorSlot1) async {


    var res = await http.get(Uri.encodeFull(getslot), headers: {"Accept": "application/json"});
    var resBody = json.decode(res.body);

    data2 = resBody;

      dropdownDoctorSlotItems = buildDoctorSlotMenuItems(resBody);
      if(!data2.isEmpty && selectedDoctorSlot1 == "tempSlot"){
        selectedDoctorSlot = dropdownDoctorSlotItems[0].value;
      }
      else if(selectedDoctorSlot1.contains(" To ")){

         for(var zi =0;zi<data2.length;zi++){
          if(data2[zi]['s_time'] + " To " +data2[zi]['e_time']  == selectedDoctorSlot1){
            selectedDoctorSlot = selectedDoctorSlot1;
            break;
          }

        }

      }
      else{
        selectedDoctorSlot = AppLocalizations.of(context).noAppointment;
      }


    setState(() {
    });



    return "success";
  }

  Future<String> getSWData(appointmentstore) async {
    String urrr1 = url + "${this.useridd}";
    var res = await http.get(urrr1, headers: {"Accept": "application/json"});
    var resBody = json.decode(res.body);
    data = resBody;

    for(var zx = 0 ; zx< resBody.length; zx++){
      paientList.add(Patient.fromJson( resBody[zx]));
    }

    dropdownPatientItems = buildPatientMenuItems(paientList);

    for(var zi = 0; zi< paientList.length; zi++) {
          if(paientList[zi].id == patient) {
            selectedPatient = paientList[zi];
            patient = selectedPatient.id;


          }

      }

    String dateformat = appointmentstore['date'];
    this._date = dateformat;
    var dateformatlist = dateformat.split("-");

    selectedDate = DateTime(int.parse(dateformatlist[2]),int.parse(dateformatlist[1]),int.parse(dateformatlist[0]));



    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    var selectedDoctorSlot1 = appointmentstore['start_time'] + " To "+appointmentstore['end_time'];
    availableSlot = selectedDoctorSlot1;



    String getslot = Auth().linkURL +'api/getDoctorTimeSlop?doctor_id='+_doctor.text+'&date='+formattedDate;




    getDoctorSlot(getslot, selectedDoctorSlot1);

    _remarks.text = appointmentstore['remarks'] ;
    appointmentStatus = appointmentstore['status'];





    setState(() {

       _isloading =false;
    });

    return "Sucess";
  }


  Future<String> getAppointment() async {
      String appointmenturl = Auth().linkURL +"api/getAppointmentById?id=${this.appiontmentid}";

      var res = await http.get(Uri.encodeFull(appointmenturl), headers: {"Accept": "application/json"});
      var resBody = json.decode(res.body);

      setState(() {
        appointmentstore = resBody;

        this.patient = appointmentstore['patient'];
        this.getSWData(appointmentstore);



      });

      return "success";
    }

  String success = "";
  bool _firstclick = true;
  Future<String> makeAppointment(context) async {

    String posturl = Auth().linkURL + "api/updateAppointment";



    final res = await http.post(
      posturl,
      body: {
        'id': this.appiontmentid,
        'patient': this.patient,
        'doctor': this._doctor.text,
        'date': this._date,
        'status': this.appointmentStatus,
        'time_slot': this.availableSlot,
        'user_type': 'doctor',
        'remarks': this._remarks.text,
      },
    );


    if (res.statusCode == 200&& _doctor != "") {
      this.success = "success";

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context).success),
              content: Text(AppLocalizations.of(context).appointmentUpdateMessage),
              actions: [
                FlatButton(
                  child: Text(AppLocalizations.of(context).ok),
                  onPressed: () {
                    Navigator.of(context)
                        .pushReplacementNamed(ShowAppointmentScreen.routeName);
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


  @override
  void initState() {
    super.initState();
    _doctor = new TextEditingController(text: this.idd);


    getAppointment();
  }


  AppColor appcolor = new AppColor();

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).editAppointment,
            style: TextStyle(
              color: appcolor.appbartext(),
            fontWeight: appcolor.appbarfontweight(),
            ),
          ),
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),

            onPressed: () => Navigator.of(context).pushReplacementNamed(ShowAppointmentScreen.routeName),
          ),

          centerTitle: true,
          backgroundColor: appcolor.appbarbackground(),
          elevation: 0,
          bottomOpacity: .1,



          iconTheme: IconThemeData(color: appcolor.appbaricontheme()),

        ),

        body:  (_isloading) ? Center(child: CircularProgressIndicator()) :  Container(
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [


            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Container(
                      width: double.infinity,
                      child: new DropdownButtonFormField(
                        decoration: InputDecoration(labelText: AppLocalizations.of(context).patient),


                        items: dropdownPatientItems ,
                        onChanged: (newVal) {
                          setState(() {


                            selectedPatient = newVal;
                            patient = selectedPatient.id;
                          });
                        },
                        value: this.selectedPatient,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        child: Center(
                          child: DateTimeField(
                              dateFormat: DateFormat("y/M/d"),
                              decoration:  InputDecoration(
                                  hintText: AppLocalizations.of(context).selectTheDate),
                              selectedDate: selectedDate,
                              mode: DateTimeFieldPickerMode.date,
                              onDateSelected: (DateTime value) {
                                setState(() {
                                  selectedDate = value;
                                  String formattedDate =
                                      DateFormat('yyyy-MM-dd')
                                          .format(value);
                                  this._date = formattedDate;

                                  String getslot = Auth().linkURL +'api/getDoctorTimeSlop?doctor_id=' +_doctor.text +'&date=' +formattedDate;
                                  var tempslot = "tempSlot";
                                  getDoctorSlot(getslot,tempslot);
                                });
                              }),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        child: new DropdownButtonFormField(
                          decoration: InputDecoration(labelText: AppLocalizations.of(context).availableSlot),


                          items: dropdownDoctorSlotItems,
                          onChanged: (newVal2) {


                            onchangedDropdownDoctorSlotItem(newVal2);
                          },

                          value: selectedDoctorSlot,
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        child: TextFormField(
                          controller: _remarks,
                          decoration: InputDecoration(
                              labelText: AppLocalizations.of(context).remarks,
                              hintText: AppLocalizations.of(context).giveYourRemarks),
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
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        child: new DropdownButtonFormField(
                          decoration: InputDecoration(labelText: AppLocalizations.of(context).appointmentStatus),
                          items: data3.map((item3) {
                            return new DropdownMenuItem(
                              child: new Text(item3),
                              value: item3,
                            );
                          }).toList(),
                          onChanged: (newVal3) {
                            setState(() {
                              this._mySelection3 = newVal3;
                              this.appointmentStatus = newVal3;
                            });
                          },
                          value: this.appointmentStatus,
                        ),
                      ),
                    ),
                  ),


                  Container(
                    width: MediaQuery.of(context).size.width*.9,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 20.0),
                      child: ElevatedButton(

                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            if (_firstclick) {
                              _firstclick = false;
                              makeAppointment(context);
                            }
                          }
                        },
                        child: Text(AppLocalizations.of(context).update),
                      ),
                    ),
                  )



                ],
              ),
            ),
          ],
        )));
  }
}
