part of 'login_cubit.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}
class LoginSuccess extends LoginState {
  final AuthModel userModel;

  const LoginSuccess(this.userModel);

  @override
  List<Object> get props => [userModel];
}
class LoginError extends LoginState {
  final ResponseModel error;

  const LoginError(this.error);

  @override
  List<Object> get props => [error];
}