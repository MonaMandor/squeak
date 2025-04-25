
part of 'clinic_cubit.dart';
sealed class ClinicState {}

final class ClinicInitial extends ClinicState {}


final class GetAvailabilityLoading extends ClinicState {}
final class GetAvailabilitySuccess extends ClinicState {}
final class GetAvailabilityError extends ClinicState {}

final class GetSupplierLoading extends ClinicState {}
final class GetSupplierSuccess extends ClinicState {}
final class GetSupplierError extends ClinicState {}



final class GetDoctorLoading extends ClinicState {}
final class GetDoctorSuccess extends ClinicState {}
final class GetDoctorError extends ClinicState {}

final class UnFollowLoading extends ClinicState {}
final class UnFollowSuccess extends ClinicState {}
final class UnFollowError extends ClinicState {}

final class isNoSelectStatue extends ClinicState {}

///todo Create Appointments
class CreateAppointmentsLoading extends ClinicState {}
class CreateAppointmentsToVetICareSuccess extends ClinicState {}
class CreateExistedClientAppointment extends ClinicState {}
class CreateNewPetAppointment extends ClinicState {}
class CreateNewPetAndClientAppointment extends ClinicState {}
class CreateAppointmentsSuccess extends ClinicState {}
class CreateAppointmentsError extends ClinicState {
  final ResponseModel responseModel;

  CreateAppointmentsError(this.responseModel);
}