import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:voting_blockchain/helpers/networking.dart';

class ResultPage extends StatelessWidget {
  ResultPage({super.key, required this.pollData, required this.result});
  final dynamic pollData;
  final dynamic result;
  late List<CandidateData> _candidateData;
  late String _winner;
  late String _totalVotes;

  @override
  Widget build(BuildContext context) {
    _candidateData = getChartData(result);
    _winner = getWinner(result);
    _totalVotes = getTotalVotes(result);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: SingleChildScrollView(
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Poll: ${pollData["id"]}",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontFamily: "Alkatra"),
                    ),
                    Text(
                      DateFormat.yMMMMd('en_US').format(DateFormat("yyyy-MM-dd")
                          .parse((pollData['created'] as String)
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
                    pollData["title"],
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(fontFamily: "Alkatra"),
                    textAlign: TextAlign.justify,
                  ),
                ),
                SizedBox(
                  height: 400,
                  child: SfCircularChart(
                    // title: ChartTitle(
                    //     text: pollData["title"],
                    //     textStyle: Theme.of(context)
                    //         .textTheme
                    //         .titleLarge!
                    //         .copyWith(fontFamily: "Alkatra")),
                    legend: Legend(
                      isVisible: true,
                      overflowMode: LegendItemOverflowMode.wrap,
                      textStyle: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontFamily: "Alkatra", color: Colors.white),
                      position: LegendPosition.bottom,
                    ),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <CircularSeries>[
                      PieSeries<CandidateData, String>(
                        dataSource: _candidateData,
                        xValueMapper: (datum, index) => datum.name,
                        yValueMapper: (datum, index) => datum.votes,
                        dataLabelSettings:
                            const DataLabelSettings(isVisible: true),
                        enableTooltip: true,
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                ResultRow(
                  label: "Winner :",
                  value: _winner,
                ),
                ResultRow(
                  label: "By :",
                  value: "${result["votes"][result["winners"][0]]} votes",
                ),
                ResultRow(
                  label: "Total :",
                  value: "$_totalVotes votes",
                ),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var result = await showTextInputDialog(
            autoSubmit: true,
            barrierDismissible: true,
            message: "Enter vote hash to verify:",
            title: "Verify",
            context: context,
            textFields: [
              DialogTextField(
                validator: (value) {
                  if (value == null) {
                    return null;
                  }
                  if (value.length != 66) {
                    return "Hash must be 66 characters long.";
                  }
                },
              ),
            ],
          );
          if (result == null) return;
          String hash = result[0];
          var response = await NetworkHelper().postData(
              url: "verifyVote/",
              jsonMap: {"election_id": pollData["id"], "hash": hash});
          if (response.statusCode != 200) {
            await showOkAlertDialog(
              context: context,
              title: "Invalid Hash",
              message:
                  "Please enter the hash you received on voting on this poll only.",
            );
            return;
          }
          String choice_name = jsonDecode(response.body)["choice"]["name"];
          showOkAlertDialog(
            context: context,
            title: "Result",
            message: "You voted for $choice_name",
          );
        },
        backgroundColor: Colors.white,
        enableFeedback: true,
        elevation: 10,
        child: const Icon(
          Icons.verified_user,
          color: Colors.black,
          size: 35,
        ),
      ),
    );
  }
}

class ResultRow extends StatelessWidget {
  const ResultRow({super.key, required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            textAlign: TextAlign.right,
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(fontFamily: "Alkatra"),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          flex: 4,
          child: Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(fontFamily: "Alkatra"),
          ),
        ),
      ],
    );
  }
}

class CandidateData {
  final String name;
  final int votes;
  CandidateData({required this.name, required this.votes});
}

List<CandidateData> getChartData(dynamic data) {
  final List<dynamic> choices = data["choices"];
  final List<dynamic> votes = data["votes"];
  List<CandidateData> candidateData = [];
  for (int i = 0; i < choices.length; i++) {
    candidateData.add(CandidateData(name: choices[i]["name"], votes: votes[i]));
  }
  return candidateData;
}

String getWinner(dynamic data) {
  final List<dynamic> choices = data["choices"];
  final List<dynamic> winners = data["winners"];
  String ans = "";
  for (int ind in winners) {
    ans += choices[ind]["name"];
    ans += ", ";
  }
  ans = ans.substring(0, ans.length - 2);
  return ans;
}

String getTotalVotes(dynamic data) {
  final List<dynamic> votes = data["votes"];
  int ans = 0;
  for (int vote in votes) {
    ans += vote;
  }
  return ans.toString();
}
