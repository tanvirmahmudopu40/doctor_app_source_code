import "package:flutter/material.dart";
import 'package:hmz/profile/fullProfile.dart';
import '../../profile/changePassword.dart';
import '../../appointment/showAppointment.dart';
import '../../dashboard/dashboard.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';

class AppBottomNavigationBar extends StatefulWidget {
  var screenNum;
  AppBottomNavigationBar({this.screenNum});

  @override
  _AppBottomNavigationBarState createState() => _AppBottomNavigationBarState(screenNum: this.screenNum);
}

class _AppBottomNavigationBarState extends State<AppBottomNavigationBar> {
  var screenNum;
  int _selectedIndex;

  int _selectedIndexValue;

  Color selectedcolor ;
  TextStyle optionStyle = TextStyle(fontSize: 15) ;

  _AppBottomNavigationBarState({this.screenNum}){
    this._selectedIndex = screenNum;
    if(_selectedIndex == null){
      _selectedIndex = 0;
      _selectedIndexValue=null;

      selectedcolor = Colors.black54;
      this.optionStyle = TextStyle(fontSize: 15);
    }
    else{
      selectedcolor = Colors.amber[800];
      _selectedIndexValue=screenNum;
      this.optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
    }
  }
  
  

  void _onItemTapped(int index) {
    setState(() {
      if(index == 0){
        Navigator.of(context).pushReplacementNamed(DashboardScreen.routeName);
      }
      if(index == 1){
        Navigator.of(context).pushReplacementNamed(ShowAppointmentScreen.routeName);
      }

      if(index == 2){
        Navigator.of(context).pushReplacementNamed(FullProfile.routeName);
      }
      
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Container(
      decoration: BoxDecoration(
        color: Colors.white,
    
        
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 7,
            offset: Offset(0, 3), 
          ),
        ],
      ),
      
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        
          items: <BottomNavigationBarItem>[

            BottomNavigationBarItem(
              icon: Icon(Icons.home,
              ),
              label: (_selectedIndexValue == 0)?AppLocalizations.of(context).dashboard : "",
             
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: (_selectedIndexValue == 1)?AppLocalizations.of(context).appointments : "",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: (_selectedIndexValue == 2)?AppLocalizations.of(context).profile : "",
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: selectedcolor,
          onTap: _onItemTapped,
        ),
    );
  }

  
}


