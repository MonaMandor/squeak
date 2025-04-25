import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:squeak/features/appointments/models/files_and_prescription_for_pet_model.dart';
import 'package:squeak/features/appointments/clinic/data/repositories/clinic_repo.dart';


part 'files_and_prescription_for_pet_state.dart';

class FilesAndPrescriptionForPetCubit
    extends Cubit<FilesAndPrescriptionForPetState> {
      final ClinicRepository repository;

  FilesAndPrescriptionForPetCubit(this.repository)
      : super(FilesAndPrescriptionForPetInitial());

  late PrescriptionAndFiles getPrescriptionAndFilesModel;
  bool getTheFilesAndPrescriptionForPetLoading = false;

  void getTheFilesAndPrescriptionForPet({required String reservationid}) async {
    getTheFilesAndPrescriptionForPetLoading = true;
    

    try {
      final data = await repository.getFilesAndPrescriptionForPet(reservationid);
      getPrescriptionAndFilesModel = data;

      print("************************************");
      print(getPrescriptionAndFilesModel.data?.files?.isEmpty);

      getTheFilesAndPrescriptionForPetLoading = false;
      emit(GetFilesAndPrescriptionForPetSuccessState());
    } on DioException catch (e) {
      print(e);
      getTheFilesAndPrescriptionForPetLoading = false;
      emit(GetFilesAndPrescriptionForPetErrorState());
    }
  }
}
