import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:voting_blockchain/Providers/loader.dart';
import 'package:voting_blockchain/Providers/voter.dart';
import 'package:voting_blockchain/pages/opening_page.dart';

void main() async {
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Voter(),
        ),
        Provider(
          create: (context) => Loader(),
          lazy: false,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData.dark().copyWith(
            textTheme: TextTheme(
              titleLarge: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.9)),
              bodyMedium: const TextStyle(fontSize: 18, color: Colors.white70),
              bodySmall: const TextStyle(fontSize: 13, color: Colors.white70),
              titleMedium: const TextStyle(fontSize: 19),
              titleSmall: const TextStyle(fontSize: 15),
            ),
            chipTheme: ChipThemeData(
              backgroundColor: Colors.white.withOpacity(0.9),
              selectedColor: Colors.amber,
              disabledColor: Colors.white70,
            ),
            colorScheme: ColorScheme.fromSwatch().copyWith(
              secondary: Colors.white70,
              // primary: Colors.white70,
            ),
            scaffoldBackgroundColor: const Color.fromRGBO(24, 25, 32, 1),
            drawerTheme: const DrawerThemeData(
              backgroundColor: Color.fromRGBO(24, 25, 32, 1),
            )),
        home: const OpeningAnimationsPage(),
      ),
    );
  }
}
