import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/doctor_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: Consumer<AuthService>(
        builder: (context, auth, _) {
          if (auth.user == null) {
            return MaterialApp(home: LoginScreen());
          } else {
            return MaterialApp(
              home: auth.userRole == 'admin'
                  ? AdminScreen()
                  : DoctorScreen(),
            );
          }
        },
      ),
    );
  }
}
