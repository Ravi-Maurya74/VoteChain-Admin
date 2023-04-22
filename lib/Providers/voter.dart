import 'package:flutter/material.dart';

class Voter with ChangeNotifier {
  int id = 0;
  String email = '';
  String password = '';
  String name = '';
  void update(
      {required int id,
      required String email,
      required String password,
      required String name,}) {
    this.id = id;
    this.email = email;
    this.password = password;
    this.name = name;
  }
}
