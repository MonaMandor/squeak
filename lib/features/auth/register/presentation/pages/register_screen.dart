import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:squeak/features/auth/register/data/datasources/register_remote_data_source.dart';
import 'package:squeak/features/auth/register/data/repositories/register_repository.dart';
import 'package:squeak/features/auth/register/presentation/cubit/register_cubit.dart';
import 'package:squeak/features/auth/password/presentation/pages/verfiy_user_screen.dart';
import 'package:squeak/features/auth/register/presentation/widgets/authItem.dart';
import 'package:squeak/features/auth/register/presentation/widgets/register_widget.dart';

import '../../../../../core/constant/global_widget/toast.dart';
import '../../../../../core/thames/styles.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(
        RegisterRepository(
        RegisterRemoteDataSource()
        ),

      )
        ..getCountry('')
        ..getCountryCode(),
      child: BlocConsumer<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state is ErrorRegisterState) {
            errorToast(
              context,
              state.error.errors.isNotEmpty
                  ? state.error.errors.values.first.first
                  : state.error.message,
            );
          }
          if (state is SuccessRegisterState) {
            navigateAndFinish(
              context,
              VerifyUser(
                emailController: RegisterCubit.get(context).emailController,
              ),
            );
          }
        },
        builder: (context, state) {
          var cubit = RegisterCubit.get(context);
          return AuthItem(
            widget: RegisterView(
              cubit: cubit,
            ),
          );
        },
      ),
    );
  }
}
