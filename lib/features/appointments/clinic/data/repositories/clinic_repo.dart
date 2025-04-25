import 'dart:convert';

import 'package:squeak/core/helper/cache/cache_helper.dart';
import 'package:squeak/features/appointments/models/availabilities_model.dart';
import 'package:squeak/features/appointments/models/doctor_model.dart';
import 'package:squeak/features/appointments/models/files_and_prescription_for_pet_model.dart';
import 'package:squeak/features/appointments/models/get_client_clinic_model.dart';
import 'package:squeak/features/appointments/clinic/data/datasources/clinic_remote_data_source.dart';
import 'package:squeak/features/layout/models/clinic_model.dart';

abstract class ClinicRepository {
  Future<List<AvailabilityModel>> getFilteredAvailability(String clinicCode);
  Future<MySupplierModel> fetchSuppliersAndCache();
  Future<List<DoctorModel>> fetchDoctors(String clinicCode);
  Future<List<ClientClinicModel>> fetchClientInClinic(String clinicCode);
   Future<void> createAppointment({
    required String endpoint,
    required Map<String, dynamic> data,
  });
    Future<PrescriptionAndFiles> getFilesAndPrescriptionForPet(String reservationId);
}

class ClinicRepositoryImpl implements ClinicRepository {
  final ClinicRemoteDataSource remoteDataSource;

  ClinicRepositoryImpl(this.remoteDataSource);
  
  @override
  Future<List<ClientClinicModel>> fetchClientInClinic(String clinicCode) {
    return remoteDataSource.getClientInClinic(clinicCode);
  }
@override

  @override
  Future<PrescriptionAndFiles> getFilesAndPrescriptionForPet(String reservationId) {
    return remoteDataSource.getFilesAndPrescriptionForPet(reservationId);
  }
  @override
  Future<void> createAppointment({
    required String endpoint,
    required Map<String, dynamic> data,
  }) {
    return remoteDataSource.createAppointment(endpoint: endpoint, data: data);
  }
  @override
  Future<List<AvailabilityModel>> getFilteredAvailability(
      String clinicCode) async {
    final allAvailabilities =
        await remoteDataSource.getAvailability(clinicCode);

    final unique = <DayOfWeek>{};
    final filtered = allAvailabilities.where((availability) {
      if (unique.contains(availability.dayOfWeek)) {
        return false;
      } else {
        unique.add(availability.dayOfWeek);
        return true;
      }
    }).toList();

    return filtered.where((e) => e.isActive == true).toList();
  }

  @override
  Future<MySupplierModel> fetchSuppliersAndCache() async {
    final suppliers = await remoteDataSource.getSuppliers();

    await CacheHelper.removeData('suppliers');

    return suppliers;
  }
  
  @override
  Future<List<DoctorModel>> fetchDoctors(String clinicCode) {
    return remoteDataSource.getDoctors(clinicCode);
  }
}
