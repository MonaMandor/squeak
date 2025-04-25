// contust_remote_data_source.dart
import 'package:dio/dio.dart';
import 'package:squeak/core/helper/remotely/end-points.dart';
import 'package:squeak/core/helper/image_helper/helper_model/response_model.dart';
import 'package:squeak/features/vetcare/models/vetIcare_client_model.dart';

class ContustRemoteDataSource {
  final Dio _dio;

  ContustRemoteDataSource(this._dio);

  Future<ResponseModel> contactUs({
    required String title,
    required String phone,
    required String fullName,
    required String comment,
    required String email,
  }) async {
    try {
      final response = await _dio.post(contactUsEndPoint, data: {
        "title": title,
        "phone": phone,
        "fullName": fullName,
        "comment": comment,
        "email": email,
        "statues": false,
      });
      return ResponseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<VetClientModel>> getClientFormVetVoid({
    required String code,
    required String phone,
    required bool isFilter,
  }) async {
    try {
      final response = await _dio.get(getClientClinicEndPoint(code, phone));
      if (isFilter) {
        return List<VetClientModel>.from(
          response.data["data"]
              .map((x) => VetClientModel.fromJson(x))
              .where((element) => element.addedInSqueakStatues == false),
        );
      } else {
        return List<VetClientModel>.from(
          response.data["data"].map((x) => VetClientModel.fromJson(x)),
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
