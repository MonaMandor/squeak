// contust_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:squeak/core/helper/cache/cache_helper.dart';
import 'package:squeak/features/auth/contust/data/repositories/contust_repository.dart';
import 'package:squeak/features/vetcare/models/vetIcare_client_model.dart';
import 'package:squeak/core/helper/image_helper/helper_model/response_model.dart';
import 'package:squeak/features/auth/login/presentation/cubit/login_cubit.dart';
import 'package:squeak/features/layout/controller/layout_cubit.dart';
import 'package:equatable/src/equatable.dart';
part 'contust_state.dart';


class ContustCubit extends Cubit<ContustState> {
  static ContustCubit get(BuildContext context) => BlocProvider.of(context);
  
  final ContustRepository repository;
  ContustCubit(this.repository) : super(ContustInitial());
  
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final codeController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final countryId = TextEditingController();
  final commentController = TextEditingController();
  final titleController = TextEditingController();
  final nameController = TextEditingController();
  final followCodeController = TextEditingController();
  
  bool isAccept = true;

  void init(context) {
    if (CacheHelper.getData('phone') != null) {
      var c = LayoutCubit.get(context);
      emailController.text = c.profile.email;
      nameController.text = c.profile.fullName;
      phoneController.text = c.profile.phone;
    }
  }

  bool isContactUs = false;

  Future<void> contactUs() async {
    isContactUs = true;
    emit(ContactUsLoadingState());
    try {
      final response = await repository.contactUs(
        title: titleController.text,
        phone: phoneController.text,
        fullName: nameController.text,
        comment: commentController.text,
        email: emailController.text,
      );
      isContactUs = false;
      emit(ContactUsSuccessState());
    } catch (e) {
      isContactUs = false;
      emit(ContactUsErrorState(ResponseModel.fromJson(e is Map<String, dynamic> ? e : {})));
    }
  }

  List<VetClientModel> vetClientModel = [];

  Future<List<VetClientModel>> getClintFormVetVoid(
      BuildContext context, String code, bool isFilter) async {
    LoginCubit.get(context).isLoggedIn = true;
    try {
      vetClientModel = await repository.getClintFormVetVoid(
        code: code,
        phone: CacheHelper.getData('phone'),
        isFilter: isFilter,
      );
      LoginCubit.get(context).isLoggedIn = true;
      return vetClientModel;
    } catch (e) {
      LoginCubit.get(context).isLoggedIn = false;
      emit(FollowSuccess(false));
      return [];
    }
  }

  void clearContactUs() {
    titleController.clear();
    phoneController.clear();
    nameController.clear();
    commentController.clear();
    emailController.clear();
  }
}
