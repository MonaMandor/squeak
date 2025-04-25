
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:phone_text_field/model/phone_number.dart';
import 'package:squeak/core/constant/global_function/global_function.dart';
import 'package:squeak/core/helper/cache/cache_helper.dart';
import 'package:squeak/core/helper/image_helper/helper_model/response_model.dart';
import 'package:squeak/features/auth/login/presentation/cubit/login_cubit.dart';
import 'package:squeak/features/auth/register/data/models/country_model.dart';
import 'package:squeak/features/auth/register/data/repositories/register_repository.dart';
import 'package:squeak/features/layout/controller/layout_cubit.dart';
import 'package:squeak/features/vetcare/models/vetIcare_client_model.dart';
//import 'package:geolocator/geolocator.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  static RegisterCubit get(BuildContext context) => BlocProvider.of(context);
  final RegisterRepository repository;

  RegisterCubit(this.repository) : super(RegisterInitial());

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

  void clearRegister() {
    passwordController.clear();
    phoneController.clear();
    nameController.clear();
  }

  bool isRegister = false;

  String countryCode = "EG";
  String countryPhoneCode = "+20";
  int countryIdToServer = 1;
  List<CountryModel> countries = [];

  String? password;
  String? Username;


  setCountryCodeAuto({required newCountryCode}) {
    countryCode = newCountryCode;
    emit(GetCurrentCountryCodeSuccessState());
  }

  Future<String?> getCountryCode() async {
      emit(GetCurrentCountryCodeLoadingState());
    /* try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(GetCurrentCountryCodeErrorState());
          return "Permission Denied";
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(GetCurrentCountryCodeErrorState());
        return "Permission Denied Forever";
      }

      // Get the current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse geocode to get the country name
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
        // 29.2156484,
        // 11.2156484,
      );

      if (placemarks.isNotEmpty) {
        String countryName = placemarks.first.country ?? "Unknown";
        CacheHelper.saveData('countryNameE', countryName);
        print("####################");
        print(countryName);

        countries.forEach((e) {
          if (e.name == countryName) {
            countryPhoneCode = e.phoneCode;
            countryIdToServer = e.id;
            print("YESSSS");
          }
        });
        setCountryCodeAuto(newCountryCode: countryName);
        emit(GetCurrentCountryCodeSuccessState());
        return countryName; // Example: "Egypt", "United States", "India"
      }
    } catch (e) {
      emit(GetCurrentCountryCodeErrorState());
      print("Error getting country name: $e");
    }
    return null;  */
  }


  Future<void> getCountry(String name) async {
    getTokenFormFirebase();
    try {
      String username = Username ?? 'Ahmed.Omar@Veticare.com';
      String passwordBasic = password ?? 'Password@123';
      String basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$passwordBasic'));

      // Use repository to get country
      countries = await repository.getCountry(name);
      countries.removeWhere((element) => element.id == 2);
      emit(GetCountrySuccessState());
    } catch (e) {
      emit(GetCurrentCountryCodeErrorState());
      print("Error getting country: $e");
    }
  }

  Future<void> getTokenFormFirebase() async {
    try {
      await FirebaseFirestore.instance
          .collection('UserToken')
          .doc('Is0fJjcbMCqOrWmQdKoj')
          .snapshots()
          .listen((event) {
        print(event.data());
        Username = event.data()!['Username'];
        password = event.data()!['password'];
      });
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<void> register() async {
    isRegister = true;
    var phone = phoneController.text;
    print(phone);

    emit(LoadingRegisterState());

    try {
      // Use repository to register the user
      await repository.register({
        "fullName": nameController.text,
        "email": emailController.text,
        "password": passwordController.text,
        "Gender": 1,
        "PasswordConfirm": passwordController.text,
        "userName": emailController.text,
        "userType": 1,
        "countryId": countryIdToServer,
        "phone": phone,
      });

      isRegister = false;
      clearRegister();
      CacheHelper.saveData("followCode", followCodeController.text.trim());
      emit(SuccessRegisterState());
    } catch (e) {
      isRegister = false;
      print(e);
      emit(ErrorRegisterState(ResponseModel.fromJson(e is Map<String, dynamic> ? e : {})));
     
    }
  }

  Future<void> registerQr(clinicCode, context) async {
    LoginCubit.get(context).isLoggedIn = true;
    var phone = phoneController.text;
    phone = normalizePhoneNumber(phone);
    print(phone);

    emit(LoadingRegisterState());

    try {
      await repository.registerQr({
        "fullName": nameController.text,
        "phoneNumber": phone,
        "email": emailController.text,
        "password": passwordController.text,
        "countryId": CacheHelper.getData('countryId') == '+20' ? 1 : CacheHelper.getData('countryId'),
        "clinicCode": clinicCode,
        "allToShareDataWithVetICare": isAccept,
        "gender": 1,
      });

      LoginCubit.get(context).login(context);
      emit(SuccessRegisterState());
    } catch (e) {
      LoginCubit.get(context).isLoggedIn = false;
      print(e);
      emit(ErrorRegisterState(ResponseModel.fromJson(e is Map<String, dynamic> ? e : {})));
    }
  }

  Future<List<VetClientModel>> getClintFormVetVoid(BuildContext context, String code, bool isFilter) async {
    LoginCubit.get(context).isLoggedIn = true;
    try {
      List<VetClientModel> vetClientModel = await repository.getClients(code, CacheHelper.getData('phone'), isFilter);
      LoginCubit.get(context).isLoggedIn = true;
      return vetClientModel;
    } catch (e) {
      LoginCubit.get(context).isLoggedIn = false;
      emit(FollowSuccess(false));
      return []; // Return an empty list in case of an error
    }
  }
}
