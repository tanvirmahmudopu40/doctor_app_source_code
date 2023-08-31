import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hmz/utils/colors.dart';
import '../home/widgets/app_drawer.dart';
import 'fullProfile.dart';
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

class EditProfile extends StatefulWidget {
  static const routeName = '/editprofile';

  String idd;
  String useridd;
  EditProfile(this.idd, this.useridd);

  @override
  EditProfileState createState() => EditProfileState(this.idd, this.useridd);
}

class EditProfileState extends State<EditProfile> {
  String idd;
  String useridd;
  EditProfileState(this.idd, this.useridd);

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
    url = Auth().linkURL +"api/getDoctorProfile?id=";
    String urrr1 = url + "${this.useridd}";
    var res = await http.get( Uri.encodeFull(urrr1), headers: {"Accept": "application/json"});

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

      zname = _name.text;

      this._isloading = false;
    });

    return "Sucess";
  }

  @override
  void initState() {
    super.initState();
    getSWData();
  }

  Future<String> updateProfile(context) async {
    if (_name != zname || _password != "") {
      String posturl = Auth().linkURL + "api/updateDoctorProfile";

      final res = await http.post(
        posturl,
        body: {
          'email': this._email.text,
          'id': this.useridd,
          'name': this._name.text,
          'address': this._address.text,
          'phone': this._phone.text,
          'department': this._department.text,
        },
      );

      if (res.body == '"successful"') {
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
                          .pushReplacementNamed(FullProfile.routeName);
                    },
                  )
                ],
              );
            });

        return 'success';
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  AppLocalizations.of(context).failed,
                ),
                content: Text(
                    AppLocalizations.of(context).changesUpdatedNotSuccessfull),
                actions: [
                  FlatButton(
                    child: Text(AppLocalizations.of(context).ok),
                    onPressed: () {
                      Navigator.of(context)
                          .pushReplacementNamed(FullProfile.routeName);
                    },
                  )
                ],
              );
            });
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
                        .pushReplacementNamed(FullProfile.routeName);
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
        title: Text(
          AppLocalizations.of(context).editProfile,
          style: TextStyle(
            color: appcolor.appbartext(),
            fontWeight: appcolor.appbarfontweight(),
          ),
        ),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () =>
              Navigator.of(context).pushReplacementNamed(FullProfile.routeName),
        ),
        centerTitle: true,
        backgroundColor: appcolor.appbarbackground(),
        elevation: 0,
        bottomOpacity: .1,
        iconTheme: IconThemeData(color: appcolor.appbaricontheme()),
      ),
      body: (_isloading)
          ? Center(child: CircularProgressIndicator())
          : Container(
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
                        child: Center(
                          child: Container(
                            width: double.infinity,
                            child: TextFormField(
                              controller: _name,
                              decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context).name,
                                  hintText:
                                      AppLocalizations.of(context).enterName),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return AppLocalizations.of(context)
                                      .invalidName;
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
                            child: TextFormField(
                              controller: _email,
                              readOnly: true,
                              decoration: InputDecoration(
                                  labelText:
                                      '${AppLocalizations.of(context).email} (${AppLocalizations.of(context).notChangable})',
                                  hintText: AppLocalizations.of(context).email),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return AppLocalizations.of(context)
                                      .invalidEmail;
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
                            child: TextFormField(
                              controller: _address,
                              decoration: InputDecoration(
                                  labelText:
                                      AppLocalizations.of(context).address,
                                  hintText:
                                      AppLocalizations.of(context).address),
                              validator: (value) {
                                if (value.isEmpty || value.length < 5) {
                                  return AppLocalizations.of(context)
                                      .invalidAddress;
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
                            child: TextFormField(
                              controller: _phone,
                              decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context).phone,
                                  hintText: AppLocalizations.of(context).phone),
                              validator: (value) {
                                if (value.isEmpty || value.length < 5) {
                                  return AppLocalizations.of(context).phone;
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
                            child: TextFormField(
                              controller: _department,
                              decoration: InputDecoration(
                                  labelText:
                                      AppLocalizations.of(context).department,
                                  hintText:
                                      AppLocalizations.of(context).department),
                              validator: (value) {
                                if (value.isEmpty || value.length < 5) {
                                  return AppLocalizations.of(context)
                                      .invalidDepartment;
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * .9,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              updateProfile(context);
                            }
                          },
                          child: Text(AppLocalizations.of(context).update),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            )),
    );
  }
}
