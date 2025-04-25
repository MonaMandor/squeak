import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:squeak/core/helper/cache/cache_helper.dart';
import 'package:squeak/core/helper/remotely/dio.dart';
import 'package:squeak/core/helper/remotely/end-points.dart';
import 'package:squeak/features/auth/login/data/models/auth_model.dart';


class LoginRemoteDataSource {
  Future<AuthModel> login({
    required String emailOrPhoneNumber,
    required String password,
  }) async {
    final fbToken =
        CacheHelper.getData('DeviceToken') ?? await FirebaseMessaging.instance.getToken();

    final response = await DioFinalHelper.postData(
      method: loginEndPoint,
      data: {
        'emailOrPhoneNumber': emailOrPhoneNumber,
        'password': password,
        'FbToken': fbToken,
        'IOSDevice': Platform.isIOS,
        'Androidevice': Platform.isAndroid,
      },
    );

    return AuthModel.fromJson(response.data);
  }
}
