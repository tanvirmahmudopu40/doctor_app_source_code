import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hmz/auth/providers/auth.dart';
import 'package:hmz/home/widgets/app_drawer.dart';
import 'package:hmz/language/provider/language_provider.dart';
import 'package:hmz/utils/colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:date_field/date_field.dart';

import 'dart:async';
import 'dart:convert';
import 'showAppointment.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:table_calendar/table_calendar.dart';


import 'package:searchable_dropdown/searchable_dropdown.dart';

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
      name: json['img_url'] as String,
      image: json['name'] as String,
    );
  }
}

class AppointmentDetailsScreen extends StatefulWidget {
  static const routeName = '/Appointmentdetail';

  String idd;
  String useridd;
  AppointmentDetailsScreen(this.idd, this.useridd);

  @override
  AppointmentDetailsScreenState createState() =>
      AppointmentDetailsScreenState(this.idd, this.useridd);
}

class AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  String idd;
  String useridd;
  AppointmentDetailsScreenState(this.idd, this.useridd);

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List doctorSlotList = [];
  bool erroravailableslot = false;
  bool errorpatientselect = false;

  final _formKey = GlobalKey<FormState>();
  String patient;
  var patientlist = "";
  Future<List<Patient>> users;

  String _mySelection;
  String _mySelection2;
  String _mySelection3;

  final String url = Auth().linkURL + "api/getPatientList?id=";

  List patientdata = List();
  List slotdata = List();
  List statusdata = [
    'Confirmed',
    'Pending Confirmation',
    'Treated',
    'Cancelled'
  ];
  String availableSlot = '';
  String appointmentStatus;
  TextEditingController _ddoctor = TextEditingController();
  DateTime selectedDate;
  bool _isloading = true;

  

  String _date = "";
  final _remarks = TextEditingController();

  List<dynamic> buildDoctorSlotItems(List doctorslot) {
    List<String> itemss = List();
    doctorSlotList = new List();
    for (var zdoctor in doctorslot) {
      doctorSlotList
          .add([zdoctor['s_time'] + " To " + zdoctor['e_time'] + " SL " + zdoctor['serial_no'], false]);

      itemss.add(
        zdoctor['s_time'] + " To " + zdoctor['e_time']  + " SL " + zdoctor['serial_no'],
      );
    }

    return itemss;
  }

  Future<String> getDoctorSlot(getslot) async {
    var res = await http
        .get(Uri.encodeFull(getslot), headers: {"Accept": "application/json"});
    var resBody = json.decode(res.body);

    setState(() {
      slotdata = resBody;

      buildDoctorSlotItems(resBody);
    });

    return "success";
  }

  Future<String> getSWData() async {
    String urrr1 = url + "${this.useridd}";
    var res = await http.get(urrr1, headers: {"Accept": "application/json"});
    var resBody = json.decode(res.body);

    setState(() {
      patientdata = resBody;
      
      _isloading = false;
    });

    return "Sucess";
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _ddoctor = new TextEditingController(text: this.idd);
      String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      this._date = formattedDate;
      String getslot = Auth().linkURL +
          'api/getDoctorTimeSlop?doctor_id=' +
          _ddoctor.text +
          '&date=' +
          this._date;
      
      getDoctorSlot(getslot);
    });
    _mySelection = "";
    this.getSWData();
    _mySelection3 = statusdata[1];
    appointmentStatus = _mySelection3;
  }

  String success = "";
  Future<String> makeAppointment(context) async {
    String posturl = Auth().linkURL + "api/addAppointment";

    final res = await http.post(
      posturl,
      body: {
        'patient': this.patient,
        'doctor': this._ddoctor.text,
        'date': this._date,
        'status': this.appointmentStatus,
        'time_slot': this.availableSlot,
        'user_type': 'doctor',
        'remarks': this._remarks.text,
      },
    );

    if (res.statusCode == 200) {
      this.success = "success";

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context).newAppointment),
              content: Text("Appointment has been created."),
              actions: [
                FlatButton(
                  child: Text("OK"),
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

  AppColor appcolor = new AppColor();
 

  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    bool _firstclick = true;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context).addAppointment,
            style: TextStyle(
              color: appcolor.appbartext(),
            fontWeight: appcolor.appbarfontweight(),
            ),
          ),
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
          ),
          centerTitle: true,
          backgroundColor: appcolor.appbarbackground(),
          elevation: 0,
          bottomOpacity: .1,
          
          iconTheme: IconThemeData(color: appcolor.appbaricontheme(),),
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
                          child: Container(
                            child: Container(
                              width: double.infinity,
                              child: SearchableDropdown.single(
                                displayClearIcon: false,
                                items: patientdata.map((item) {
                                  return new DropdownMenuItem(
                                    child: Container(
                                      padding:
                                          EdgeInsets.only(top: 15, bottom: 15),
                                      child: Row(
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
                                          Text("${item['name']} [ID: ${item['id']}]"),
                                        ],
                                      ),
                                    ),
                                    value: item,
                                  );
                                }).toList(),
                                value: _mySelection,
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
                                    _mySelection = value["id"];
                                    patient = value["id"];
                                   
                                  });
                                },
                                isExpanded: true,
                              ),
                            ),
                          ),
                        ),

                        (errorpatientselect)
                            ? Container(
                                child: Text(
                                  " No patient selected",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            : Container(),

                       

                        Container(
                          padding: EdgeInsets.all(20),
                          child: TableCalendar(
                            firstDay: DateTime.now(),
                            lastDay: DateTime.utc(2030, 3, 14),
                            focusedDay: _focusedDay,
                            headerStyle: HeaderStyle(
                                formatButtonVisible: false,
                                titleCentered: true),


                            selectedDayPredicate: (day) {
                              return isSameDay(_selectedDay, day);
                            },

                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay; 
                               

                                String formattedDate = DateFormat('yyyy-MM-dd')
                                    .format(_selectedDay);
                                this._date = formattedDate;
                                
                                String getslot = Auth().linkURL +
                                    'api/getDoctorTimeSlop?doctor_id=' +
                                    _ddoctor.text +
                                    '&date=' +
                                    formattedDate;
                                getDoctorSlot(getslot);

                                availableSlot = "";

                                
                              });
                            },

                            calendarFormat: CalendarFormat.twoWeeks,
                            
                            calendarStyle: CalendarStyle(
                              defaultTextStyle: TextStyle(
                                fontSize: 15,
                              ),
                              isTodayHighlighted: false,
                              cellMargin: EdgeInsets.all(5),
                              selectedDecoration: BoxDecoration(
                                color: Colors.orange[800].withOpacity(.7),
                                shape: BoxShape.circle,
                              ),
                              selectedTextStyle: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            onPageChanged: (focusedDay) {
                              _focusedDay = focusedDay;
                            },
                            locale: langProvider.locale.languageCode,
                            pageJumpingEnabled: true,
                            pageAnimationEnabled: true,
                          ),
                        ),

                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                          child: Center(
                            child: Container(
                              width: double.infinity,
                              height: (true) ? 180 : 0,
                              decoration: BoxDecoration(
                                  border: Border(
                                top: BorderSide(
                                    width: .5, color: Colors.black54),
                                bottom: BorderSide(
                                    width: .5, color: Colors.black54),
                              )),
                              child: Scrollbar(
                                child: GridView.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 5,
                                      mainAxisSpacing: 5,
                                      childAspectRatio: (50 / 23),
                                    ),
                                    shrinkWrap: true,
                                    primary: false,
                                    padding: const EdgeInsets.all(5),
                                    physics: ClampingScrollPhysics(),
                                    itemCount: doctorSlotList.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: TextButton(
                                          style: (doctorSlotList[index][1] ==
                                                  true)
                                              ? ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          Colors.amber[800]),
                                                )
                                              : ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          Colors.white),
                                                ),
                                          onPressed: () {
                                            setState(() {
                                              for (var listdatas = 0;
                                                  listdatas <
                                                      doctorSlotList.length;
                                                  listdatas++) {
                                                if (doctorSlotList[listdatas]
                                                        [0] !=
                                                    doctorSlotList[index][0]) {
                                                  doctorSlotList[listdatas][1] =
                                                      false;
                                                }
                                              }
                                              doctorSlotList[index][1] = true;
                                              availableSlot =
                                                  doctorSlotList[index][0];
                                              erroravailableslot = false;


                                            });
                                          },
                                          child: Container(
                                            child: Center(
                                                child: Text(
                                              "${doctorSlotList[index][0]}",
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: (!doctorSlotList[index]
                                                          [1])
                                                      ? Colors.black
                                                      : Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ),
                          ),
                        ),

                        (erroravailableslot)
                            ? Container(
                                child: Text(
                                  " No slot selected",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            : Container(),

                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: Center(
                            child: Container(
                              width: double.infinity,
                              child: TextFormField(
                                controller: _remarks,
                                decoration: InputDecoration(
                                    labelText:
                                        AppLocalizations.of(context).remarks,
                                    hintText: AppLocalizations.of(context)
                                        .giveYourRemarks),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return AppLocalizations.of(context)
                                        .invalidInput;
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
                                decoration: InputDecoration(
                                    labelText: AppLocalizations.of(context)
                                        .appointmentStatus),
                                items: statusdata.map((item3) {
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
                                value: this._mySelection3,
                              ),
                            ),
                          ),
                        ),

                        Container(
                          width: MediaQuery.of(context).size.width * .9,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                
                                if (availableSlot == "" ||
                                    availableSlot == null) {
                                  setState(() {
                                    erroravailableslot = true;
                                  });
                                } else if (patient == "" || patient == null) {
                                  setState(() {
                                    errorpatientselect = true;
                                  });
                                } else {
                                  if (_firstclick) {
                                    _firstclick = false;
                                    makeAppointment(context);
                                  }
                                }
                              }
                            },
                            child: Text('Save'),
                          ),
                        ),
                        
                      ],
                    ),
                  ),
                ],
              )));
  }
}

