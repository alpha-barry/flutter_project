import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NightMode extends ChangeNotifier {
  Color color = Colors.white;
  bool  switcher = false;

  void  switchMode(){
    switcher = !switcher;
    switcher ?  color = Colors.black : color = Colors.white;
    notifyListeners();
  }
}