import 'package:flutter/cupertino.dart';
import 'package:messagener_app/data/models/user_model.dart';
import 'package:messagener_app/data/services/base_repository.dart';

class AuthRepository extends BaseRepository {
  Future<UserModel> signUp({
    required String fullName,
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {}
}
