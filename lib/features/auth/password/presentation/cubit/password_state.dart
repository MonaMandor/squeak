part of 'password_cubit.dart';

abstract class PasswordState extends Equatable {
  const PasswordState();

  @override
  List<Object> get props => [];
}

class PasswordInitial extends PasswordState {}
class VerifyUserSuccessState extends PasswordState{}
class VerifyUserLoadingState extends PasswordState{}
class RestPasswordErrorState extends PasswordState {
  final ResponseModel error;

  const RestPasswordErrorState(this.error);

  @override
  List<Object> get props => [error];
}
 class RestPasswordSuccessState extends PasswordState{
   final ResponseModel responseModel;
    const RestPasswordSuccessState(this.responseModel);
    @override
    List<Object> get props => [responseModel];
  }
  class RestPasswordLoadingState  extends PasswordState{}
  class ForgetPasswordErrorState extends PasswordState {
    final ResponseModel error;

    const ForgetPasswordErrorState(this.error);

    @override
    List<Object> get props => [error];
  }
class ForgetPasswordSuccessState extends PasswordState{}
class ForgetPasswordLoadingState extends PasswordState{}
class LoadingRegisterState extends PasswordState{}
class VerifyUserErrorState extends PasswordState {
  final ResponseModel error;

  const VerifyUserErrorState(this.error);

  @override
  List<Object> get props => [error];
}
