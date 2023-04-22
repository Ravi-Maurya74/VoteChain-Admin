import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:async';

import 'package:voting_blockchain/Providers/voter.dart';
import 'package:voting_blockchain/Providers/loader.dart';
import 'package:provider/provider.dart';
import 'package:voting_blockchain/pages/home_page.dart';
import 'package:voting_blockchain/pages/login_page.dart';

class OpeningAnimationsPage extends StatefulWidget {
  const OpeningAnimationsPage({super.key});

  @override
  OpeningAnimationsPageState createState() => OpeningAnimationsPageState();
}

class OpeningAnimationsPageState extends State<OpeningAnimationsPage> {
  bool _a = false;
  bool _b = false;
  bool _c = false;
  bool _d = false;
  bool _e = false;
  bool _f = false;
  bool _g = false;
  bool _h = true;

  final TextStyle initialStyle = const TextStyle(
    fontSize: 30,
    color: Colors.black,
    fontWeight: FontWeight.w600,
    wordSpacing: 2,
  );

  final TextStyle finalStyle = const TextStyle(
    fontSize: 30,
    color: Colors.white,
    fontWeight: FontWeight.w600,
    wordSpacing: 2,
  );

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _g = true;
        _a = true;
        _h = !_h;
      });
    });
    Timer(const Duration(seconds: 1), () {
      setState(() {
        _b = true;
        _h = !_h;
      });
    });
    Timer(const Duration(milliseconds: 1500), () {
      setState(() {
        _c = true;
        _h = !_h;
      });
    });
    Timer(const Duration(seconds: 2), () {
      setState(() {
        _d = true;
        _h = !_h;
      });
    });
    Timer(const Duration(milliseconds: 2500), () {
      setState(() {
        _e = true;
        _h = !_h;
      });
    });
    Timer(const Duration(seconds: 3), () {
      setState(() {
        _f = true;
        _h = !_h;
        _g = false;
      });
    });
    Timer(const Duration(milliseconds: 4000), () async {
      final loader = Provider.of<Loader>(context, listen: false);
      int choice = await loader.choice;
      if (choice == 1) {
        final results = loader.data;
        Response voterData = results[0];
        var data = jsonDecode(voterData.body);
        if (!mounted) return;
        Provider.of<Voter>(context, listen: false).update(
          id: data['id'],
          email: data['user_email'],
          password: data['password'],
          name: data['name'],
        );
        Navigator.pushReplacement(
            context, ThisIsFadeRoute(page: HomePage(), route: HomePage()));
      } else {
        if (!mounted) return;
        Navigator.pushReplacement(
            context, ThisIsFadeRoute(page: LoginPage(), route: LoginPage()));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 2500),
              curve: Curves.fastLinearToSlowEaseIn,
              height: _a ? height : 0,
              width: _a ? width : 0,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(_a ? 0 : 99),
              ),
            ),
          ),
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 2500),
              curve: Curves.fastLinearToSlowEaseIn,
              height: _b ? height : 0,
              width: _b ? width : 0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_b ? 0 : 99),
              ),
            ),
          ),
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 2500),
              curve: Curves.fastLinearToSlowEaseIn,
              height: _c ? height : 0,
              width: _c ? width : 0,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(_c ? 0 : 99),
              ),
            ),
          ),
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 2500),
              curve: Curves.fastLinearToSlowEaseIn,
              height: _d ? height : 0,
              width: _d ? width : 0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_d ? 0 : 99),
              ),
            ),
          ),
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 2500),
              curve: Curves.fastLinearToSlowEaseIn,
              height: _e ? height : 0,
              width: _e ? width : 0,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(_e ? 0 : 99),
              ),
            ),
          ),
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 2200),
              curve: Curves.fastLinearToSlowEaseIn,
              height: _f ? height : 0,
              width: _f ? width : 0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_f ? 0 : 99),
              ),
            ),
          ),
          Center(
            child: _g
                ? AnimatedDefaultTextStyle(
                    style: _h ? initialStyle : finalStyle,
                    duration: const Duration(seconds: 2),
                    curve: Curves.fastLinearToSlowEaseIn,
                    child: const Text(
                      "VoteChain",
                      style: TextStyle(fontFamily: 'Kaushan', fontSize: 55),
                    ),
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}

class ThisIsFadeRoute extends PageRouteBuilder {
  final Widget page;
  final Widget route;

  ThisIsFadeRoute({required this.page, required this.route})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: animation,
            child: route,
          ),
        );
}
