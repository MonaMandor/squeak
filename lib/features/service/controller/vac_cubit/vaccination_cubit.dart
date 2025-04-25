import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:squeak/core/constant/global_function/global_function.dart';
import 'package:squeak/core/constant/global_widget/toast.dart';
import 'package:squeak/core/helper/build_service/main_cubit/main_cubit.dart';
import 'package:squeak/core/helper/local_db/local_database.dart';
import 'package:squeak/core/helper/remotely/end-points.dart';
import 'package:squeak/features/service/models/vaccination_entities.dart';

import '../../../../../core/helper/remotely/dio.dart';
import '../../../../core/helper/build_service/notification_service.dart';
import '../../../../core/thames/color_manager.dart';
import '../../../../core/thames/styles.dart';
import '../../../settings/view/update_profile_screen.dart';
import '../../models/reminder_model.dart';

part 'vaccination_state.dart';

class VaccinationCubit extends Cubit<VaccinationState> {
  VaccinationCubit() : super(VaccinationInitial());

  String feedSubTypeValue =
      isArabic() ? 'نوع معين الطعام' : 'select feed sub type';
  List<String> feedSubType = [
    "Dry food",
    "wet food",
    "snacks",
  ];

  static VaccinationCubit get(context) => BlocProvider.of(context);
  bool isButtonSheetShown = false;

  void changeBottomSheetShow({
    required bool isShow,
  }) {
    isButtonSheetShown = !isShow;
    emit(AppChangeBottomSheetState());
  }

  List<VaccinationNameModel> vaccinationName = [];
  var valueFeedItem = "Select Feed Type";

  Future<void> getVaccinationName() async {
    emit(GetVaccinationLoadingState());

    try {
      Response object = await DioFinalHelper.getData(
        method: allVacEndPoint,
        language: false,
      );
      print("************");
      print(object.data["data"]["_vaccinations"]);
      object.data["data"]["_vaccinations"].forEach((e) {
        print(e["arName"]);
        print(e["enName"]);
        print("/");
      });

      vaccinationName = (object.data['data']['_vaccinations'] as List)
          .map((e) => VaccinationNameModel.fromJson(e))
          .toList();
      emit(GetVaccinationSuccessState());
    } on DioException catch (error) {
      print(error.response!.data);
      emit(GetVaccinationErrorState(error.response!.data['message']));
    }
  }

  List<VaccinationModel> petVacs = [];

  bool isVacLoading = false;

  var listOfServices = [];

  Future<void> getVacPet({
    required String petId,
  }) async {
    isVacLoading = true;
    listOfServices = [];
    emit(GetVaccinationLoadingState());

    try {
      // Response object = await DioFinalHelper.getData(
      //   method: allVacPetEndPoint + petId,
      //   language: false,
      // );
      // print(object.data);
      // petVacs = (object.data['data'] as List)
      //     .map((e) => VaccinationModel.fromJson(e))
      //     .toList();

      listOfServices = await LocalDatabaseHelper.getAllReminders(petId: petId);

      isVacLoading = false;
      emit(GetPetVaccinationSuccessState());
    } on DioException catch (error) {
      print(error.response!.data);
      isVacLoading = false;
      emit(GetVaccinationErrorState(error.response!.data['message']));
    }
  }

  bool isEdit = false;

  Future<void> updateDate({
    required String comments,
    required String petId,
    required String vaccinationName,
    required String data,
    required String vaccinationTypeId,
    required String id,
    required bool statues,
    required int index,
  }) async {
    isEdit = true;
    emit(UpdateVacPetsLoadingState());

    try {
      Response object = await DioFinalHelper.patchData(
        method: deleteVacEndPoint + id,
        data: {
          'petId': petId,
          'vaccinationId': vaccinationTypeId,
          'id': id,
          'VacDate': data,
          'comment': comments,
          'statues': statues,
        },
      );
      isEdit = false;
      if (statues == true) {
        await DioFinalHelper.patchData(
          method: deleteVacEndPoint + "petvac/" + id,
          data: {},
        );
      }

      getVacPet(petId: petId);
      emit(UpdateVacPetsSuccessState());
    } on DioException catch (error) {
      isEdit = false;
      print(error.response);
      emit(UpdateVacPetsErrorState());
    }
  }

