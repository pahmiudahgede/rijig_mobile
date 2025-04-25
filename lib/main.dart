import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rijig_mobile/core/router.dart';
// import 'screen/auth/login_screen.dart';

void main() async {
  await dotenv.load(fileName: "server/.env.dev");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, child) => MaterialApp.router(
        // theme: ThemeData(textTheme: textTheme),
        debugShowCheckedModeBanner: false,
        routerConfig: router,
      ),
    );
  }
}
