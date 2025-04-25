import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:squeak/core/helper/image_helper/helper_model/response_model.dart';
import 'package:squeak/core/helper/remotely/dio.dart';
import 'package:squeak/core/helper/remotely/end-points.dart';
import 'package:squeak/features/appointments/models/availabilities_model.dart';
import 'package:squeak/features/appointments/models/doctor_model.dart';
import 'package:squeak/features/appointments/models/get_client_clinic_model.dart';
import 'package:squeak/features/appointments/clinic/data/repositories/clinic_repo.dart';
import 'package:squeak/features/layout/models/clinic_model.dart';

import '../../../../../core/helper/cache/cache_helper.dart';
 part 'clinic_state.dart';

class ClinicCubit extends Cubit<ClinicState> {
  final ClinicRepository repository;

  ClinicCubit(this.repository) : super(ClinicInitial());

  static ClinicCubit get(context) =>
      BlocProvider.of<ClinicCubit>(context);

  void init() {
    if (CacheHelper.getData('suppliers') != null) {
      String stringToJason = CacheHelper.getData('suppliers')!;
      var jsonToMap = json.decode(stringToJason);
      suppliers = MySupplierModel.fromJson(jsonToMap);
      filteredSuppliers = suppliers!.data;
      emit(GetSupplierSuccess());
    }
    getSupplier();
  }

  List<AvailabilityModel> availabilities = [];

  TextEditingController commentController = TextEditingController();

  AvailabilityModel? selectedTime;
  List<TimeOfDay> timeSlots = [];
  TimeOfDay? selectedTimeSlot;

  DateTime? selectedDate;
  bool isLoadingAvailability = false;

  Future<void> getAvailability(String clinicCode) async {
    isLoadingAvailability = true;
    emit(GetAvailabilityLoading());

    try {
      final results = await repository.getFilteredAvailability(clinicCode);
      availabilities = results;

      for (var element in availabilities) {
        print(element.toJson());
      }

      isLoadingAvailability = false;
      emit(GetAvailabilitySuccess());
    } catch (e) {
      print(e);
      isLoadingAvailability = false;
      emit(GetAvailabilityError());
    }
  }

  List<AvailabilityModel> removeDuplicatesByDayOfWeek(
      List<AvailabilityModel> availabilityList) {
    final uniqueDays = <DayOfWeek>{};
    return availabilityList.where((availability) {
      if (uniqueDays.contains(availability.dayOfWeek)) {
        return false;
      } else {
        uniqueDays.add(availability.dayOfWeek);
        return true;
      }
    }).toList();
  }

  MySupplierModel? suppliers;
  List<ClinicInfo> filteredSuppliers = [];
  Future<void> getSupplier() async {
    emit(GetSupplierLoading());

    try {
      final result = await repository.fetchSuppliersAndCache();
      suppliers = result;
      filteredSuppliers = result.data;
      emit(GetSupplierSuccess());
    } catch (e) {
      print(e);
      emit(GetSupplierError());
    }
  }

  TextEditingController searchController = TextEditingController();

  void filterSuppliers(String query) {
    filteredSuppliers = suppliers!.data
        .where((supplier) =>
            supplier.data.name.toLowerCase().contains(query.toLowerCase()) ||
            supplier.data.code.toLowerCase().contains(query.toLowerCase()))
        .toList();
    emit(GetSupplierSuccess());
  }

  Future unFollow(ClinicId) async {
    emit(UnFollowLoading());
    try {
      Response response = await DioFinalHelper.postData(
        method: unfollowClinicEndPoint,
        data: {
          'ClinicId': ClinicId,
        },
      );
      print(response.data);
      emit(UnFollowSuccess());
    } on DioException catch (e) {
      print(e);
      emit(UnFollowError());
    }
  }

  List<DoctorModel> doctors = [];

  bool isNoSelect = false;
  void isNoSelectVoid(bool error) {
    isNoSelect = error;
    emit(isNoSelectStatue());
  }

  Future<void> getDoctor(String clinicCode) async {
    emit(GetDoctorLoading());

    try {
      doctors = await repository.fetchDoctors(clinicCode);
      print(doctors);
      emit(GetDoctorSuccess());
    } catch (e) {
      print(e);
      emit(GetDoctorError());
    }
  }

