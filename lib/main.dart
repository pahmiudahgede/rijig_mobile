import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:rijig_mobile/core/container/injection_container.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/core/container/export_vmod.dart';

void main() async {
  await dotenv.load(fileName: "server/.env.dev");
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null).then((_) {
    init();
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sl<LoginViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<OtpViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<LogoutViewModel>()),

        ChangeNotifierProvider(create: (_) => sl<TrashViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<AboutViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<AboutDetailViewModel>()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, child) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: router,
          );
        },
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
