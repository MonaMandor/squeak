import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:squeak/core/constant/global_function/global_function.dart';
import 'package:squeak/core/helper/cache/cache_helper.dart';
import 'package:squeak/features/auth/password/data/datasources/password_remote_data_source.dart';
import 'package:squeak/features/auth/password/data/repositories/password_repo.dart';
import 'package:squeak/features/auth/password/presentation/cubit/password_cubit.dart';

import 'package:squeak/features/auth/register/presentation/pages/register_screen.dart';

import '../../../../../core/constant/global_function/custom_text_form_field.dart';
import '../../../../../core/constant/global_widget/toast.dart';
import '../../../../../core/thames/styles.dart';
import '../../../../../generated/l10n.dart';
import '../../../contust/presentation/pages/contact_us.dart';
import '../../../login/presentation/pages/login_screen.dart';

class VerifyUser extends StatelessWidget {
  VerifyUser({
    super.key,
    required this.emailController,
  });

  final TextEditingController emailController;
  final List<TextEditingController> controllers =
      List.generate(4, (index) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(4, (index) => FocusNode());

  void submitForm(context) {
    bool isValid = true;
    for (int i = 0; i < controllers.length; i++) {
      String value = controllers[i].text.trim();
      if (value.isEmpty || value.length != 1) {
        isValid = false;
        break;
      }
    }

    if (isValid) {
      String otp = controllers.map((controller) => controller.text).join();

      PasswordCubit.get(context).verifyUser(otp, emailController.text);
    } else {
      errorToast(
        context,
        'Please enter a valid code',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PasswordCubit(
         passwordRepo: PasswordRepo(
          remoteDataSource: 
      PasswordRemoteDataSource()
        ),
      )
        ..initTheVerifyUser(newOtp: CacheHelper.getData("initTheVerifyUser")),
      child: BlocConsumer<PasswordCubit, PasswordState>(
        listener: (context, state) {
          if (state is VerifyUserErrorState) {
            errorToast(
              context,
              state.error.errors.isNotEmpty
                  ? state.error.errors.values.first.first
                  : state.error.message,
            );
          }

          if (state is VerifyUserSuccessState) {
            navigateAndFinish(
              context,
              LoginScreen(),
            );
          }
        },
        builder: (context, state) {
          var cubit = PasswordCubit.get(context);
          return WillPopScope(
            onWillPop: () async {
              navigateAndFinish(context, RegisterScreen());
              return false;
            },
            child: Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text(S.of(context).verification),
                elevation: 0,
                leading: IconButton(
                  onPressed: () {
                    navigateAndFinish(context, RegisterScreen());
                  },
                  icon: Icon(isArabic()
                      ? IconlyLight.arrow_right_2
                      : IconlyLight.arrow_left_2),
                ),
                actions: [
                  InkWell(
                    onTap: () {
                      navigateToScreen(context, ContactScreen());
                    },
                    borderRadius: BorderRadius.circular(100),
                    child: Card(
                      shape: CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.help,
                          size: 25,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Form(
                    key: cubit.formKey,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Text.rich(
                          TextSpan(
                            text: isArabic()
                                ? 'من فضلك ادخل رمز التحقق على بريدك الالكتروني '
                                : 'Please enter the verification code on your email ',
                            style: FontStyleThame.textStyle(
                              context: context,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              fontColor: Colors.black,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: emailController.text,
                                style: FontStyleThame.textStyle(
                                  context: context,
                                  fontSize: 18, // Increase font size
                                  fontWeight: FontWeight.bold, // Make text bold
                                  fontColor: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 300,
                          child: CachedNetworkImage(
                            height: 300,
                            imageUrl:
                                'https://firebasestorage.googleapis.com/v0/b/educational-platform-1e5d7.appspot.com/o/demand-insurance-service-digital-insurer-mobile-app-innovative-business-model-female-customer-ordering-insurance-policy-online.png?alt=media&token=f0862a0f-84ca-4ed0-9264-313967346976',
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(
                            4,
                            (index) {
                              return SizedBox(
                                width: 56,
                                height: 52,
                                child: TextFormField(
                                  controller: controllers[index],
                                  keyboardType: TextInputType.text,
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  onChanged: (value) {
                                    if (value.isNotEmpty && index < 3) {
                                      // Move to next field if the user enters a value
                                      FocusScope.of(context)
                                          .requestFocus(focusNodes[index + 1]);
                                    } else if (value.isEmpty && index > 0) {
                                      // Move back if empty and the user presses backspace
                                      FocusScope.of(context)
                                          .requestFocus(focusNodes[index - 1]);
                                    }

                                    // Auto-submit if all fields are filled
                                    if (controllers.every((controller) =>
                                        controller.text.isNotEmpty)) {
                                      submitForm(context);
                                    }
                                  },
                                  onEditingComplete: () {
                                    if (index > 0) {
                                      FocusScope.of(context)
                                          .requestFocus(focusNodes[index - 1]);
                                    }
                                    if (index == 3) {
                                      if (cubit.formKey.currentState!
                                          .validate()) {
                                        submitForm(context);
                                      }
                                    }
                                  },
                                  focusNode: focusNodes[index],
                                  decoration: InputDecoration(
                                    counterText: "", // Hide the character count
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.blue),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        cubit.followCodeController.text.isNotEmpty
                            ? MyTextForm(
                                controller: cubit.followCodeController,
                                prefixIcon: const Icon(
                                  Icons.person,
                                  size: 14,
                                ),
                                enable: false,
                                hintText: S.of(context).followCode,
                                // validatorText: S.of(context).enterName,
                                obscureText: false,
                                keyboardType: TextInputType.text,
                              )
                            : SizedBox(),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: ColorTheme.primaryColor,
                            ),
                            onPressed: cubit.isVerifyUser
                                ? null
                                : () {
                                    if (cubit.formKey.currentState!
                                        .validate()) {
                                      submitForm(context);
                                    }
                                  },
                            child: cubit.isVerifyUser
                                ? CircularProgressIndicator()
                                : Text(S.of(context).verification),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
