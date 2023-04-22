import 'package:flutter/material.dart';
import 'package:voting_blockchain/widgets/custom_appbar.dart';
import 'package:voting_blockchain/widgets/poll_card.dart';

class OngoingPolls extends StatelessWidget {
  const OngoingPolls({
    super.key,
    required this.polls,
  });
  final dynamic polls;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              const CustomAppbar(title: "Ongoing Polls"),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) =>
                        PollCard(pollData: polls[index]),
                    itemCount: (polls as List<dynamic>).length,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
