// appointment_remote_data_source.dart

import 'package:squeak/core/helper/remotely/dio.dart';
import 'package:squeak/core/helper/remotely/end-points.dart';
import 'package:squeak/features/appointments/models/get_appointment_model.dart';

class UsertRemoteDataSource {
  Future<List<AppointmentModel>> getAppointmentsFromApi(String phone) async {
    final response = await DioFinalHelper.getData(
      method: createAndGetAppointmentsEndPoint(phone),
      language: true,
    );

    final data = response.data['data']['result'] as List;
    return data.map((e) => AppointmentModel.fromJson(e)).toList();
  }
  Future<void> deleteAppointmentFromApi(String reservationId) async {
    await DioFinalHelper.postData(
      method: deleteAppointmentsEndPoint,
      data: {
        "reservationId": reservationId,
      },
    );
  }
  Future<void> rateAppointmentRequest({
    required String reservationId,
    required int cleanlinessRate,
    required int doctorServiceRate,
    required String feedbackComment,
  }) async {
    await DioFinalHelper.postData(
      method: rateAppointmentEndPoint,
      data: {
        "reservationId": reservationId,
        "cleanlinessRate": cleanlinessRate,
        "doctorServiceRate": doctorServiceRate,
        "feedbackComment": feedbackComment,
      },
    );
  }
}