  bool clientINClinic = false;

  List<ClientClinicModel> petListInVet = [];
  Future<void> getClientINClinic(String clinicCode) async {
    emit(GetDoctorLoading());
    try {
      petListInVet = await repository.fetchClientInClinic(clinicCode);
      clientINClinic = true;
      print(petListInVet);
      emit(GetDoctorSuccess());
    } catch (e) {
      print(e);
      emit(GetDoctorError());
    }
  }

  bool isLoading = false;

  String convertLocalTimeToUTC(String time) {
    if (time.isEmpty) {
      return '';
    }

    // Split the time string into hours, minutes, and seconds
    final parts = time.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    final seconds = int.parse(parts[2]);

    // Create a DateTime object with the provided time in local time zone
    DateTime localDate = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, hours, minutes, seconds);

    // Convert local time to UTC
    DateTime utcDate = localDate.toUtc();

    // Format the UTC hours, minutes, and seconds to always have two digits
    String utcHours = utcDate.hour.toString().padLeft(2, '0');
    String utcMinutes = utcDate.minute.toString().padLeft(2, '0');
    String utcSeconds = utcDate.second.toString().padLeft(2, '0');

    return '$utcHours:$utcMinutes:$utcSeconds';
  }

  Future createAppointment({
    required String petId,
    String? doctorId,
    required String clinicCode,
    required String appointmentTime,
    required String appointmentDate,
    required int petGender,
    required String petName,
    required String clientId,
    required String petSqueakId,
    required bool isExisted,
    required bool notExistedOrPet,
    required bool isExistedNoPet,
    required bool isSpayed,
  }) async {
    isLoading = true;
    appointmentTime = convertLocalTimeToUTC(appointmentTime);
    emit(CreateAppointmentsLoading());

    try {
      if (isExisted) {
        print('isExisted');
        await repository.createAppointment(
          endpoint: '$version/vetcare/reservation/existedClient',
          data: {
            "date": appointmentDate,
            "time": appointmentTime,
            "petId": petId,
            "clinicCode": clinicCode,
            'doctorUserId': doctorId,
            "clientId": petListInVet.first.clientId,
            "petSqueakId": petSqueakId,
          },
        );
        emit(CreateExistedClientAppointment());
      } else if (isExistedNoPet) {
        await repository.createAppointment(
          endpoint: '$version/vetcare/reservation/newPet',
          data: {
            "date": appointmentDate,
            "time": appointmentTime,
            "clinicCode": clinicCode,
            "clientId": clientId,
            'doctorUserId': doctorId,
            "pet": {
              "petName": petName,
              "petGender": petGender,
              "breedId": null,
              "specieId": null,
              "isSpayed": isSpayed,
            },
            "squeakPetId": petSqueakId
          },
        );
        emit(CreateNewPetAppointment());
      } else if (notExistedOrPet) {
        await repository.createAppointment(
          endpoint: '$version/vetcare/reservation/newPet/newClient',
          data: {
            "date": appointmentDate,
            "time": appointmentTime,
            "clinicCode": clinicCode,
            'doctorUserId': doctorId,
            "pet": {
              "petName": petName,
              "petGender": petGender,
              "squeakPetId": petSqueakId,
              "isSpayed": isSpayed,
              "breedId": null,
              "specieId": null,
            },
            "client": {
              "name": CacheHelper.getData('clientName'),
              "squeakClientId": CacheHelper.getData('clintId'),
              'countryId': CacheHelper.getData('countryId'),
              "phone": CacheHelper.getData('phone'),
              "gender": 1,
            },
          },
        );
        emit(CreateNewPetAndClientAppointment());
      }

      isLoading = false;
      emit(CreateAppointmentsSuccess());
    } on DioException catch (e) {
      print(e.response!.data);
      isLoading = false;
      emit(CreateAppointmentsError(ResponseModel.fromJson(e.response!.data)));
    }
  }

  Future<void> _createAppointment({
    required String method,
    required Map<String, dynamic> data,
    required successEmit,
  }) async {
    Response response = await DioFinalHelper.postData(
      method: method,
      data: data,
    );

    print(response.data);
    emit(successEmit);
  }
}
