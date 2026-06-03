import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ukl_mobile_uiux/controllers/auth_controller.dart'; 
import 'package:ukl_mobile_uiux/controllers/layanan_controller.dart';
import 'package:ukl_mobile_uiux/controllers/customer_controller.dart';
import 'package:ukl_mobile_uiux/controllers/tagihan%20controller.dart'; 
import 'package:ukl_mobile_uiux/controllers/profile_controller.dart';
import 'package:ukl_mobile_uiux/views/splash_view.dart'; 

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => LayananController()),
        ChangeNotifierProvider(create: (_) => CustomerAdminController()),
        ChangeNotifierProvider(create: (_) => TagihanController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
      ],
      child: const MyApp(isAdmin: true),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required bool isAdmin});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashView(),
    );
  }
}