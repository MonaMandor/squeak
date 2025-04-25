
part of 'contust_cubit.dart';

abstract class ContustState extends Equatable {
  const ContustState();

  @override
  List<Object> get props => [];
}

class ContustInitial extends ContustState {}

class ContactUsLoadingState extends ContustState {}

class ContactUsSuccessState extends ContustState {}
class GetCountrySuccessState extends ContustState {}

class ContactUsErrorState extends ContustState {
  final ResponseModel error;
  ContactUsErrorState(this.error);
}


class FollowSuccess extends ContustState {
  final isHavePet;

  FollowSuccess(this.isHavePet);
}
