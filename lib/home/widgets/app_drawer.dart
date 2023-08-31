import 'package:flutter/material.dart';
import 'package:hmz/appointment/todaysAppointment.dart';
import 'package:hmz/dashboard/dashboard.dart';
import 'package:hmz/prescription/screens/prescription_detail_screen.dart';
import 'package:hmz/profile/fullProfile.dart';
import '../../setting/setting.dart';
import '../../prescription/screens/user_prescriptions_screen.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth.dart';

import '../../appointment/appointment.dart';
import '../../appointment/showAppointment.dart';

import '../../jitsi/jitsi.dart';
import '../../profile/changePassword.dart';
import '../../dashboard/dashboard.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            AppBar(
               backgroundColor: Colors.amber,
              toolbarHeight: 150,
              title: Center(child: Text('Doctor Express')),
              automaticallyImplyLeading: false,
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text(AppLocalizations.of(context).dashboard),
              onTap: () {
                Navigator.of(context)
                    .pushReplacementNamed(DashboardScreen.routeName);
              },
            ),

            Divider(height: 3,),

            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                leading: Icon(Icons.list, 
                ),
                title: Text(AppLocalizations.of(context).appointment),
                children: <Widget>[

                  Padding(
                    padding: const EdgeInsets.only(left:20),
                    child: ListTile(
                      leading: Icon(Icons.book,
                      ),
                      title: Text(AppLocalizations.of(context).appointmentRequest),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed(
                            AppointmentDetailsScreen.routeName);
                      },
                    ),
                  ),

                  Padding(

                    padding: const EdgeInsets.only(left:20),
                    child: ListTile(
                      leading: Icon(Icons.today,
                      ),
                      title: Text(AppLocalizations.of(context).todaysAppointment),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed(ShowTodaysAppointmentScreen.routeName);
                      },
                    ),
                  ),

                  

                  


                  Padding(
                    padding: const EdgeInsets.only(left:20),
                    child: ListTile(
                      leading: Icon(Icons.list, 
                      ),
                      title: Text(AppLocalizations.of(context).appointmentList),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed(ShowAppointmentScreen.routeName);
                      },
                    ),
                  ),

                  
                ],
              ),
            ),

            Divider(height: 3,),

            ListTile(
              leading: Icon(Icons.file_copy),
              title: Text( AppLocalizations.of(context).prescription),
              onTap: () {
                Navigator.of(context).pushReplacementNamed(UserPrescriptionsScreen.routeName);
              },
            ),


           
            
            
            Divider(height: 2,),
            ListTile(
              leading: Icon(Icons.person),
              title: Text(AppLocalizations.of(context).profile),
              onTap: () {
                Navigator.of(context).pushReplacementNamed(FullProfile.routeName);
              },
            ),

            Divider(height: 2,),

            ListTile(
              leading: Icon(Icons.settings),
              title: Text( AppLocalizations.of(context).setting),
              onTap: () {
                Navigator.of(context).pushReplacementNamed(SettingScreen.routeName);
              },
            ),

            

            

           
            Divider(height: 3,),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text(AppLocalizations.of(context).logout),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/');
                
                Provider.of<Auth>(context, listen: false).logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
