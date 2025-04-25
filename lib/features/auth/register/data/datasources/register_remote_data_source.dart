import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:squeak/core/helper/remotely/config_model.dart';
import 'package:squeak/core/helper/remotely/dio.dart';
import 'package:squeak/core/helper/remotely/end-points.dart';
import 'package:squeak/features/auth/register/data/models/country_model.dart';
import 'package:squeak/features/vetcare/models/vetIcare_client_model.dart';

class RegisterRemoteDataSource {
  String? password;
  String? username;

  Future<void> getTokenFormFirebase() async {
    try {
      await FirebaseFirestore.instance
          .collection('UserToken')
          .doc('Is0fJjcbMCqOrWmQdKoj')
          .snapshots()
          .listen((event) {
        username = event.data()!['Username'];
        password = event.data()!['password'];
      });
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<List<CountryModel>> getCountry(String name) async {
    await getTokenFormFirebase();
    try {
      final auth = 'Basic ${base64Encode(utf8.encode('${username ?? "Ahmed.Omar@Veticare.com"}:${password ?? "Password@123"}'))}';
      final dio = Dio();
      final response = await dio.request(
        '${ConfigModel.baseApiimageUrlSqueak}$version/squeak/countries?Name=$name',
        options: Options(
          method: 'GET',
          headers: {
            'accept': '*/*',
            'Authorization': auth,
          },
        ),
      );

      return (response.data['data'] as List)
          .map((e) => CountryModel.fromJson(e))
          .where((e) => e.id != 2)
          .toList();
    } on DioException catch (e) {
      print(e.response);
      rethrow;
    }
  }

  Future<void> register(Map<String, dynamic> data) async {
    await DioFinalHelper.postData(method: registerEndPoint, data: data);
  }

  Future<void> registerQr(Map<String, dynamic> data) async {
    await DioFinalHelper.putData(method: registerQrEndPoint, data: data);
  }

  Future<List<VetClientModel>> getClients(String code, String phone, bool isFilter) async {
    final response = await DioFinalHelper.getData(
      method: getClientClinicEndPoint(code, phone),
      language: true,
    );

    final list = List<VetClientModel>.from(response.data["data"].map((x) => VetClientModel.fromJson(x)));

    if (isFilter) {
      return list.where((e) => e.addedInSqueakStatues == false).toList();
    }

    return list;
  }
}
