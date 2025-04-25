// password_repo.dart

import 'package:squeak/core/helper/image_helper/helper_model/response_model.dart';
import 'package:squeak/features/auth/password/data/datasources/password_remote_data_source.dart';

class PasswordRepo {
  final PasswordRemoteDataSource remoteDataSource;

  PasswordRepo({required this.remoteDataSource});

  // Method to forget password
  Future<ResponseModel> forgetPassword(String email) async {
    return await remoteDataSource.forgetPassword(email);
  }

  // Method to reset password
  Future<ResponseModel> resetPassword(String email, String tokenCode, String newPassword) async {
    return await remoteDataSource.resetPassword(email, tokenCode, newPassword);
  }

  // Method to verify user
  Future<ResponseModel> verifyUser(String email, String tokenCode, String clinicCode) async {
    return await remoteDataSource.verifyUser(email, tokenCode, clinicCode);
  }
}
