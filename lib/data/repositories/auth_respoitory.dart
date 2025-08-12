import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:messagener_app/data/models/user_model.dart';
import 'package:messagener_app/data/services/base_repository.dart';

class AuthRepository extends BaseRepository {
  //state change notifier
  Stream<User?> get authStateChanges => auth.authStateChanges();

  // Sign up method
  Future<UserModel> signUp({
    required String fullName,
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final formattedPhoneNumber = phoneNumber.replaceAll(
        RegExp(r'\s+'),
        ''.trim(),
      );
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw "User creation failed";
      }

      //create a user model and save
      final user = UserModel(
        uid: userCredential.user!.uid,
        fullName: fullName,
        username: username,
        email: email,
        phoneNumber: formattedPhoneNumber,
        password: password,
      );
      await saveUserData(user);
      return user;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  //save the user model to firestore
  Future<void> saveUserData(UserModel user) async {
    try {
      await firestore.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      throw "failed to save user data";
    }
  }

  //sign in method
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in the user

      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw "User not found";
      }
      // Fetch user data from Firestore
      final user = await getUserData(userCredential.user!.uid);
      return user;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  // get user data from firestore
  Future<UserModel> getUserData(String uid) async {
    try {
      final doc = await firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        throw "User not found";
      }
      return UserModel.fromFirestore(doc);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  //sign out method
  Future<void> signOut() async {
    await auth.signOut();
  }
}
