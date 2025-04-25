import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:squeak/core/helper/build_service/main_cubit/main_cubit.dart';
import 'package:squeak/features/appointments/clinic/data/datasources/clinic_remote_data_source.dart';
import 'package:squeak/features/appointments/clinic/data/repositories/clinic_repo.dart';
import 'package:squeak/features/appointments/clinic/presentation/cubit/files_and_prescription_for_pet_cubit.dart';
import 'package:squeak/features/appointments/clinic/presentation/widgets/tabel_header.dart';
import 'package:squeak/features/appointments/clinic/presentation/widgets/tabel_singel_record.dart';
import '../../../../../../core/constant/global_function/global_function.dart';
import '../../../../../../core/thames/styles.dart';
import '../../../../models/files_and_prescription_for_pet_model.dart';

class PrescriptionForPetScreen extends StatelessWidget {
  const PrescriptionForPetScreen({
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
              title: isArabic() ? Text("الروشته") : Text("Prescription"),
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
                          height: 24,
                        ),

                        filesAndPrescriptionForPetCubit
                                    .getPrescriptionAndFilesModel
                                    .data!
                                    .prescription ==
                                null
                            ? Column(
                                children: [
                                  SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height / 3,
                                  ),
                                  Text(
                                    isArabic()
                                        ? "لا توجد وصفة طبية لهذه الزيارة."
                                        : "No prescription is available for this appointment.",
                                    style: FontStyleThame.textStyle(
                                      context: context,
                                      fontSize: 18,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Table(
                                    border: TableBorder.all(),
                                    children: [
                                      // Header Row
                                      TableRow(
                                        decoration: BoxDecoration(
                                            color: Colors.grey[300]),
                                        children: [
                                          TableHeader(
                                            tableHeaderName: isArabic()
                                                ? "اسم العقار"
                                                : 'Drug Name',
                                          ),
                                          TableHeader(
                                            tableHeaderName: isArabic()
                                                ? "عدد الجرعات"
                                                : 'Number of unites',
                                          ),
                                          TableHeader(
                                            tableHeaderName: isArabic()
                                                ? "عدد المرات"
                                                : 'Number of times',
                                          ),
                                          TableHeader(
                                            tableHeaderName: isArabic()
                                                ? "عدد الايام"
                                                : 'Number of days',
                                          ),
                                        ],
                                      ),
                                      // Data Rows
                                      for (PrescriptionDrug record
                                          in filesAndPrescriptionForPetCubit
                                                  .getPrescriptionAndFilesModel
                                                  .data
                                                  ?.prescription
                                                  ?.prescriptionDrugs ??
                                              [])
                                        TableRow(
                                          decoration: BoxDecoration(
                                              color: Colors.white),
                                          children: [
                                            TableSingleRecord(
                                              tableRecordName:
                                                  record.drug!.name ?? '',
                                            ),
                                            TableSingleRecord(
                                              tableRecordName:
                                                  record.numberOfUnit! ?? '',
                                            ),
                                            TableSingleRecord(
                                              tableRecordName: record
                                                      .numberOfTime
                                                      .toString() ??
                                                  '',
                                            ),
                                            TableSingleRecord(
                                              tableRecordName: record
                                                      .numberOfDay
                                                      .toString() ??
                                                  '',
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  BlocConsumer<MainCubit, MainState>(
                                    listener: (context, state) {
                                      // TODO: implement listener
                                    },
                                    builder: (context, state) {
                                      return Center(
                                        child: Text(
                                          filesAndPrescriptionForPetCubit
                                                  .getPrescriptionAndFilesModel
                                                  .data!
                                                  .prescription!
                                                  .comment ??
                                              "",
                                          style: FontStyleThame.textStyle(
                                            context: context,
                                            fontSize: 18,
                                            fontColor:
                                                BlocProvider.of<MainCubit>(
                                                            context)
                                                        .isDark
                                                    ? Colors.white
                                                    : Colors.black,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      );
                                    },
                                  )
                                ],
                              ),

                        /// Contact Us
                        SizedBox(
                          height: 12,
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

