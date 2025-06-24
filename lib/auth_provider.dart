import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// FirebaseAuth instance provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Authentication provider
final authProvider = StateNotifierProvider<AuthController, User?>((ref) {
  return AuthController(ref);
});

class AuthController extends StateNotifier<User?> {
  final Ref _ref;

  AuthController(this._ref)
      : super(_ref.read(firebaseAuthProvider).currentUser) {
    _ref
        .read(firebaseAuthProvider)
        .authStateChanges()
        .listen((user) => state = user);
  }

  // Sign Up (Now returns a String message)
  Future<String> signUp(String email, String password) async {
    try {
      await _ref
          .read(firebaseAuthProvider)
          .createUserWithEmailAndPassword(email: email, password: password);
      return "Registration Successful!";
    } catch (e) {
      return "Sign Up Error: $e";
    }
  }

  // Login (Now returns a String message)
  Future<String> login(String email, String password) async {
    try {
      await _ref
          .read(firebaseAuthProvider)
          .signInWithEmailAndPassword(email: email, password: password);
      return "Login Successful!";
    } catch (e) {
      return "Login Error: $e";
    }
  }

  // Forgot Password
  Future<void> resetPassword(String email) async {
    try {
      await _ref
          .read(firebaseAuthProvider)
          .sendPasswordResetEmail(email: email);
    } catch (e) {
      print("Reset Password Error: $e");
    }
  }
// faqprovider

  // Logout
  Future<void> logout() async {
    try {
      await _ref.read(firebaseAuthProvider).signOut();
    } catch (e) {
      print("Logout Error: $e");
    }
  }
}

/// FutureProvider to fetch FAQs from Firestore
final faqProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final snapshot = await FirebaseFirestore.instance.collection('FAQS').get();
  return snapshot.docs.map((doc) {
    final data = doc.data();

    final question = (data['question'] ?? '').toString().trim();
    final answer = (data['answer'] ?? '').toString().trim();

    return {
      'question': question.isNotEmpty ? question : 'No Question',
      'answer': answer.isNotEmpty ? answer : 'No Answer',
    };
  }).toList();
});
