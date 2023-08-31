import 'package:flutter/material.dart';
import 'package:hmz/appointment/todaysAppointment.dart';
import 'package:hmz/prescription/screens/add_prescription.dart';
import 'package:hmz/prescription/screens/user_prescriptions_screen.dart';
import 'profile/editProfile.dart';
import 'profile/fullProfile.dart';
import 'setting/setting.dart';
import 'auth/providers/auth.dart';
import 'auth/screens/auth_screen.dart';
import 'prescription/screens/prescription_detail_screen.dart';
import 'package:provider/provider.dart';
import 'prescription/screens/user_prescriptions_screen.dart';
import 'home/screens/splash-screen.dart';

import 'appointment/appointment.dart';
import 'appointment/showAppointment.dart';
import 'appointment/editAppointment.dart';

import 'jitsi/jitsi.dart';
import 'dashboard/dashboard.dart';
import 'profile/changePassword.dart';

import 'l10n/l10n.dart';
import 'language/provider/language_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    
    SystemUiOverlayStyle(  
      statusBarColor: Colors.transparent,
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  
  String appointmentid;

  @override
  Widget build(BuildContext context) {
    

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),

        ChangeNotifierProvider(
          create: (ctx) => LanguageProvider(),
        ),

        
        

        
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) {
          final langProvider = Provider.of<LanguageProvider>(ctx);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Doctor Express',
            theme: ThemeData(
              primarySwatch: Colors.purple,
              accentColor: Colors.deepOrange,
              fontFamily: 'Poppins',
            ),
              locale: langProvider.locale,
              supportedLocales: L10n.all,
              localizationsDelegates: [
                AppLocalizations.delegate, 
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
            home: auth.isAuth
                ? DashboardScreen(auth.particularId, auth.userId)
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen(),
                  ),
            routes: {
              
              DashboardScreen.routeName: (ctx) =>
                  DashboardScreen(auth.particularId, auth.userId),
              PrescriptionDetailScreen.routeName: (ctx) => PrescriptionDetailScreen(auth.particularId, auth.userId),
              AppointmentDetailsScreen.routeName: (ctx) =>
                  AppointmentDetailsScreen(auth.particularId, auth.userId),
              ShowTodaysAppointmentScreen.routeName: (ctx) =>
                  ShowTodaysAppointmentScreen(auth.particularId, auth.userId),
              ShowAppointmentScreen.routeName: (ctx) => ShowAppointmentScreen(auth.particularId, auth.userId),
              EditAppointmentDetailsScreen.routeName: (ctx) => EditAppointmentDetailsScreen(auth.particularId, auth.userId, appointmentid ),
                
              Jitsi.routeName: (ctx) => Jitsi(),

              
              Profile.routeName: (ctx) => Profile(auth.particularId, auth.userId),
              FullProfile.routeName: (ctx) => FullProfile(auth.particularId,auth.userId),
              EditProfile.routeName: (ctx) => EditProfile(auth.particularId,auth.userId),

              
              UserPrescriptionsScreen.routeName: (ctx) => UserPrescriptionsScreen(auth.particularId,auth.userId),
              AddUserPrescriptionsScreen.routeName: (ctx) => AddUserPrescriptionsScreen(auth.particularId,auth.userId),
              
              
              AuthScreen.routeName: (ctx) => AuthScreen(),
              SettingScreen.routeName: (ctx) => SettingScreen(auth.particularId, auth.userId),
            },
          );
        }
      ),
    );
  }
}
