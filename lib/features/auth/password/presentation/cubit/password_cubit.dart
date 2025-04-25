// password_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phone_text_field/model/phone_number.dart';
import 'package:squeak/core/helper/cache/cache_helper.dart';
import 'package:squeak/core/helper/image_helper/helper_model/response_model.dart';
import 'package:squeak/features/auth/password/data/repositories/password_repo.dart';
import 'package:squeak/features/layout/controller/layout_cubit.dart';
import 'package:equatable/src/equatable.dart';
part 'password_state.dart';

class PasswordCubit extends Cubit<PasswordState> {
  static PasswordCubit get(BuildContext context) => BlocProvider.of(context);
  final PasswordRepo passwordRepo;

  PasswordCubit({required this.passwordRepo}) : super(PasswordInitial());

  bool isRestPassword = false;
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final codeController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final countryId = TextEditingController();
  final nameController = TextEditingController();
  final followCodeController = TextEditingController();

  bool isAccept = true;

  void allToShareDataWithVetICare() {
    isAccept = !isAccept;
    emit(LoadingRegisterState());
  }

  void init(context) {
    if (CacheHelper.getData('phone') != null) {
      var c = LayoutCubit.get(context);
      emailController.text = c.profile.email;
      nameController.text = c.profile.fullName;
      phoneController.text = c.profile.phone;
    }
  }

  PhoneNumber? phoneNumber;

  bool isForgetPassword = false;

  Future<void> forgetPassword() async {
    isForgetPassword = true;
    emit(ForgetPasswordLoadingState());
    try {
      final response = await passwordRepo.forgetPassword(emailController.text);
      isForgetPassword = false;
      emit(ForgetPasswordSuccessState());
    } catch (e) {
      isForgetPassword = false;
      emit(ForgetPasswordErrorState(ResponseModel.fromJson(e is Map<String, dynamic> ? e : {})));
    }
  }

  Future<void> restPassword(emailController) async {
    isRestPassword = true;
    emit(RestPasswordLoadingState());
    try {
      final response = await passwordRepo.resetPassword(
        emailController,
        codeController.text,
        passwordController.text,
      );
      isRestPassword = false;
      emit(RestPasswordSuccessState(response));
    } catch (e) {
      isRestPassword = false;
      emit(RestPasswordErrorState(ResponseModel.fromJson(e is Map<String, dynamic> ? e : {})));
    }
  }

  bool isVerifyUser = false;

  Future<void> verifyUser(tokenCode, email) async {
    isVerifyUser = true;
    emit(VerifyUserLoadingState());
    try {
      final response = await passwordRepo.verifyUser(
        email,
        tokenCode,
        followCodeController.text.trim(),
      );
      isVerifyUser = false;
      emit(VerifyUserSuccessState());
    } catch (e) {
      isVerifyUser = false;
      emit(VerifyUserErrorState(ResponseModel.fromJson(e is Map<String, dynamic> ? e : {})));
    }
  }

  initTheVerifyUser({required newOtp}) {
    followCodeController.text = CacheHelper.getData("followCode") ?? "";
  }
}
