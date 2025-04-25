import 'package:dio/dio.dart';
import 'package:squeak/core/helper/cache/cache_helper.dart';
import 'package:squeak/core/helper/remotely/dio.dart';
import 'package:squeak/core/helper/remotely/end-points.dart';
import 'package:squeak/features/appointments/models/availabilities_model.dart';
import 'package:squeak/features/appointments/models/doctor_model.dart';
import 'package:squeak/features/appointments/models/files_and_prescription_for_pet_model.dart';
import 'package:squeak/features/appointments/models/get_client_clinic_model.dart';
import 'package:squeak/features/layout/models/clinic_model.dart';

abstract class ClinicRemoteDataSource {
  Future<List<AvailabilityModel>> getAvailability(String clinicCode);
  Future<MySupplierModel> getSuppliers();
  Future<List<DoctorModel>> getDoctors(String clinicCode);
 Future<List<ClientClinicModel>> getClientInClinic(String clinicCode);
 Future<void> createAppointment({
    required String endpoint,
    required Map<String, dynamic> data,
  });
  Future<PrescriptionAndFiles> getFilesAndPrescriptionForPet(String reservationId);
}

class ClinicRemoteDataSourceImpl implements ClinicRemoteDataSource {
   @override
  Future<void> createAppointment({
    required String endpoint,
    required Map<String, dynamic> data,
  }) async {
    await DioFinalHelper.postData(method: endpoint, data: data);
  }
  @override
  Future<PrescriptionAndFiles> getFilesAndPrescriptionForPet(String reservationId) async {
    final response = await DioFinalHelper.getData(
      method: getFilesAndPrescriptionForPetEndPoint(reservationid: reservationId),
      language: true,
    );

    return PrescriptionAndFiles.fromJson(response.data);
  }
  
   @override
  Future<List<ClientClinicModel>> getClientInClinic(String clinicCode) async {
    final String phone = CacheHelper.getData('phone');

    final Response response = await DioFinalHelper.getData(
      method: getClientClinicEndPoint(clinicCode, phone),
      language: false,
    );

    return (response.data['data'] as List)
        .map((e) => ClientClinicModel.fromJson(e))
        .toList();
  }
  @override
  Future<List<AvailabilityModel>> getAvailability(String clinicCode) async {
    final response = await DioFinalHelper.getData(
      method: getAvailabilitiesEndPoint(clinicCode),
      language: false,
    );

    final List<AvailabilityModel> all = (response.data['data'] as List)
        .map((e) => AvailabilityModel.fromJson(e))
        .toList();

    return all;
  }
    @override
  Future<MySupplierModel> getSuppliers() async {
    final response = await DioFinalHelper.getData(
      method: getFollowerClinicEndPoint,
      language: false,
    );
    return MySupplierModel.fromJson(response.data['data']);
  }
   @override
  Future<List<DoctorModel>> getDoctors(String clinicCode) async {
    final Response response = await DioFinalHelper.getData(
      method: getDoctorAppointmentsEndPoint(clinicCode),
      language: false,
    );

    return (response.data['data'] as List)
        .map((e) => DoctorModel.fromJson(e))
        .toList();
  }

}
