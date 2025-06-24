import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Firestore provider
final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);

// Profile provider
final profileProvider =
    StateNotifierProvider<ProfileController, Map<String, dynamic>>((ref) {
  return ProfileController(ref);
});

class ProfileController extends StateNotifier<Map<String, dynamic>> {
  final Ref _ref;

  ProfileController(this._ref) : super({}) {
    _listenToUserProfile(); // Real-time profile updates
  }

  void _listenToUserProfile() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _ref
        .read(firestoreProvider)
        .collection('user')
        .doc(user.uid)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        state = doc.data()!;
      } else {
        _createUserProfile();
      }
    });
  }

  Future<void> _createUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final profileData = {'email': user.email, 'name': '', 'phone': ''};
    await _ref
        .read(firestoreProvider)
        .collection('user')
        .doc(user.uid)
        .set(profileData);
  }

  Future<void> updateProfile(String name, String phone) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final updatedData = {'name': name, 'phone': phone};
    await _ref
        .read(firestoreProvider)
        .collection('user')
        .doc(user.uid)
        .set(updatedData, SetOptions(merge: true));

    state = {...state, ...updatedData};
  }
}
