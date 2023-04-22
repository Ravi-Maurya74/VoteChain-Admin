import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voting_blockchain/Providers/loader.dart';
import 'package:voting_blockchain/pages/home_page_drawer.dart';
import 'package:voting_blockchain/pages/new_election_page.dart';
import 'package:voting_blockchain/widgets/custom_textfield2.dart';
import 'package:voting_blockchain/widgets/poll_card.dart';
import 'package:animations/animations.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<Loader>(context, listen: false).data;
    final List<dynamic> polls = jsonDecode(data[1].body);
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          _scaffoldKey.currentState!.openDrawer();
                        },
                        icon: const Icon(Icons.menu)),
                    Expanded(
                      child: CustomTextField2(
                        label: "Search",
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) =>
                      PollCard(pollData: polls[index]),
                  itemCount: polls.length,
                  physics: const BouncingScrollPhysics(
                      decelerationRate: ScrollDecelerationRate.fast),
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: HomePageDrawer(),
      floatingActionButton: OpenContainer(
        transitionDuration: const Duration(milliseconds: 800),
        closedElevation: 6,
        openColor: Colors.white10,
        middleColor: Colors.white24,
        closedColor: Colors.white70,
        closedShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30))),
        closedBuilder: (context, action) => SizedBox(
          height: 60,
          width: 60,
          child: Icon(
            Icons.add,
            size: 30,
            color: Colors.black,
          ),
        ),
        openBuilder: (context, action) => NewElectionPage(),
      ),
    );
  }
}

// FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => NewElectionPage(),
//               ));
//         },
        // child: Icon(
        //   Icons.add,
        //   size: 30,
        //   color: Colors.black,
        // ),
//       )
