import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';
import 'package:voting_blockchain/helpers/networking.dart';

class Loader {
  late Completer<int> ch;
  List<Response> data = [];
  Loader() {
    debugPrint('started');
    ch = Completer();
    start();
  }
  Future<int> get choice {
    return ch.future;
  }

  void start() async {
    final box = GetStorage();
    bool hasUser = box.hasData('voter_id');
    if (hasUser) {
      int voterId = box.read('voter_id');
      final results = await Future.wait([
        NetworkHelper()
            .postData(url: "identifyVoter/", jsonMap: {"voter_id": voterId}),
        NetworkHelper().postData(
            url: "getVoterElections/", jsonMap: {"voter_id": voterId}),
        // NetworkHelper().getData(url: 'topRatedMovies/'),
        // NetworkHelper().getData(url: 'mostUpvotedMovies/'),
      ]);
      data = results;
      debugPrint('completed');
      ch.complete(1);
      // String firstMovie = jsonDecode(results[2].body)[0]['imageUrl'];
      // Image image = Image(
      //   image: CachedNetworkImageProvider(firstMovie),
      //   fit: BoxFit.cover,
      // );
      // loadImage(image.image);
    } else {
      ch.complete(2);
    }
  }
}
