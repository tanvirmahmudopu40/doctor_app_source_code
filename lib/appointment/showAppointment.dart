import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hmz/appointment/appointment.dart';
import 'package:hmz/home/widgets/app_drawer.dart';
import 'package:hmz/utils/colors.dart';
import '../home/widgets/bottom_navigation_bar.dart';
import 'package:provider/provider.dart';
import '../auth/providers/auth.dart';
import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';
import '../jitsi/jitsi.dart';

import 'editAppointment.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppintmentDetails {
  final String id;
  final String patient_name;
  final String doctor_name;
  final String date;
  final String start_time;
  final String end_time;
  final String status;
  final String remarks;
  final String jitsi_link;
  final String serial_no;
  final String visit_type_name;
  final String payment_id;
  final String amount;
  final String hospital_appointment_id;

  AppintmentDetails({
    this.id,
    this.patient_name,
    this.doctor_name,
    this.date,
    this.start_time,
    this.end_time,
    this.remarks,
    this.status,
    this.jitsi_link,
    this.serial_no,
    this.visit_type_name,
    this.payment_id,
    this.amount,
    this.hospital_appointment_id,
  });
}

class ShowAppointmentScreen extends StatefulWidget {
  static const routeName = '/showappointmentlist';

  String idd;
  String useridd;
  ShowAppointmentScreen(this.idd, this.useridd);

  @override
  ShowAppointmentScreenState createState() =>
      ShowAppointmentScreenState(this.idd, this.useridd);
}

class ShowAppointmentScreenState extends State<ShowAppointmentScreen> {
  String idd;
  String useridd;
  ShowAppointmentScreenState(this.idd, this.useridd);

  List<AppintmentDetails> _tempappointmentlistdata = [];
  List<AppintmentDetails> _appointmentlistdata = [];
  bool erroralllistdata = true;

