import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _db = FirebaseDatabase.instance.ref();
  User? user;
  String? userRole;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthChanged);
  }

  Future<void> _onAuthChanged(User? u) async {
    user = u;
    if (user != null) {
      // Lee el rol desde RTDB en /users/{uid}/role
      final snap = await _db.child('users').child(user!.uid).child('role').get();
      userRole = snap.value as String?; // 'admin' o 'doctor'
    }
    notifyListeners();
  }

  Future<void> signIn(String email, String pass) =>
    _auth.signInWithEmailAndPassword(email: email, password: pass);

  Future<void> signOut() => _auth.signOut();
}
