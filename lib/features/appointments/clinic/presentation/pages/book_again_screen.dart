import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:shimmer/shimmer.dart';
import 'package:squeak/core/constant/global_widget/toast.dart';
import 'package:squeak/core/thames/styles.dart';
import 'package:squeak/features/appointments/clinic/data/datasources/clinic_remote_data_source.dart';
import 'package:squeak/features/appointments/clinic/data/repositories/clinic_repo.dart';
import 'package:squeak/features/appointments/clinic/presentation/cubit/clinic_cubit.dart';
import 'package:squeak/features/appointments/models/doctor_model.dart';
import 'package:squeak/features/appointments/models/get_client_clinic_model.dart';
import 'package:squeak/features/appointments/user/presentation/widgets/CustomCalendarDatePicker.dart';
import 'package:intl/intl.dart';
import 'package:squeak/features/appointments/clinic/presentation/widgets/calender_shimmer_widget.dart';
import '../../../../../core/constant/global_function/global_function.dart';
import '../../../../../core/helper/build_service/main_cubit/main_cubit.dart';
import '../../../../../core/thames/color_manager.dart';
import '../../../../../core/thames/decorations.dart';
import '../../../../../generated/l10n.dart';
import '../../../../layout/controller/layout_cubit.dart';
import '../../../../layout/layout.dart';

/// Booking again Screen melkerm
class BooKAgainScreen extends StatelessWidget {
  BooKAgainScreen({
    super.key,
    required this.clinicCode,
    required this.petId,
  });
  final String clinicCode;
  final String petId;
  var dateController = TextEditingController();
  String? time;

