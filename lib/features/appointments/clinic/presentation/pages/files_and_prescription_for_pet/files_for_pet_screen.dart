import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:squeak/core/helper/remotely/config_model.dart';
import 'package:squeak/features/appointments/clinic/data/datasources/clinic_remote_data_source.dart';
import 'package:squeak/features/appointments/clinic/data/repositories/clinic_repo.dart';
import 'package:squeak/features/appointments/clinic/presentation/cubit/files_and_prescription_for_pet_cubit.dart';
import 'package:squeak/features/appointments/clinic/presentation/pages/files_and_prescription_for_pet/file_card_widget.dart';
import '../../../../../../core/constant/global_function/global_function.dart';
import '../../../../../../core/thames/styles.dart';
import '../../../../../layout/view/search/search_screen.dart';

class FilesForPetScreen extends StatelessWidget {
  const FilesForPetScreen({
    super.key,
    required this.reservationid,
  });

  final String reservationid;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FilesAndPrescriptionForPetCubit(
        ClinicRepositoryImpl(
          ClinicRemoteDataSourceImpl(),
          )
      )
        ..getTheFilesAndPrescriptionForPet(
          reservationid: reservationid,
        ),
      child: BlocConsumer<FilesAndPrescriptionForPetCubit,
          FilesAndPrescriptionForPetState>(
        listener: (context, state) {
          // TODO: implement listener
        },
        builder: (context, state) {
          var filesAndPrescriptionForPetCubit =
              BlocProvider.of<FilesAndPrescriptionForPetCubit>(context);
          return Scaffold(
            appBar: AppBar(
              title: isArabic() ? Text("الملفات") : Text("Files"),
              automaticallyImplyLeading: false,
              leading: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.arrow_back)),
            ),
            body: Padding(
              padding: const EdgeInsets.all(12.0),
              child: filesAndPrescriptionForPetCubit
                      .getTheFilesAndPrescriptionForPetLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView(
                      physics: BouncingScrollPhysics(),
                      children: [
                        SizedBox(
                          height: 12,
                        ),
                        filesAndPrescriptionForPetCubit
                                .getPrescriptionAndFilesModel
                                .data!
                                .files!
                                .isEmpty
                            ? Column(
                                children: [
                                  SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height / 3,
                                  ),
                                  Center(
                                    child: Text(
                                      isArabic()
                                          ? "لا توجد تحاليل طبية لهذه الزيارة."
                                          : "No medical tests available for this appointment.",
                                      textAlign: TextAlign.center,
                                      style: FontStyleThame.textStyle(
                                        context: context,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                itemCount: filesAndPrescriptionForPetCubit
                                    .getPrescriptionAndFilesModel
                                    .data!
                                    .files!
                                    .length,
                                shrinkWrap: true,
                                physics: BouncingScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10),
                                    child: InkWell(
                                      onTap: () {
                                        filesAndPrescriptionForPetCubit
                                                    .getPrescriptionAndFilesModel
                                                    .data!
                                                    .files![index]
                                                    .fileLink !=
                                                null
                                            ? navigateToReference(
                                                imageUrl:
                                                    "${ConfigModel.serverFirstHalfOfImageimageUrl}${filesAndPrescriptionForPetCubit.getPrescriptionAndFilesModel.data!.files![index].fileLink}",
                                              )
                                            : null;
                                      },
                                      child: FileCardWidget(
                                          fileName:
                                              filesAndPrescriptionForPetCubit
                                                  .getPrescriptionAndFilesModel
                                                  .data!
                                                  .files![index]
                                                  .name,
                                          fileDate:
                                              filesAndPrescriptionForPetCubit
                                                  .getPrescriptionAndFilesModel
                                                  .data!
                                                  .files![index]
                                                  .issueDate
                                                  .toString(),
                                          fileDescription:
                                              filesAndPrescriptionForPetCubit
                                                  .getPrescriptionAndFilesModel
                                                  .data!
                                                  .files![index]
                                                  .description),
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}
