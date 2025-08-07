import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String username;
  final String email;
  final String phoneNumber;
  final String password;
  final bool isOnline;
  final Timestamp lastSeen;
  final Timestamp createdAt;
  final String? fcmToken;
  final List<String> blockedUsers;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.password,
    this.isOnline = false,
    Timestamp? lastSeen,
    Timestamp? createdAt,
    this.fcmToken,
    this.blockedUsers = const [],
  }) : lastSeen = lastSeen ?? Timestamp.now(),
       createdAt = createdAt ?? Timestamp.now();

  UserModel copyWith({
    String? uid,
    String? fullName,
    String? username,
    String? email,
    String? phoneNumber,
    String? password,
    bool? isOnline,
    Timestamp? lastSeen,
    Timestamp? createdAt,
    String? fcmToken,
    List<String>? blockedUsers,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      fcmToken: fcmToken ?? this.fcmToken,
      blockedUsers: blockedUsers ?? this.blockedUsers,
    );
  }

  // Factory method to create a UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      fullName: data['fullName'],
      username: data['username'],
      email: data['email'],
      phoneNumber: data['phoneNumber'],
      password: data['password'],
      fcmToken: data['fcmToken'],
      isOnline: data['isOnline'],
      lastSeen: data['lastSeen'],
      createdAt: data['createdAt'],
      blockedUsers: data['blockedUsers'],
    );
  }

  // Converts the UserModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
      'createdAt': createdAt,
      'fcmToken': fcmToken,
      'blockedUsers': blockedUsers,
    };
  }
}
