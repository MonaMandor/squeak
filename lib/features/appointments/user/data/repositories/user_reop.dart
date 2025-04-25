// appointment_repository.dart

import 'package:squeak/features/appointments/models/get_appointment_model.dart';
import 'package:squeak/features/appointments/user/data/datasources/user_data_sourse.dart';

abstract class UsertRepo {
  Future<List<AppointmentModel>> getAppointments(String phone);
  Future<void> deleteAppointment(String reservationId);
  Future<void> rateAppointment({
    required String reservationId,
    required int cleanlinessRate,
    required int doctorServiceRate,
    required String feedbackComment,
  });
}

class UsertRepoImpl implements UsertRepo {
  final UsertRemoteDataSource remoteDataSource;

  UsertRepoImpl(this.remoteDataSource);

  @override
  Future<List<AppointmentModel>> getAppointments(String phone) {
    return remoteDataSource.getAppointmentsFromApi(phone);
  }
    @override
  Future<void> deleteAppointment(String reservationId) {
    return remoteDataSource.deleteAppointmentFromApi(reservationId);
  }
  
  @override
  Future<void> rateAppointment({
    required String reservationId,
    required int cleanlinessRate,
    required int doctorServiceRate,
    required String feedbackComment,
  }) {
    return remoteDataSource.rateAppointmentRequest(
      reservationId: reservationId,
      cleanlinessRate: cleanlinessRate,
      doctorServiceRate: doctorServiceRate,
      feedbackComment: feedbackComment,
    );
  }

}
