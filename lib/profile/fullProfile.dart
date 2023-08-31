import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hmz/utils/colors.dart';
import '../profile/editProfile.dart';
import '../home/widgets/app_drawer.dart';
import 'changePassword.dart';
import '../home/widgets/bottom_navigation_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:date_field/date_field.dart';

import 'dart:async';
import 'dart:convert';
import '../auth/providers/auth.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FullProfile extends StatefulWidget {
  static const routeName = '/fullprofile';

  String idd;
  String useridd;
  FullProfile(this.idd, this.useridd);

  @override
  FullProfileState createState() => FullProfileState(this.idd, this.useridd);
}

class FullProfileState extends State<FullProfile> {
  String idd;
  String useridd;
  FullProfileState(this.idd, this.useridd);

  final _formKey = GlobalKey<FormState>();

  String url;

  TextEditingController _name = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _address = TextEditingController();
  TextEditingController _department = TextEditingController();

  List data = new List();
  String zname;

  bool _isloading = true;

  Future<String> getSWData() async {
    url = Auth().linkURL + "api/getDoctorProfile?id=";
    String urrr1 = url + "${this.useridd}";
    var res = await http
        .get(Uri.encodeFull(urrr1), headers: {"Accept": "application/json"});

    // final url = Auth().linkURL + "api/getDoctorProfile";
    // var res = await http.post(
    //   Uri.parse(url),
    //   body: {
    //     'id': useridd,
    //   },
    // );

    var resBody = json.decode(res.body);

    setState(() {
      _email.text = resBody['email'];
      _name.text = resBody['name'];
      _phone.text = resBody['phone'];
      _department.text = resBody['department_name'];
      _address.text = resBody['address'];

      setState(() {
        this._isloading = false;
      });
    });

    return "Sucess";
  }

  @override
  void initState() {
    super.initState();

    getSWData();
  }

  Future<String> changePassword(context) async {
    if (_name != zname || _password != "") {
      String posturl = Auth().linkURL + "api/updateProfile";

      final res = await http.post(
        posturl,
        body: {
          'email': this._email.text,
          'password': this._password.text,
          'id': this.useridd,
          'name': this._name.text,
        },
      );

      if (res.statusCode == 200) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  AppLocalizations.of(context).success,
                ),
                content: Text(
                    AppLocalizations.of(context).changesUpdatedSuccessfuly),
                actions: [
                  FlatButton(
                    child: Text(AppLocalizations.of(context).ok),
                    onPressed: () {
                      Navigator.of(context)
                          .pushReplacementNamed(Profile.routeName);
                    },
                  )
                ],
              );
            });

        return 'success';
      } else {
        return "error";
      }
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context).invalid),
              content: Text(AppLocalizations.of(context).invalidInput),
              actions: [
                FlatButton(
                  child: Text(AppLocalizations.of(context).ok),
                  onPressed: () {
                    Navigator.of(context)
                        .pushReplacementNamed(Profile.routeName);
                  },
                )
              ],
            );
          });
    }
  }

  AppColor appcolor = new AppColor();
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
        ),
        centerTitle: true,
        backgroundColor: appcolor.appbarbackground(),
        elevation: 0,
        bottomOpacity: .1,
        iconTheme: IconThemeData(color: appcolor.appbaricontheme()),
        actions: [
          if (_isloading == false)
            ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  primary: Colors.transparent,
                  elevation: 0.0,
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed(EditProfile.routeName);
                },
                icon: Icon(
                  Icons.edit,
                  color: appcolor.appbaricontheme(),
                ),
                label: Text(
                  AppLocalizations.of(context).edit,
                  style: TextStyle(
                    color: appcolor.appbaricontheme(),
                  ),
                )),
        ],
      ),
      body: (_isloading)
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(children: [
              Center(
                child: Container(
                  padding: EdgeInsets.only(top: 20, bottom: 15),
                  child: CircleAvatar(
                    radius: 100,
                    backgroundImage: NetworkImage(
                        "https://image.flaticon.com/icons/png/512/147/147144.png"),
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
              Center(
                child: Container(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_name.text,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        )),
                    SizedBox(
                      width: 5,
                    ),
                    InkWell(
                      child: CircleAvatar(
                        radius: 15,
                        child: Icon(
                          Icons.edit,
                          color: Colors.black,
                          size: 16,
                        ),
                        backgroundColor: Colors.transparent,
                      ),
                      onTap: () {
                        Navigator.of(context).pushNamed(EditProfile.routeName);
                      },
                    ),
                  ],
                )),
              ),
              SizedBox(height: 30),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * .9,
                  child: ListTile(
                    leading: Icon(Icons.email),
                    title: Text(_email.text),
                    trailing: PopupMenuButton<int>(
                      itemBuilder: (context) => [
                        PopupMenuItem<int>(
                            value: 0,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit,
                                  color: Colors.orange,
                                ),
                                const SizedBox(
                                  width: 7,
                                ),
                                Text(AppLocalizations.of(context).edit)
                              ],
                            )),
                      ],
                      onSelected: (item) {
                        if (item == 0) {
                          Navigator.of(context)
                              .pushNamed(EditProfile.routeName);
                        }
                      },
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * .9,
                  child: ListTile(
                    leading: Icon(Icons.phone),
                    title: Text(_phone.text),
                    trailing: PopupMenuButton<int>(
                      itemBuilder: (context) => [
                        PopupMenuItem<int>(
                            value: 0,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit,
                                  color: Colors.orange,
                                ),
                                const SizedBox(
                                  width: 7,
                                ),
                                Text(AppLocalizations.of(context).edit)
                              ],
                            )),
                      ],
                      onSelected: (item) {
                        if (item == 0) {
                          Navigator.of(context)
                              .pushNamed(EditProfile.routeName);
                        }
                      },
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * .9,
                  child: ListTile(
                    leading: Icon(Icons.work_outline),
                    title: Text(_department.text),
                    trailing: PopupMenuButton<int>(
                      itemBuilder: (context) => [
                        PopupMenuItem<int>(
                            value: 0,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit,
                                  color: Colors.orange,
                                ),
                                const SizedBox(
                                  width: 7,
                                ),
                                Text(AppLocalizations.of(context).edit)
                              ],
                            )),
                      ],
                      onSelected: (item) {
                        if (item == 0) {
                          Navigator.of(context)
                              .pushNamed(EditProfile.routeName);
                        }
                      },
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * .9,
                  child: ListTile(
                    leading: Icon(Icons.home),
                    title: Text(_address.text),
                    trailing: PopupMenuButton<int>(
                      itemBuilder: (context) => [
                        PopupMenuItem<int>(
                            value: 0,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit,
                                  color: Colors.orange,
                                ),
                                const SizedBox(
                                  width: 7,
                                ),
                                Text(AppLocalizations.of(context).edit)
                              ],
                            )),
                      ],
                      onSelected: (item) {
                        if (item == 0) {
                          Navigator.of(context)
                              .pushNamed(EditProfile.routeName);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ])),
      bottomNavigationBar: AppBottomNavigationBar(screenNum: 2),
    );
  }
}