  Future<void> deleteDate({
    required dynamic id,
    required dynamic petId,
  }) async {
    emit(DeleteVacPetsLoadingState());
    try {
      // Response object = await DioFinalHelper.deleteData(
      //   method: deleteVacEndPoint + id,
      // );
      // print(object.data);
      // petVacs.removeWhere(
      //   (element) {
      //     return element.id == id;
      //   },
      // );
      await LocalDatabaseHelper.deleteReminder(
        id,
      );

      await getVacPet(petId: petId);

      emit(DeleteVacPetsSuccessState());
    } on DioException catch (error) {
      print(error.response!.data);
      emit(DeleteVacPetsErrorState(error.response!.data['message']));
    }
  }

  bool isLoading = false;

  List<String> reminderFreq = [
    "Once",
    "Daily",
    "Weekly",
    "Monthly",
    "Annually",
  ];

  TextEditingController otherController = TextEditingController();

  Future<void> createVac({
    required String petId,
    required String petName,
    required String typeId,
    required String data,
    required String valueVacItem,
    required String comments,
    required BuildContext context,
  }) async {
    isLoading = true;
    emit(AddVaccinationLoadingState());

    try {
      if (picked == null) {
        errorToast(context,
            isArabic() ? "الرجاء اختيار الوقت" : "Please select the time");
        isLoading = false;
        return;
      } else {
        int _notificationId = NotificationService.generateNotificationId();

        print("********************** : ${valueVacItem}");
        ReminderModel reminder = ReminderModel(
          petName: petName,
          reminderType: valueVacItem,
          reminderFreq: currentFreq.toString(),
          date: data,
          time: "${picked!.hour} : ${picked!.minute}",
          timeAR: "${picked!.minute} : ${picked!.hour}",
          notes: comments,
          petId: petId,
          notificationID: _notificationId.toString(),
          subTypeFeed: feedSubTypeValue.isEmpty ||
                  feedSubTypeValue.toString() == "نوع معين الطعام" ||
                  feedSubTypeValue.toString() == 'select feed sub type'
              ? ""
              : feedSubTypeValue.toString().trim(),
          otherTitle: valueVacItem == "other" || valueVacItem == "أخرى"
              ? otherController.text.trim()
              : "",
        );

        // print("Reminder Model");
        // print("reminder.reminderFreq ${reminder.reminderFreq}");
        // print("reminder.reminderType ${reminder.reminderType}");
        // print("reminder.date ${reminder.date}");
        // print("reminder.time ${reminder.time}");
        // print("reminder.notes ${reminder.notes}");
        // print("reminder.petId ${reminder.petId}");
        // print("reminder.notificationID ${reminder.notificationID}");

        await LocalDatabaseHelper.insertReminder(reminder);

        List<String> dateParts = reminder.date.split("-");

        int year = int.parse(dateParts[0]);
        int month = int.parse(dateParts[1]);
        int day = int.parse(dateParts[2]);

        NotificationService.scheduleNotification(
          id: _notificationId,
          title: reminder.reminderType.toString() == "other" ||
                  reminder.reminderType.toString() == "أخرى"
              ? "${reminder.otherTitle.toString()}"
              : "${reminder.reminderType.toString()}", // body: reminder.notes.toString() == null ||
          //         reminder.notes.toString() == ""d
          //     ? ""
          //     : reminder.notes.toString(),
          body: handleTheNotificationBodyBasedOnType(
            type: reminder.reminderType.toString(),
            petName: reminder.petName,
          ),
          startDate: DateTime(year, month, day),
          startTime: TimeOfDay(hour: picked!.hour, minute: picked!.minute),
          frequency: reminder.reminderFreq,
        );

        isLoading = false;
        isButtonSheetShown = false;
        valueVacItem = 'Select Service';
        valueIdItem = '';
        currentFreq = isArabic() ? "اختر عدد التكرار" : "Select The Frequency";
        otherController.clear();
        // picked = null;
        await getVacPet(petId: petId);
        emit(AddVaccinationSuccessState());
      }
    } on DioException catch (error) {
      print(error.response!.data);
      isLoading = false;
      isButtonSheetShown = false;

      emit(AddVaccinationErrorState(error.response!.data['message']));
    }
  }

