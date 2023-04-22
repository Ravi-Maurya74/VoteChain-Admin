import 'dart:convert';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:voting_blockchain/helpers/networking.dart';
import 'package:flutter/services.dart';

class VotePage extends StatefulWidget {
  const VotePage({super.key, required this.pollData});
  final dynamic pollData;

  @override
  State<VotePage> createState() => _VotePageState();
}

class _VotePageState extends State<VotePage> {
  int _selected = -1;
  late final GetStorage box;
  late int voterId;

  @override
  void initState() {
    // TODO: implement initState
    box = GetStorage();
    voterId = box.read('voter_id');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Poll: ${widget.pollData["id"]}",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontFamily: "Alkatra"),
                  ),
                  Text(
                    DateFormat.yMMMMd('en_US').format(DateFormat("yyyy-MM-dd")
                        .parse((widget.pollData['created'] as String)
                            .substring(0, 10))),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontFamily: "Alkatra"),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  widget.pollData["title"],
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontFamily: "Alkatra"),
                  textAlign: TextAlign.justify,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) => Bounceable(
                    onTap: () {
                      setState(() {
                        _selected = index;
                      });
                    },
                    child: index == _selected
                        ? SelectedTile(
                            title: widget.pollData["choices_name"][index],
                            index: index,
                          )
                        : DeselectedTile(
                            title: widget.pollData["choices_name"][index],
                            index: index,
                          )),
                itemCount:
                    (widget.pollData["choices_name"] as List<dynamic>).length,
              ),
              const SizedBox(
                height: 40,
              ),
              ElevatedButton(
                onPressed: () {
                  if (_selected == -1) {
                    CoolAlert.show(
                      context: context,
                      type: CoolAlertType.error,
                      text: "Select a choice to vote!",
                      barrierDismissible: false,
                    );
                    return;
                  } else {
                    CoolAlert.show(
                      context: context,
                      type: CoolAlertType.confirm,
                      text:
                          "You are voting to ${widget.pollData["choices_name"][_selected]}. This action is irreversible.",
                      confirmBtnText: "Confirm",
                      barrierDismissible: false,
                      closeOnConfirmBtnTap: false,
                      onConfirmBtnTap: () async {
                        Navigator.pop(context);
                        CoolAlert.show(
                          context: context,
                          type: CoolAlertType.loading,
                          text: "Saving your vote...",
                          barrierDismissible: false,
                        );
                        var response = await NetworkHelper()
                            .postData(url: "castVote/", jsonMap: {
                          "election_id": widget.pollData["id"],
                          "choice_id": _selected,
                          "voter_id": voterId,
                        });
                        var hashData = jsonDecode(response.body);
                        if (!mounted) return;
                        Navigator.pop(context);
                        await CoolAlert.show(
                          context: context,
                          type: CoolAlertType.success,
                          barrierDismissible: false,
                          confirmBtnText: "Done",
                          text:
                              "Your vote has been recorded. Click on Done to copy your vote hash to clipboard and return to home page. This hash can be used to verify you vote later.",
                          onConfirmBtnTap: () async {
                            await Clipboard.setData(
                                ClipboardData(text: hashData["hash"]));
                          },
                        );
                        Navigator.pop(context, true);
                      },
                    );
                  }
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      // side: BorderSide(color: Colors.amber),
                    ),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Text(
                    "Vote",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontFamily: "Alkatra"),
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}

class DeselectedTile extends StatelessWidget {
  const DeselectedTile({super.key, required this.title, required this.index});
  final String title;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: IntrinsicHeight(
        child: Row(children: [
          Text(
            String.fromCharCode(("A".codeUnitAt(0)) + index),
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(fontFamily: "Alkatra", color: Colors.black),
          ),
          const VerticalDivider(
            color: Colors.black,
          ),
          const SizedBox(
            width: 5,
          ),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontFamily: "Alkatra", color: Colors.black),
            ),
          ),
        ]),
      ),
    );
  }
}

class SelectedTile extends StatelessWidget {
  const SelectedTile({super.key, required this.title, required this.index});
  final String title;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // color: Colors.amber[200],
        gradient: LinearGradient(colors: [
          Colors.orange.shade300.withOpacity(0.9),
          Colors.orange.withOpacity(0.9),
          Colors.orange.shade800.withOpacity(0.9),
        ]),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: IntrinsicHeight(
        child: Row(children: [
          Text(
            String.fromCharCode(("A".codeUnitAt(0)) + index),
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(fontFamily: "Alkatra", color: Colors.black),
          ),
          const VerticalDivider(
            color: Colors.black,
          ),
          const SizedBox(
            width: 5,
          ),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontFamily: "Alkatra", color: Colors.black),
            ),
          ),
        ]),
      ),
    );
  }
}
