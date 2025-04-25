
import 'package:squeak/features/auth/login/data/datasources/login_remote_data_source.dart';
import 'package:squeak/features/auth/login/data/models/auth_model.dart';

class LoginRepository {
  final LoginRemoteDataSource remoteDataSource;

  LoginRepository({required this.remoteDataSource});

  Future<AuthModel> login({
    required String emailOrPhoneNumber,
    required String password,
  }) {
    return remoteDataSource.login(
      emailOrPhoneNumber: emailOrPhoneNumber,
      password: password,
    );
  }
}
