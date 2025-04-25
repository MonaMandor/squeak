import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:squeak/core/helper/cache/cache_helper.dart';
import 'package:squeak/core/helper/image_helper/helper_model/response_model.dart';
import 'package:squeak/core/helper/build_service/main_cubit/main_cubit.dart';
import 'package:squeak/core/constant/global_function/global_function.dart';
import 'package:flutter/material.dart';
import 'package:squeak/features/auth/login/data/models/auth_model.dart';
import 'package:squeak/features/auth/login/data/repositories/login_repository.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  static LoginCubit get(BuildContext context) => BlocProvider.of(context);
  final LoginRepository repository;

  LoginCubit(this.repository) : super(LoginInitial());

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoggedIn = false;

  Future<void> login(BuildContext context) async {
    isLoggedIn = true;
    emit(LoginLoading());

    try {
      String emailOrPhone = emailController.text;
      if (!isEmail(emailOrPhone)) {
        emailOrPhone = normalizePhoneNumber(emailOrPhone);
      }

      final model = await repository.login(
        emailOrPhoneNumber: emailOrPhone,
        password: passwordController.text,
      );

      CacheHelper.saveData('token', model.data?.token);
      MainCubit.get(context).saveToken();

      clearFields();

      isLoggedIn = false;
      emit(LoginSuccess(model));
    } catch (e) {
      isLoggedIn = false;
      if (e is DioException) {
        emit(LoginError(ResponseModel.fromJson(e.response?.data)));
      } else {
        emit(LoginError(ResponseModel(
          message: e.toString(),
          errors: {},
          success: false,
          statusCode: 500,
        )));
      }
    }
  }

  void clearFields() {
    emailController.clear();
    passwordController.clear();
  }
}
