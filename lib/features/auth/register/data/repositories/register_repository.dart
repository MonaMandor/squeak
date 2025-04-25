import 'package:squeak/features/auth/register/data/datasources/register_remote_data_source.dart';
import 'package:squeak/features/auth/register/data/models/country_model.dart';
import 'package:squeak/features/vetcare/models/vetIcare_client_model.dart';

class RegisterRepository {
  final RegisterRemoteDataSource remoteDataSource;

  RegisterRepository(this.remoteDataSource);

  Future<List<CountryModel>> getCountry(String name) {
    return remoteDataSource.getCountry(name);
  }

  Future<void> register(Map<String, dynamic> data) {
    return remoteDataSource.register(data);
  }

  Future<void> registerQr(Map<String, dynamic> data) {
    return remoteDataSource.registerQr(data);
  }

  Future<List<VetClientModel>> getClients(String code, String phone, bool isFilter) {
    return remoteDataSource.getClients(code, phone, isFilter);
  }
}
