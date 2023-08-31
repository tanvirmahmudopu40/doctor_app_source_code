import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hmz/appointment/todaysAppointment.dart';
import 'package:hmz/auth/providers/auth.dart';
import 'package:hmz/home/widgets/app_drawer.dart';
import 'package:hmz/home/widgets/bottom_navigation_bar.dart';
import 'package:hmz/prescription/screens/user_prescriptions_screen.dart';
import 'package:hmz/setting/setting.dart';
import 'package:hmz/utils/colors.dart';
import '../profile/fullProfile.dart';
import 'package:hmz/profile/changePassword.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:date_field/date_field.dart';

import 'dart:async';
import 'dart:convert';
import '../appointment/appointment.dart';
import '../appointment/showAppointment.dart';

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

  });
}

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dsh';

  String idd;
  String useridd;
  DashboardScreen(this.idd, this.useridd);

  @override
  DashboardScreenState createState() =>
      DashboardScreenState(this.idd, this.useridd);
}

class DashboardScreenState extends State<DashboardScreen> {
  String idd;
  String useridd;
  DashboardScreenState(this.idd, this.useridd);
  int len;

  Future<List<AppintmentDetails>> _responseFuture() async {
    final doctor_id = this.idd;
    // var data = await http.get(Auth().linkURL +
    //     "api/getMyAllAppoinmentList?group=doctor&id=" +
    //     this.idd);

    // final url = Auth().linkURL + "api/getMyAllAppoinmentList";
    //
    // final data = await http.post(
    //   Uri.parse(url),
    //   body: {
    //     'group': "doctor",
    //     'id': this.idd,
    //   },
    // );

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

    this.len = _lcdata.length;

    return _lcdata;
  }

  Future<List<AppintmentDetails>> allappointments;

  @override
  void initState() {
    super.initState();
    allappointments = _responseFuture();
  }

  AppColor appcolor = new AppColor();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).dashboard,
          style: TextStyle(
            color: appcolor.appbartext(),
            fontWeight: appcolor.appbarfontweight(),
          ),
        ),
        backgroundColor: appcolor.appbarbackground(),
        elevation: 0,
        bottomOpacity: .1,
        iconTheme: IconThemeData(color: appcolor.appbaricontheme()),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: GestureDetector(
              child: CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(
                    "https://image.flaticon.com/icons/png/512/147/147144.png"),
                backgroundColor: Colors.transparent,
              ),
              onTap: () {
                Navigator.of(context)
                    .pushReplacementNamed(FullProfile.routeName);
              },
            ),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: Container(
          padding: EdgeInsets.all(10),
          height: MediaQuery.of(context).size.height,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GridView.count(
                  shrinkWrap: true,
                  primary: false,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 10,
                  crossAxisCount: 2,
                  childAspectRatio: (100 / 100),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          shadowColor: Color.fromRGBO(0, 0, 0, .5),
                          elevation: 5,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Colors.amber[800],
                            ),
                            Padding(padding: EdgeInsets.all(5)),
                            Text(
                              AppLocalizations.of(context).todaysAppointment,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed(
                              ShowTodaysAppointmentScreen.routeName);
                        },
                      ),
                    ),
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            shadowColor: Color.fromRGBO(0, 0, 0, .5),
                            elevation: 5,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                color: Colors.amber[800],
                                size: 30,
                              ),
                              Padding(padding: EdgeInsets.all(5)),
                              Text(
                                AppLocalizations.of(context).addAppointment,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          onPressed: () {
                            Navigator.of(context).pushReplacementNamed(
                                AppointmentDetailsScreen.routeName);
                          },
                        ),
                      ),
                    ),
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            shadowColor: Color.fromRGBO(0, 0, 0, .5),
                            elevation: 5,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.list,
                                color: Colors.amber[800],
                                size: 30,
                              ),
                              Padding(padding: EdgeInsets.all(5)),
                              Text(
                                AppLocalizations.of(context).appointments,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          onPressed: () {
                            Navigator.of(context).pushReplacementNamed(
                                ShowAppointmentScreen.routeName);
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,

                          shadowColor: Color.fromRGBO(0, 0, 0, .5),
                          elevation: 5, // foreground
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.file_copy,
                              color: Colors.amber[800],
                              size: 30,
                            ),
                            Padding(padding: EdgeInsets.all(5)),
                            Text(
                              AppLocalizations.of(context).prescription,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed(
                              UserPrescriptionsScreen.routeName);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,

                          shadowColor: Color.fromRGBO(0, 0, 0, .5),
                          elevation: 5, // foreground
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person,
                              color: Colors.amber[800],
                              size: 30,
                            ),
                            Padding(padding: EdgeInsets.all(5)),
                            Text(
                              AppLocalizations.of(context).profile,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        onPressed: () {
                          Navigator.of(context)
                              .pushReplacementNamed(FullProfile.routeName);
                        },
                      ),
                    ),
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,

                            shadowColor: Color.fromRGBO(0, 0, 0, .5),
                            elevation: 5, // foreground
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.settings,
                                color: Colors.amber[800],
                                size: 30,
                              ),
                              Padding(padding: EdgeInsets.all(5)),
                              Text(
                                AppLocalizations.of(context).setting,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          onPressed: () {
                            Navigator.of(context)
                                .pushReplacementNamed(SettingScreen.routeName);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ])),
      bottomNavigationBar: AppBottomNavigationBar(screenNum: 0),
    );
  }
}