  ClientClinicModel? findPet(List<ClientClinicModel> data, String petId) {
    for (var element in data) {
      if (element.petId == petId) {
        return element;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ClinicCubit(
        ClinicRepositoryImpl(
          ClinicRemoteDataSourceImpl(
           
          ),
        )
       
      )
        ..getAvailability(clinicCode)
        ..getClientINClinic(clinicCode)
        ..getDoctor(clinicCode),
      child: BlocConsumer<ClinicCubit, ClinicState>(
        listener: (context, state) {
          if (state is CreateAppointmentsSuccess) {
            LayoutCubit.get(context).changeBottomNav(2);
            LayoutCubit.get(context).pets.forEach((element) {
              element.isSelected = false;
            });
            navigateAndFinish(context, LayoutScreen());
          }
          if (state is CreateAppointmentsError) {
            errorToast(
              context,
              state.responseModel.errors.isNotEmpty
                  ? state.responseModel.errors.values.first.first
                  : state.responseModel.message,
            );
          }
        },
        builder: (context, state) {
          var cubit = ClinicCubit.get(context);

          return Scaffold(
            appBar: AppBar(
              title: Text(S.of(context).appointmentButtonBooking),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 100,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor:
                            ColorTheme.primaryColor.withOpacity(.2),
                      ),
                      onPressed: cubit.isLoading
                          ? null
                          : () {
                              if (dateController.text.isEmpty || time == null) {
                                infoToast(
                                  context,
                                  dateController.text.isEmpty
                                      ? isArabic()
                                          ? 'الرجاء تحديد التاريخ '
                                          : 'Please select date'
                                      : isArabic()
                                          ? "الرجاء تحديد الوقت"
                                          : 'Please select time',
                                );
                              } else {
                                ClientClinicModel? matchedPet;
                                matchedPet = findPet(cubit.petListInVet, petId);
                                if (matchedPet == null) {
                                  infoToast(
                                    context,
                                    isArabic()
                                        ? 'الحيوان غير موجود'
                                        : 'The pet is not found',
                                  );
                                  return;
                                } else {
                                  cubit.createAppointment(
                                    petId: petId,
                                    isSpayed: true,
                                    petSqueakId: matchedPet.petSqueakId,
                                    clinicCode: clinicCode,
                                    appointmentTime: time! + ':00',
                                    appointmentDate: dateController.text,
                                    petGender: matchedPet.petGender,
                                    petName: matchedPet.petName,
                                    clientId: matchedPet.clientId,
                                    isExisted: true,
                                    notExistedOrPet: false,
                                    isExistedNoPet: false,
                                    doctorId: doctorId,
                                  );
                                }
                              }
                            },
                      child: cubit.isLoading
                          ? const CircularProgressIndicator()
                          : Text(
                              S.of(context).booking,
                              style: FontStyleThame.textStyle(
                                context: context,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontColor: ColorTheme.primaryColor,
                              ),
                            ),
                    ),
                  ),
                )
              ],
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: cubit.commentController,
                style: FontStyleThame.textStyle(
                  context: context,
                  fontSize: 15,
                ),
                maxLines: 1,
                decoration: InputDecoration(
                  hintText: S.of(context).addComment,
                  contentPadding: EdgeInsetsDirectional.only(
                    start: 10,
                  ),
                  counterStyle: FontStyleThame.textStyle(
                    context: context,
                    fontSize: 13,
                  ),
                  hintStyle: FontStyleThame.textStyle(
                    context: context,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontColor: MainCubit.get(context).isDark
                        ? Colors.white54
                        : Colors.black54,
                  ),
                  suffixIcon: IconButton(
                    onPressed: cubit.isLoading
                        ? null
                        : () {
                            if (dateController.text.isEmpty || time == null) {
                              infoToast(
                                context,
                                dateController.text.isEmpty
                                    ? isArabic()
                                        ? 'الرجاء تحديد التاريخ '
                                        : 'Please select date'
                                    : isArabic()
                                        ? "الرجاء تحديد الوقت"
                                        : 'Please select time',
                              );
                            } else {
                              ClientClinicModel? matchedPet;
                              matchedPet = findPet(cubit.petListInVet, petId);
                              if (matchedPet == null) {
                                infoToast(
                                  context,
                                  isArabic()
                                      ? 'الحيوان غير موجود'
                                      : 'The pet is not found',
                                );
                                return;
                              } else {
                                cubit.createAppointment(
                                  petId: petId,
                                  petSqueakId: matchedPet.petSqueakId,
                                  isSpayed: true,
                                  clinicCode: clinicCode,
                                  appointmentTime: time! + ':00',
                                  appointmentDate: dateController.text,
                                  petGender: matchedPet.petGender,
                                  petName: matchedPet.petName,
                                  clientId: matchedPet.clientId,
                                  isExisted: true,
                                  notExistedOrPet: false,
                                  isExistedNoPet: false,
                                  doctorId: doctorId,
                                );
                              }
                            }
                          },
                    icon: cubit.isLoading
                        ? const CircularProgressIndicator()
                        : const Icon(IconlyLight.send),
                  ),
                  filled: true,
                  fillColor: MainCubit.get(context).isDark
                      ? ColorManager.myPetsBaseBlackColor
                      : Colors.grey.shade200,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusColor: Colors.grey.shade200,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            body: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    buildDropDownDoctor(cubit, context),
                    (ClinicCubit.get(context).availabilities.isNotEmpty)
                        ? CalendarScreen(
                            isShowTime: true,
                            isShowDate: true,
                            timeSlotData: cubit.availabilities,
                            onDaySelected: (selectedDay, focusedDay) {
                              String formatDate =
                                  DateFormat('yyyy-MM-dd', 'en_US')
                                      .format(selectedDay);
                              dateController.text = formatDate;
                              cubit.emit(GetAvailabilitySuccess());
                            },
                            onIntervalSelected: (p0) {
                              p0 = convertTo24Hour(p0);
                              if (DateTime.now().isBefore(
                                  DateTime.parse(dateController.text))) {
                                time = p0;
                              } else {
                                if (int.parse(p0.split(':')[0]) <
                                        DateTime.now().hour ||
                                    (int.parse(p0.split(':')[0]) ==
                                            DateTime.now().hour &&
                                        int.parse(p0.split(':')[1]) <
                                            DateTime.now().minute)) {
                                  infoToast(
                                    context,
                                    isArabic()
                                        ? 'الساعة المحددة قبل الساعة الحالية'
                                        : 'Selected time is before current time',
                                  );
                                } else {
                                  time = p0;
                                }
                              }
                              cubit.emit(GetAvailabilitySuccess());
                            },
                          )
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CalendarShimmer(),
                          ),
                    SizedBox(
                      height: 80,
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String? doctorImage;
  String? doctorName;
  String? doctorId;

  Widget buildDropDownDoctor(ClinicCubit cubit, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: Decorations.kDecorationBoxShadow(context: context),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: DropdownButton<DoctorModel>(
            onChanged: (newValue) {
              doctorImage = newValue!.image;
              doctorId = newValue.id;
              doctorName = newValue.name;
              cubit.emit(GetDoctorSuccess());
            },
            isExpanded: true,
            iconSize: 0.0,
            elevation: 0,
            menuMaxHeight: 200,
            icon: const SizedBox.shrink(),
            underline: const SizedBox(),
            hint: Row(
              children: [
                Text(
                  doctorName ?? (isArabic() ? 'اختر الطبيب' : 'Select doctor'),
                  style: FontStyleThame.textStyle(
                    context: context,
                  ),
                ),
                Spacer(),
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                    doctorImage ??
                        'https://img.freepik.com/free-vector/businessman-character-avatar-isolated_24877-60111.jpg?size=626&ext=jpg&uid=R78903714&ga=GA1.1.798062041.1678310296&semt=ais',
                  ),
                ),
              ],
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            items: cubit.doctors.map((DoctorModel value) {
              return DropdownMenuItem<DoctorModel>(
                value: value,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        value.name,
                        style: FontStyleThame.textStyle(
                          context: context,
                        ),
                      ),
                      Spacer(),
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                          value.image,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
