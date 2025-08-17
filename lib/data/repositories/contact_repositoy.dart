import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:messagener_app/data/models/user_model.dart';
import 'package:messagener_app/data/services/base_repository.dart';

class ContactRepository extends BaseRepository {
  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  //asking access to contacts permissions
  Future<bool> requestContactsPermission() async {
    return FlutterContacts.requestPermission();
  }

  //getting registered users
  Future<List<Map<String, dynamic>>> getRegisteredUsers() async {
    bool hasPermission = await requestContactsPermission();
    if (!hasPermission) {
      log('Contacts permission not granted');
      return [];
    }

    try {
      //get device contact
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );

      //extract contact and normalize the phone number
      final phoneNumbers = contacts
          .where((contact) => contact.phones.isNotEmpty)
          .map(
            (contact) => {
              'name': contact.displayName,
              'phoneNumber': contact.phones.first.number.replaceAll(
                RegExp(r'[^\d+]'),
                '',
              ),
              'photo': contact.photo,
            },
          )
          .toList();

      //get all user from firestore
      final userSnapshot = await firestore.collection('users').get();

      final registeredUsers = userSnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();

      //match contact with registered users
      final matchedContacts = phoneNumbers
          .where((contact) {
            //Filtering Phase
            String phoneNumber = contact["phoneNumber"].toString();

            if (phoneNumber.startsWith('+91')) {
              phoneNumber = phoneNumber.substring(3);
            }

            return registeredUsers.any(
              (user) =>
                  user.phoneNumber == phoneNumber && user.uid != currentUserId,
            );
          })
          .map((contact) {
            //Transformation Phase
            String phoneNumber = contact["phoneNumber"].toString();

            if (phoneNumber.startsWith("+91")) {
              phoneNumber = phoneNumber.substring(3);
            }

            final registeredUser = registeredUsers.firstWhere(
              (user) => user.phoneNumber == phoneNumber,
            );
            return {
              'id': registeredUser.uid,
              'name': contact['name'],
              'phoneNumber': registeredUser.phoneNumber,
            };
          })
          .toList();
      return matchedContacts;
    } catch (_) {}

    return getRegisteredUsers();
  }
}
