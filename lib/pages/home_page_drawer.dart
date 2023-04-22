import 'dart:convert';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:voting_blockchain/helpers/networking.dart';
import 'package:voting_blockchain/pages/declared_polls.dart';
import 'package:voting_blockchain/pages/ongoing_polls.dart';

class HomePageDrawer extends StatelessWidget {
  HomePageDrawer({
    Key? key,
  }) : super(key: key);
  late GetStorage box;

  @override
  Widget build(BuildContext context) {
    box = GetStorage();
    return Drawer(
      child: Column(children: [
        AppBar(
          title: Text(
            'VoteChain',
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(fontFamily: "Alkatra"),
          ),
          leading: null,
          automaticallyImplyLeading: false,
        ),
        // ListTile(
        //   leading: const Icon(
        //     Icons.person,
        //     color: Colors.white,
        //   ),
        //   title: Text(
        //     'Account',
        //     style: Theme.of(context).textTheme.bodyMedium,
        //   ),
        //   onTap: () {
        //     // Navigator.pushNamed(context, ChangeAccount.routeName);
        //   },
        // ),
        ListTile(
          leading: const Icon(
            Icons.how_to_vote_sharp,
            color: Colors.white,
          ),
          title: Text(
            'Ongoing Polls',
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontFamily: "Alkatra"),
          ),
          onTap: () async {
            var voterId = box.read("voter_id");
            var response = await NetworkHelper().postData(
              url: "getOngoingVOterElections/",
              jsonMap: {"voter_id": voterId},
            );
            var polls = jsonDecode(response.body);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OngoingPolls(
                    polls: polls,
                  ),
                ));
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.bar_chart_outlined,
            color: Colors.white,
          ),
          title: Text(
            'Declared Polls',
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontFamily: "Alkatra"),
          ),
          onTap: () async {
            var voterId = box.read("voter_id");
            var response = await NetworkHelper().postData(
              url: "getClosedVoterElections/",
              jsonMap: {"voter_id": voterId},
            );
            var polls = jsonDecode(response.body);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DeclaredPolls(
                    polls: polls,
                  ),
                ));
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.power_settings_new,
            color: Colors.white,
          ),
          title: Text(
            'Log out',
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontFamily: "Alkatra"),
          ),
          onTap: () {
            CoolAlert.show(
              context: context,
              type: CoolAlertType.confirm,
              confirmBtnText: 'Confirm',
              onConfirmBtnTap: () {
                GetStorage().remove('voter_id');
                SystemNavigator.pop();
              },
            );
          },
        ),
      ]),
    );
  }
}
