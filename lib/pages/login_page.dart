import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:voting_blockchain/Providers/loader.dart';
import 'package:voting_blockchain/Providers/voter.dart';
import 'package:voting_blockchain/helpers/networking.dart';
import 'package:voting_blockchain/pages/home_page.dart';
import 'package:voting_blockchain/pages/register_page.dart';
import 'package:voting_blockchain/widgets/custom_button.dart';
import 'package:voting_blockchain/widgets/custom_password_field.dart';
import 'package:voting_blockchain/widgets/custom_text_field.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final box = GetStorage();
  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    var dimensions = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: dimensions.height * 0.1,
              ),
              Text('Welcome !', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(
                height: 10,
              ),
              const Text('Please sign in to your account'),
              SizedBox(
                height: dimensions.height * 0.1,
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
                height: dimensions.height * 0.25,
              ),
              CustomButton(
                  dimensions: dimensions,
                  label: 'Sign In',
                  action: () async {
                    if (emailController.text.isEmpty ||
                        passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Please provide complete info.')));
                      return;
                    }
                    Response response = await NetworkHelper().postData(
                        url: 'adminLogin/',
                        jsonMap: {
                          "email_id": emailController.text,
                          "password": passwordController.text
                        });
                    var data = jsonDecode(response.body);
                    if (response.statusCode == 400) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(data["message"])));
                      return;
                    }
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
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     const Text(
              //       "Dont't have an Account? ",
              //       style: TextStyle(),
              //     ),
              //     TextButton(
              //       onPressed: () {
              //         // Navigator.pushReplacementNamed(
              //         //     context, RegisterPage.routeName);
              //         Navigator.pushReplacement(
              //           context,
              //           MaterialPageRoute(
              //             builder: (context) => RegisterPage(),
              //           ),
              //         );
              //       },
              //       child: Text(
              //         'Sign Up',
              //         style: TextStyle(
              //           fontSize:
              //               Theme.of(context).textTheme.titleMedium!.fontSize,
              //         ),
              //       ),
              //     )
              //   ],
              // ),
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
