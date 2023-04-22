import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:voting_blockchain/Providers/loader.dart';
import 'package:voting_blockchain/Providers/voter.dart';
import 'package:voting_blockchain/helpers/networking.dart';
import 'package:voting_blockchain/pages/home_page.dart';
import 'package:voting_blockchain/pages/login_page.dart';
import 'package:voting_blockchain/widgets/custom_button.dart';
import 'package:voting_blockchain/widgets/custom_password_field.dart';
import 'package:voting_blockchain/widgets/custom_text_field.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final box = GetStorage();
  RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    var dimensions = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Text('Create new account',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(
                height: 10,
              ),
              const Text('Please fill in the form to continue'),
              const SizedBox(height: 70),
              CustomTextField(
                label: 'Full Name',
                iconData: Icons.person,
                textEditingController: nameController,
              ),
              const SizedBox(
                height: 20,
              ),
              CustomTextField(
                label: 'Email',
                iconData: Icons.email,
                textEditingController: emailController,
              ),
              const SizedBox(
                height: 20,
              ),
              CustomPasswordField(
                label: 'Password',
                iconData: Icons.lock,
                textEditingController: passwordController,
              ),
              SizedBox(
                height: dimensions.height * 0.20,
              ),
              CustomButton(
                  dimensions: dimensions,
                  label: 'Sign Up',
                  action: () async {
                    if (emailController.text.isEmpty ||
                        passwordController.text.isEmpty ||
                        nameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Please provide complete info.')));
                      return;
                    }
                    Response response = await NetworkHelper()
                        .postData(url: 'createVoter/', jsonMap: {
                      "name": nameController.text,
                      "user_email": emailController.text,
                      "password": passwordController.text,
                    });
                    if (response.statusCode == 400) {
                      Map<String, dynamic> res = jsonDecode(response.body);
                      List<String> display = [];
                      res.forEach((key, value) {
                        display.add("$key: ${value[0]}");
                      });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: display.map((e) => Text(e)).toList(),
                      )));
                      return;
                    }
                    var data = jsonDecode(response.body);
                    box.write('voter_id', data['id'] as int);

                    Provider.of<Voter>(context, listen: false).update(
                      id: data['id'],
                      email: data['user_email'],
                      password: data['password'],
                      name: data['name'],
                    );

                    final results = await Future.wait([
                      NetworkHelper().postData(
                          url: "getVoterElections/",
                          jsonMap: {"voter_id": data['id']}),
                      // NetworkHelper().getData(url: 'topRatedMovies/'),
                      // NetworkHelper().getData(url: 'mostUpvotedMovies/'),
                    ]);
                    final loader = Provider.of<Loader>(context, listen: false);
                    loader.data.add(response);
                    loader.data.addAll(results);

                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(),
                        ));
                  }),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Have an Account? ",
                    style: TextStyle(),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigator.pushReplacementNamed(
                      //     context, LoginPage.routeName);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          ));
                    },
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.titleMedium!.fontSize,
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: dimensions.height * 0.08,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