  String handleTheNotificationBodyBasedOnType({
    required String type,
    required String petName,
  }) {
    bool isArabicLang = isArabic();

    Map<String, String> messagesEn = {
      "Feed":
          "🍽️ Hungry alert! $petName is giving you the \"feed me now\" look!",
      "Grooming":
          "✂️ Spa day! $petName is ready for some pampering. Time for grooming!",
      "Clean Potty":
          "🚽 Uh-oh! $petName would appreciate a fresh, clean space... if you know what we mean! 😹",
      "Outdoor Walk":
          "🐕 Adventure time! $petName is ready to explore the world—let’s go for a walk!",
      "Exercise":
          "🏃‍♂️ Workout buddy alert! $petName needs some playtime—time to burn some energy!",
      "Buy Food":
          "🛒 Stock up time! $petName just realized the food stash is running low. Better refill before the \"sad eyes\" start!",
      "Flea":
          "🥟 Tiny invaders detected! Time to protect $petName from unwanted guests. Flea treatment time!",
      "Deworming":
          "💊 Health check! $petName needs deworming to stay happy and healthy!"
    };

    Map<String, String> messagesAr = {
      "Feed":
          "🍽️ جوعان Alert! $petName ينظر إليك بنظرة \"أطْعِمْني حالًا\"! 😹",
      "Grooming":
          "✂️ يوم الدلال! $petName مستعد لجلسة عناية وتجميل. حان وقت التهذيب!",
      "Clean Potty":
          "🚽 أوه لا! $petName يفضل حمامًا نظيفًا... وأنت تعرف ماذا يعني ذلك! 😹",
      "Outdoor Walk":
          "🐕 وقت المغامرة! $petName متحمّس لاستكشاف العالم – لنذهب في نزهة!",
      "Exercise":
          "🏃‍♂️ شريك التمارين مستعد! $petName بحاجة لبعض الحركة واللعب. هيا نبدأ التمارين!",
      "Buy Food":
          "🛒 مخزون الطعام في خطر! $petName لاحظ أن الأكل قرب يخلص… تصرف قبل أن يبدأ بنظرات الاستعطاف! 👀",
      "Flea":
          "🥟 الغزاة الصغار وصلوا! حان وقت حماية $petName من الضيوف غير المرغوب فيهم!",
      "Deworming":
          "💊 وقت العناية الصحية! $petName يحتاج جرعة التخلص من الديدان ليبقى بصحة وسعادة!"
    };

    return isArabicLang
        ? (messagesAr[type] ?? "⚠️ تذكير! حان وقت العناية بـ $petName!")
        : (messagesEn[type] ?? "⚠️ Reminder! Time to take care of $petName!");
  }

  bool? value;

  void changeState() {
    value = !value!;
    print(value);
    emit(ChangeStateVacState());
  }

  String valueVacItem = isArabic() ? 'اختر نوع الخدمة' : 'Select Service';
  String valueIdItem = '';

  void changeSelect({required String vacName, required String vacId}) {
    valueVacItem = vacName;
    valueIdItem = vacId;
    print('************$vacName');
    emit(ChangeStateVacState());
  }

  DateTime currentDateItem = DateTime.now();
  String timeDateItem = '';
  bool isSelectedTime = false;
  bool isSelectedVac = false;