  Future<List<AppintmentDetails>> _responseFuture() async {
    final doctor_id = this.idd;

    final url = Auth().linkURL + "api/getMyAllAppoinmentList?id=$doctor_id&group=doctor";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var jsondata = json.decode(response.body);

      List<AppintmentDetails> _appointmentlistdata = [];

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
          serial_no: u["serial_no"],
          visit_type_name: u["visit_type_name"],
          payment_id: u["payment_id"],
          amount: u["amount"],
          hospital_appointment_id: u["hospital_appointment_id"],
        );
        _appointmentlistdata.add(subdata);
      }

      setState(() {
        _tempappointmentlistdata = _appointmentlistdata;
        erroralllistdata = false;
      });

      return _appointmentlistdata;
    } else {
      // Handle error here
      print("Error: ${response.statusCode}");
      return [];
    }
  }


  @override
  void initState() {
    super.initState();

    _responseFuture();
  }

  TextEditingController _searchappointment = TextEditingController();
  Future<String> searchallappointmentList(var appointmentdata) async {
    setState(() {
      _tempappointmentlistdata = [];

      if (appointmentdata == "") {
        _tempappointmentlistdata = _appointmentlistdata;
      } else {
        for (var item in _appointmentlistdata) {
          if (item.patient_name
              .toLowerCase()
              .contains(appointmentdata.toString().toLowerCase())) {
            _tempappointmentlistdata.add(item);
          }
        }
      }
    });
    return "as";
  }

  AppColor appcolor = new AppColor();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).appointmentList,
          style: TextStyle(
            color: appcolor.appbartext(),
            fontWeight: appcolor.appbarfontweight(),
          ),
        ),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
        ),
        centerTitle: true,
        backgroundColor: appcolor.appbarbackground(),
        elevation: 0,
        bottomOpacity: .1,
        iconTheme: IconThemeData(color: appcolor.appbaricontheme()),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.add,
            ),
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(AppointmentDetailsScreen.routeName);
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: 10,
              left: 25,
              right: 25,
            ),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
                width: double.infinity,
                child: TextFormField(
                  controller: _searchappointment,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: AppLocalizations.of(context).searchbypatientname,
                    hintText: AppLocalizations.of(context).patient,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(top: 10, left: 10, bottom: 10),
                      child: Icon(Icons.search),
                    ),
                  ),
                  onChanged: (value) {
                    searchallappointmentList(value);

                    return null;
                  },
                ),
              ),
            ),
          ),
          (erroralllistdata)
              ? Container(
                  height: MediaQuery.of(context).size.height * .5,
                  child: Center(child: CircularProgressIndicator()))
              : (_tempappointmentlistdata.length == 0)
                  ? Container(
                      height: MediaQuery.of(context).size.height * .5,
                      child: Center(
                        child: Text(AppLocalizations.of(context).nodatatoshow),
                      ),
                    )
                  : Container(
                      child: ListView.builder(
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount: _tempappointmentlistdata.length,
                          itemBuilder: (BuildContext context, int index) {
                            Color statusColor;
                            if (_tempappointmentlistdata[index].status ==
                                "Confirmed") {
                              statusColor = Colors.green;
                            } else if (_tempappointmentlistdata[index].status ==
                                "Requested") {
                              statusColor = Colors.amber[800];
                            } else if (_tempappointmentlistdata[index].status ==
                                "Cancelled") {
                              statusColor = Colors.red;
                            } else if (_tempappointmentlistdata[index].status ==
                                "Treated") {
                              statusColor = Colors.black;
                            } else if (_tempappointmentlistdata[index].status ==
                                "Pending Confirmation") {
                              statusColor = Colors.amber[800];
                            }

                            return Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              padding: EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue[300].withOpacity(0.1),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .37,
                                        child: Column(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(10),
                                              height: 100,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .25,
                                              child: CircleAvatar(
                                                backgroundColor:
                                                    Colors.blue[200],
                                                child: Icon(
                                                  Icons.person,
                                                  size: 60,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                (_tempappointmentlistdata[index]
                                                            .status ==
                                                        "Confirmed")
                                                    ? Expanded(
                                                        child: Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 10),
                                                          width: 35,
                                                          height: 30,
                                                          child: ElevatedButton(
                                                            style: ButtonStyle(
                                                                padding: MaterialStateProperty.all(
                                                                    EdgeInsets.only(
                                                                        top: 2,
                                                                        bottom:
                                                                            2)),
                                                                backgroundColor:
                                                                    MaterialStateProperty.all(
                                                                        Colors
                                                                            .white),
                                                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    side: BorderSide(
                                                                        color:
                                                                            Colors.black12)))),
                                                            onPressed: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) => Jitsi(
                                                                        link: _tempappointmentlistdata[index]
                                                                            .jitsi_link,
                                                                        p_name: _tempappointmentlistdata[index]
                                                                            .patient_name,
                                                                        d_name: _tempappointmentlistdata[index]
                                                                            .doctor_name,
                                                                        d_date: _tempappointmentlistdata[index]
                                                                            .date,
                                                                        s_time: _tempappointmentlistdata[index]
                                                                            .start_time,
                                                                        e_time:
                                                                            _tempappointmentlistdata[index].end_time)),
                                                              );
                                                            },
                                                            child: Icon(
                                                              Icons.video_call,
                                                              size: 20,
                                                              color: Colors
                                                                  .amber[800],
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : Container(),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    width: 35,
                                                    height: 30,
                                                    child: ElevatedButton(
                                                      style: ButtonStyle(
                                                          padding:
                                                              MaterialStateProperty.all(
                                                                  EdgeInsets.only(
                                                                      top: 2,
                                                                      bottom:
                                                                          2)),
                                                          backgroundColor:
                                                              MaterialStateProperty.all(
                                                                  Colors.white),
                                                          shape: MaterialStateProperty.all<
                                                                  RoundedRectangleBorder>(
                                                              RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          10),
                                                                  side: BorderSide(color: Colors.black12)))),
                                                      onPressed: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => EditAppointmentDetailsScreen(
                                                                    this.idd,
                                                                    this
                                                                        .useridd,
                                                                    _tempappointmentlistdata[
                                                                            index]
                                                                        .id)));
                                                      },
                                                      child: Icon(
                                                        Icons.edit,
                                                        size: 20,
                                                        color:
                                                            Colors.amber[800],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    width: 30,
                                                    height: 30,
                                                    child: ElevatedButton(
                                                      style: ButtonStyle(
                                                          padding:
                                                              MaterialStateProperty.all(
                                                                  EdgeInsets.only(
                                                                      top: 2,
                                                                      bottom:
                                                                          2)),
                                                          backgroundColor:
                                                              MaterialStateProperty.all(
                                                                  Colors.white),
                                                          shape: MaterialStateProperty.all<
                                                                  RoundedRectangleBorder>(
                                                              RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          10),
                                                                  side: BorderSide(color: Colors.black12)))),
                                                      onPressed: () {
                                                        Future<String>
                                                            deleteAppointment(
                                                                context) async {
                                                          String posturl = Auth()
                                                                  .linkURL +
                                                              "api/deleteAppointment?id=${_tempappointmentlistdata[index].id}";
                                                          var res =
                                                              await http.get(
                                                            posturl,
                                                            headers: {
                                                              "Accept":
                                                                  "application/json"
                                                            },
                                                          );

                                                          var message =
                                                              res.body;
                                                          if (res.statusCode ==
                                                                  200 &&
                                                              res.body ==
                                                                  '\"success\"') {
                                                            await showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return AlertDialog(
                                                                    title: Text(
                                                                        AppLocalizations.of(context)
                                                                            .success),
                                                                    content: Text(
                                                                        AppLocalizations.of(context)
                                                                            .appointmentWasDeleted),
                                                                    actions: [
                                                                      FlatButton(
                                                                        child: Text(
                                                                            AppLocalizations.of(context).ok),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pushReplacementNamed(ShowAppointmentScreen.routeName);
                                                                        },
                                                                      )
                                                                    ],
                                                                  );
                                                                });

                                                            return 'success';
                                                          } else if (res
                                                                      .statusCode ==
                                                                  200 &&
                                                              res.body ==
                                                                  '\"failed\"') {
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return AlertDialog(
                                                                    title: Text(
                                                                        AppLocalizations.of(context)
                                                                            .failed),
                                                                    content: Text(
                                                                        AppLocalizations.of(context)
                                                                            .appointmentWasNotDeleted),
                                                                    actions: [
                                                                      FlatButton(
                                                                        child: Text(
                                                                            AppLocalizations.of(context).close),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pushReplacementNamed(ShowAppointmentScreen.routeName);
                                                                        },
                                                                      )
                                                                    ],
                                                                  );
                                                                });
                                                            return "failed";
                                                          } else {
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return AlertDialog(
                                                                    title: Text(
                                                                        AppLocalizations.of(context)
                                                                            .failed),
                                                                    content: Text(
                                                                        AppLocalizations.of(context)
                                                                            .appointmentWasNotDeleted),
                                                                    actions: [
                                                                      FlatButton(
                                                                        child: Text(
                                                                            AppLocalizations.of(context).close),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pushReplacementNamed(ShowAppointmentScreen.routeName);
                                                                        },
                                                                      )
                                                                    ],
                                                                  );
                                                                });

                                                            return 'failed';
                                                          }
                                                        }

                                                        setState(() {
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                title: Text(AppLocalizations.of(
                                                                        context)
                                                                    .deleteappointmentconfirmation),
                                                                content: Text(
                                                                    AppLocalizations.of(
                                                                            context)
                                                                        .doyoureallywanttodeletetheappointment),
                                                                actions: [
                                                                  TextButton(
                                                                    child: Text(
                                                                        AppLocalizations.of(context)
                                                                            .close),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pushReplacementNamed(
                                                                              ShowAppointmentScreen.routeName);
                                                                    },
                                                                  ),
                                                                  TextButton(
                                                                    child: Text(
                                                                        AppLocalizations.of(context)
                                                                            .delete),
                                                                    onPressed:
                                                                        () {
                                                                      deleteAppointment(
                                                                          context);
                                                                    },
                                                                  )
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        });
                                                      },
                                                      child: Icon(
                                                        Icons.delete,
                                                        size: 20,
                                                        color:
                                                            Colors.amber[800],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .60,
                                              child: Text(
                                                "${_tempappointmentlistdata[index].patient_name}",
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 3,
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  child: Icon(
                                                    Icons.event_note,
                                                    size: 16,
                                                    color: Colors.amber[800],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    child: Text(
                                                      "Appointment id: ${_tempappointmentlistdata[index].hospital_appointment_id}",
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 2,
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  child: Icon(
                                                    Icons.event_note,
                                                    size: 16,
                                                    color: Colors.amber[800],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    child: Text(
                                                      "${AppLocalizations.of(context).remarks}: ${_tempappointmentlistdata[index].remarks}",
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 2,
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  child: Icon(
                                                    Icons.event,
                                                    size: 16,
                                                    color: Colors.amber[800],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Container(
                                                  child: Text(
                                                    " ${_tempappointmentlistdata[index].date}",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 2,
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.amber[800],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  child: Icon(
                                                    Icons.access_time_sharp,
                                                    size: 16,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Container(
                                                  child: Text(
                                                    "${_tempappointmentlistdata[index].start_time} - ${_tempappointmentlistdata[index].end_time}",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 3,
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  child: Icon(
                                                    Icons.event_note,
                                                    size: 16,
                                                    color: Colors.amber[800],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    child: Text(
                                                      "Serial No: ${_tempappointmentlistdata[index].serial_no}",
                                                      overflow:
                                                      TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 3,
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  child: Icon(
                                                    Icons.event_note,
                                                    size: 16,
                                                    color: Colors.amber[800],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    child: Text(
                                                      "Visit Type: ${_tempappointmentlistdata[index].visit_type_name}",
                                                      overflow:
                                                      TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 3,
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  child: Icon(
                                                    Icons.event_note,
                                                    size: 16,
                                                    color: Colors.amber[800],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    child: Text(
                                                      "Invoice No: ${_tempappointmentlistdata[index].payment_id}",
                                                      overflow:
                                                      TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 3,
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  child: Icon(
                                                    Icons.event_note,
                                                    size: 16,
                                                    color: Colors.amber[800],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    child: Text(
                                                      "Amount: ${_tempappointmentlistdata[index].amount}",
                                                      overflow:
                                                      TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 2,
                                            ),
                                            Text(
                                              "${_tempappointmentlistdata[index].status}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: statusColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                    )
        ],
      ),
      bottomNavigationBar: AppBottomNavigationBar(screenNum: 1),
    );
  }
}
