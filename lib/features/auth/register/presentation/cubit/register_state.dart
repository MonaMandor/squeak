part of 'register_cubit.dart';

abstract class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object> get props => [];
}

class RegisterInitial extends RegisterState {}
class LoadingRegisterState extends RegisterState {}
class SuccessRegisterState extends RegisterState {
 
}

class ErrorRegisterState extends RegisterState {
  final ResponseModel error;

  const ErrorRegisterState(this.error);

  @override
  List<Object> get props => [error];
}
class GetCurrentCountryCodeErrorState extends RegisterState {}
class GetCurrentCountryCodeSuccessState extends RegisterState {}
class GetCurrentCountryCodeLoadingState extends RegisterState {}
class GetCountrySuccessState extends RegisterState {}
class FollowSuccess extends RegisterState {
  final bool isFollow;
  const FollowSuccess(this.isFollow);
  @override
  List<Object> get props => [isFollow];
 
}