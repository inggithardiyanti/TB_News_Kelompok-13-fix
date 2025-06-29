import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inggitbela/src/configs/app_routes.dart';
import 'package:inggitbela/src/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).initAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return ScreenUtilInit(
          designSize: const Size(360, 960),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, child) {
            return MaterialApp(
              title: 'Kelompok 13',
              debugShowCheckedModeBanner: false,
              initialRoute: AppRoutes.splash,
              onGenerateRoute: AppRoutes.generateRoute,
              theme: ThemeData(
                primaryColor: const Color(0xFF2C3E50),
                colorScheme: ColorScheme.fromSwatch().copyWith(
                  secondary: const Color(0xFF3498DB),
                ),
                fontFamily: 'Poppins',
              ),
              supportedLocales: [
                Locale('en'), // English
              ],
            );
          },
        );
      },
    );
  }
}
