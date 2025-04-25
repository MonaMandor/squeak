import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:squeak/core/constant/global_widget/toast.dart';
import 'package:squeak/core/helper/cache/cache_helper.dart';
import 'package:squeak/features/auth/login/data/datasources/login_remote_data_source.dart';
import 'package:squeak/features/auth/login/data/repositories/login_repository.dart';
import 'package:squeak/features/auth/login/presentation/cubit/login_cubit.dart';
import 'package:squeak/features/auth/login/presentation/widgets/login_widget.dart';
import 'package:squeak/features/auth/register/presentation/widgets/authItem.dart';
import 'package:squeak/features/layout/controller/layout_cubit.dart';
import 'package:squeak/features/layout/layout.dart';

import '../../../../../core/thames/styles.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(
        LoginRepository(
          remoteDataSource: LoginRemoteDataSource(
            
          ),
        ),

      ),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginError) {
            errorToast(
              context,
              state.error.errors.isNotEmpty
                  ? state.error.errors.values.first.first
                  : state.error.message,
            );
          }
          if (state is LoginSuccess) {
            CacheHelper.saveData('token', state.userModel.data!.token);
            CacheHelper.saveData('role', state.userModel.data!.role);
            CacheHelper.saveData('clintId', state.userModel.data!.id);
            CacheHelper.saveData(
                'refreshToken', state.userModel.data!.refreshToken);
            CacheHelper.saveData('phone', state.userModel.data!.phone);
            CacheHelper.saveData('name', state.userModel.data!.fullName);
            CacheHelper.saveData(
              'clientName',
              state.userModel.data!.fullName,
            );
            LayoutCubit.get(context).getOwnerPet();
            LayoutCubit.get(context).getOwnerData();
            navigateAndFinish(context, LayoutScreen());
          }
        },
        builder: (context, state) {
          var cubit = LoginCubit.get(context);
          return AuthItem(
            widget: LoginView(
              cubit: cubit,
            ),
          );
        },
      ),
    );
  }
}
