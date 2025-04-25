
import 'package:squeak/core/helper/image_helper/helper_model/response_model.dart';
import 'package:squeak/features/auth/login/data/models/login_data_model.dart';

class AuthModel extends ResponseModel {
  final LoginData? data;

  AuthModel({
    required this.data,
    required super.errors,
    required super.message,
    required super.statusCode,
    required super.success,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
      errors: Map<String, List<dynamic>>.from(json['errors']),
      message: json['message'],
      statusCode: json['statusCode'],
      success: json['success'],
    );
  }
}
