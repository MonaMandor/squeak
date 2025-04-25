// password_remote_data_source.dart

import 'package:dio/dio.dart';
import 'package:squeak/core/helper/remotely/dio.dart';
import 'package:squeak/core/helper/remotely/end-points.dart';
import 'package:squeak/core/helper/image_helper/helper_model/response_model.dart';

class PasswordRemoteDataSource {
  // Method to forget password
  Future<ResponseModel> forgetPassword(String email) async {
    try {
      final response = await DioFinalHelper.postData(
        method: forgetPasswordEndPoint,
        data: {"email": email},
      );
      return ResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ResponseModel.fromJson(e.response?.data);
    }
  }

  // Method to reset password
  Future<ResponseModel> resetPassword(String email, String tokenCode, String newPassword) async {
    try {
      final response = await DioFinalHelper.postData(
        method: resetPasswordEndPoint,
        data: {
          "email": email,
          "tokenCode": tokenCode,
          "newPassword": newPassword,
          "confirmNewPassword": newPassword,
        },
      );
      return ResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ResponseModel.fromJson(e.response?.data);
    }
  }

  // Method to verify user
  Future<ResponseModel> verifyUser(String email, String tokenCode, String clinicCode) async {
    try {
      final response = await DioFinalHelper.postData(
        method: verificationCodeEndPoint,
        data: {
          "email": email,
          "tokenCode": tokenCode,
          "clinicCode": clinicCode,
        },
      );
      return ResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ResponseModel.fromJson(e.response?.data);
    }
  }
}
