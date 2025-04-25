// contust_repository.dart

import 'package:squeak/features/auth/contust/data/datasources/contust_remote_data_source.dart';
import 'package:squeak/core/helper/image_helper/helper_model/response_model.dart';
import 'package:squeak/features/vetcare/models/vetIcare_client_model.dart';

class ContustRepository {
  final ContustRemoteDataSource remoteDataSource;

  ContustRepository(this.remoteDataSource);

  Future<ResponseModel> contactUs({
    required String title,
    required String phone,
    required String fullName,
    required String comment,
    required String email,
  }) async {
    return await remoteDataSource.contactUs(
      title: title,
      phone: phone,
      fullName: fullName,
      comment: comment,
      email: email,
    );
  }

  Future<List<VetClientModel>> getClintFormVetVoid({
    required String code,
    required String phone,
    required bool isFilter,
  }) async {
    return await remoteDataSource.getClientFormVetVoid(
      code: code,
      phone: phone,
      isFilter: isFilter,
    );
  }
}