  Future<void> selectDate(
    BuildContext context,
  ) async {
    DateTime tomorrowDateItem = currentDateItem.add(const Duration(days: 0));

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDate: tomorrowDateItem,
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
    );
    if (pickedDate != null && pickedDate != currentDateItem) {
      currentDateItem;
      String formattedDate =
          pickedDate.toString().substring(0, 10); // 'yyyy-MM-dd'
      parseDateFromInput(formattedDate);
      currentDateItem = DateTime.parse(formattedDate);
      emit(ChangeStateVacState());
    }
  }

  void changeSelectedTime() {
    if (valueIdItem.isEmpty) {
      isSelectedVac = true;
    } else {
      isSelectedVac = false;
    }
    emit(ChangeStateVacState());
  }

  late TimeOfDay? picked = TimeOfDay.now();

  Future<void> selectTime(BuildContext context) async {
    emit(TimeSelectedLoading());
    picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      // Do something with the selected time
      emit(TimeSelectedSuccessfully());
      print('Selected time: ${picked!.format(context)}');
    } else {
      emit(TimeSelectedError());
    }
  }

  String currentFreq = "Select The Frequency";

  late TimeOfDay? pickedFromEdit = null;

  Future<void> selectTimeFromEdit(
      BuildContext context, TimeOfDay initTime) async {
    emit(TimeSelectedLoading());

    final picked = await showTimePicker(
      context: context,
      initialTime: initTime,
    );

    if (picked != null) {
      pickedFromEdit = picked;
      emit(TimeSelectedSuccessfully()); // This ensures UI rebuilds
      print('Selected time: ${picked.format(context)}');
    } else {
      emit(TimeSelectedError());
    }
  }

  Future<void> updateTheService({
    required ReminderModel reminder,
  }) async {
    emit(AddVaccinationLoadingState());

    try {
      ReminderModel updatedReminder = ReminderModel(
        petName: reminder.petName,
        id: reminder.id,
        timeAR: "${picked!.minute} : ${picked!.hour}",
        petId: reminder.petId,
        reminderType: reminder.reminderType,
        reminderFreq: reminder.reminderFreq,
        date: reminder.date,
        time: reminder.time,
        notes: reminder.notes,
        notificationID: reminder.notificationID,
        subTypeFeed: reminder.subTypeFeed,
        otherTitle: reminder.otherTitle,
      );

      await LocalDatabaseHelper.updateReminder(updatedReminder).then((e) async {
        emit(AddVaccinationSuccessState());
      });

      List<String> dateParts = reminder.date.split("-");

      int year = int.parse(dateParts[0]);
      int month = int.parse(dateParts[1]);
      int day = int.parse(dateParts[2]);
      // print("***********");
      // print(reminder.time);

      reminder.time =
          reminder.time.replaceAll(RegExp(r'\s+'), ''); // Remove all spaces

      List<String> parts = reminder.time.split(":");
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      // print("hour ${hour}");
      // print("minute ${minute}");
      // print( TimeOfDay(hour: picked!.hour, minute: picked!.minute));

      NotificationService.editScheduledNotification(
        notificationId: int.parse(reminder.notificationID),
        newTitle: reminder.reminderType.toString() == "other" ||
                reminder.reminderType.toString() == "أخرى"
            ? "${reminder.otherTitle.toString()}"
            : "${reminder.reminderType.toString()}",
        newBody: handleTheNotificationBodyBasedOnType(
          type: reminder.reminderType.toString(),
          petName: reminder.petName,
        ),
        newStartDate: DateTime(year, month, day),
        newStartTime: TimeOfDay(hour: hour, minute: minute),
        newFrequency: reminder.reminderFreq,
      );
    } on DioException catch (error) {
      print(error.response!.data);
      emit(AddVaccinationErrorState(error.response!.data['message']));
    }
  }

  deleteTheService({required ReminderModel reminder, required petId}) async {
    try {
      await LocalDatabaseHelper.deleteReminder(reminder.id!.toInt());
      await getVacPet(petId: petId);

      // picked = null;
      emit(AddVaccinationSuccessState());
    } on DioException catch (error) {
      print(error.response!.data);
      isLoading = false;
      isButtonSheetShown = false;

      emit(AddVaccinationErrorState(error.response!.data['message']));
    }
  }

  DateTime? newValueForDateInEdit = null;

  Future<void> selectDateOnEdit(
    BuildContext context,
    DateTime initDate,
  ) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDate: initDate,
      firstDate: initDate.isAfter(DateTime.now()) ? DateTime.now() : initDate,
      lastDate: DateTime(2050),
    );
    if (pickedDate != null && pickedDate != newValueForDateInEdit) {
      newValueForDateInEdit;
      String formattedDate =
          pickedDate.toString().substring(0, 10); // 'yyyy-MM-dd'
      parseDateFromInput(formattedDate);
      newValueForDateInEdit = DateTime.parse(formattedDate);
      emit(ChangeStateVacState());
    }
  }

  takeStringReturnDateTime(String date) {
    List<String> dateParts = date.split("-");

    int year = int.parse(dateParts[0]);
    int month = int.parse(dateParts[1]);
    int day = int.parse(dateParts[2]);

    return DateTime(year, month, day);
  }

  late String currentFreqInEdit;

  updateTheFrequency(newFreValue) {
    currentFreqInEdit = newFreValue;
    emit(ChangeTheFreqValue());
  }

  setTheDefaultReminder(initVal) {
    currentFreqInEdit = initVal;
    emit(ChangeTheFreqValue());
  }
}
