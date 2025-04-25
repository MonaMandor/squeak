import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:squeak/core/helper/remotely/config_model.dart';
//import 'package:workmanager/workmanager.dart';
import 'package:dio/dio.dart';
import 'package:squeak/core/helper/cache/cache_helper.dart';
import 'package:squeak/core/helper/remotely/end-points.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path/path.dart';

import '../../../features/pets/models/pet_model.dart';

class Reminder {
  final String type;
  final String id;
  final DateTime date;
  final String frequency;
  final String status;
  final String time;
  final String? note;
  final PetsData petModel;

  Reminder({
    required this.type,
    required this.date,
    required this.status,
    required this.petModel,
    required this.time,
    required this.id,
    required this.frequency,
    this.note,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      type: json['type'],
      date: DateTime.parse(json['date']),
      status: json['status'],
      time: json['time'],
      id: json['id'] ?? '',
      frequency: json['frequency'],
      note: json['note'],
      petModel: PetsData.fromJson(json['petModel']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'date': date.toIso8601String(),
      'status': status,
      'time': time,
      'frequency': frequency,
      'note': note,
      'petModel': petModel.toMap(),
    };
  }
}

class ReminderManager {
  static const String remindersKey = "remindersForPet";
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  ReminderManager(this.flutterLocalNotificationsPlugin) {
    // Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  }

  static bool isArabic() {
    return Intl.getCurrentLocale() == 'ar';
  }

  static Future<String> downloadAndSaveFile(
      String imageUrl, String fileName) async {
    try {
      final Directory tempDir = Directory.systemTemp;
      final String filePath = join(tempDir.path, fileName);
      final Dio dio = Dio();

      final Response<List<int>> response = await dio.get<List<int>>(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      final File file = File(filePath);
      await file.writeAsBytes(response.data!);
      return filePath;
    } catch (e) {
      print('File download failed: $e');
      return ''; // Return an empty string if the download fails
    }
  }

  // static void callbackDispatcher() {
  //  // Workmanager().executeTask((task, inputData) async {
  //     if (task == 'refreshTokenTask') {
  //       print('Executing refresh token task');
  //       TokenManager tokenManager = TokenManager();
  //       await CacheHelper.init();
  //       await tokenManager.refreshToken();
  //     } else if (task == 'sendReminderNotification') {
  //       print('Executing Send Reminder Notification task');

  //       final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  //           FlutterLocalNotificationsPlugin();

  //       const AndroidInitializationSettings initializationSettingsAndroid =
  //           AndroidInitializationSettings('@mipmap/ic_launcher');

  //       const InitializationSettings initializationSettings =
  //           InitializationSettings(
  //         android: initializationSettingsAndroid,
  //       );

  //       await flutterLocalNotificationsPlugin
  //           .initialize(initializationSettings);

  //       if (inputData != null) {
  //         final reminderType = inputData['type'];
  //         final petName = inputData['petName'];
  //         final frequency = inputData['frequency'];
  //         final reminderTime = DateTime.parse(inputData['date']);

  //         // Map types to image imageUrls
  //         final Map<String, String> typeToImageimageUrl = {
  //           'feed':
  //               'https://firebasestorage.googleapis.com/v0/b/squeak-c005f.appspot.com/o/rb_9500.png?alt=media&token=96dd0c7a-ee8e-4371-9cef-482f1744bf27',
  //           'grooming':
  //               'https://firebasestorage.googleapis.com/v0/b/squeak-c005f.appspot.com/o/rb_26136.png?alt=media&token=1149200b-517a-4713-b2c9-101b7657939f',
  //           'pottyClean':
  //               'https://firebasestorage.googleapis.com/v0/b/squeak-c005f.appspot.com/o/DALL%C2%B7E%202024-12-23%2013.08.29%20-%20A%20clean%20and%20minimalistic%20illustration%20of%20a%20pet%20hygiene%20icon%2C%20featuring%20a%20stylized%20paw%20print%20inside%20a%20sparkling%20clean%20litter%20box%20or%20a%20tidy%20pet%20potty%20ar.png?alt=media&token=70d17c24-b1dc-44c1-ae63-07d2b3bab501',
  //           'rabies':
  //               'https://firebasestorage.googleapis.com/v0/b/squeak-c005f.appspot.com/o/freepik__background__59661.png?alt=media&token=76bee026-126a-46c9-aca3-53545ee85ca0',
  //           'fleaTickTreatment':
  //               'https://firebasestorage.googleapis.com/v0/b/squeak-c005f.appspot.com/o/rb_3645.png?alt=media&token=ff06f624-f2e9-48b6-8ce9-42fb348348c9',
  //           'examination':
  //               'https://firebasestorage.googleapis.com/v0/b/squeak-c005f.appspot.com/o/rb_3646.png?alt=media&token=4c62b043-9a5d-4143-85a3-a500a31a22cf',
  //           'vaccination':
  //               'https://firebasestorage.googleapis.com/v0/b/squeak-c005f.appspot.com/o/rb_19734.png?alt=media&token=fce97a82-9f75-484e-a6fa-b473d2ce7fa4',
  //           'deworming':
  //               'https://firebasestorage.googleapis.com/v0/b/squeak-c005f.appspot.com/o/DALL%C2%B7E%202024-12-23%2013.17.32%20-%20A%20clean%20and%20friendly%20digital%20illustration%20of%20an%20icon%20representing%20pet%20deworming.%20The%20icon%20features%20a%20happy%20dog%20and%20cat%20sitting%20side%20by%20side%20with%20a%20vis.png?alt=media&token=9e4e49a8-f381-45e1-bccd-bdb101e1e2fc',
  //           'other':
  //               'https://firebasestorage.googleapis.com/v0/b/squeak-c005f.appspot.com/o/rb_11031.png?alt=media&token=70f10416-2e2c-4dde-936a-c0305353fc9c',
  //         };

  //         final imageimageUrl =
  //             typeToImageimageUrl[reminderType] ?? typeToImageimageUrl['other'];

  //         String iconPath = await downloadAndSaveFile(
  //             imageimageUrl!, 'icon_${reminderType}.png');
  //         if (iconPath.isEmpty) {
  //           iconPath = '@drawable/ic_other'; // Default icon if download fails
  //         }

  //         final title = isArabic()
  //             ? "تذكير $reminderType لـ $petName: اتخذ إجراءً الآن"
  //             : "$reminderType Reminder for $petName: Take Action Now";

  //         final body = isArabic()
  //             ? "أكمل $reminderType لـ $petName الآن أو اختر تخطيها أو تأجيلها. الموعد: ${reminderTime.toLocal().toIso8601String().split("T")[0]} الساعة ${reminderTime.toLocal().toIso8601String().split("T")[1]}"
  //             : "Complete $reminderType for $petName now or choose to skip or snooze. Due: ${reminderTime.toLocal().toIso8601String().split("T")[0]} at ${reminderTime.toLocal().toIso8601String().split("T")[1]}";

  //         final AndroidNotificationDetails androidDetails =
  //             AndroidNotificationDetails(
  //           'reminder_channel',
  //           'Reminders',
  //           channelDescription: 'Channel for pet reminders',
  //           importance: Importance.high,
  //           priority: Priority.high,
  //           largeIcon: FilePathAndroidBitmap(iconPath),
  //           playSound: true,
  //           sound: const RawResourceAndroidNotificationSound('notification'),
  //         );

  //         final NotificationDetails notificationDetails = NotificationDetails(
  //           android: androidDetails,
  //           iOS: DarwinNotificationDetails(
  //             presentAlert: true,
  //             presentBadge: true,
  //             presentSound: true,
  //             sound: 'notification.mp3',
  //           ),
  //         );

  //         await flutterLocalNotificationsPlugin.show(
  //           inputData.hashCode,
  //           title,
  //           body,
  //           notificationDetails,
  //         );

  //         // Handle rescheduling based on frequency
  //         if (frequency == "Daily") {
  //           await Workmanager().registerOneOffTask(
  //             DateTime.now().millisecondsSinceEpoch.toString(),
  //             "sendReminderNotification",
  //             inputData: {
  //               'type': reminderType,
  //               'petName': petName,
  //               'frequency': frequency,
  //               'date': reminderTime.add(Duration(days: 1)).toIso8601String(),
  //             },
  //             initialDelay: Duration(days: 1),
  //           );
  //         } else if (frequency == "Weekly") {
  //           await Workmanager().registerOneOffTask(
  //             DateTime.now().millisecondsSinceEpoch.toString(),
  //             "sendReminderNotification",
  //             inputData: {
  //               'type': reminderType,
  //               'petName': petName,
  //               'frequency': frequency,
  //               'date': reminderTime.add(Duration(days: 7)).toIso8601String(),
  //             },
  //             initialDelay: Duration(days: 7),
  //           );
  //         } else if (frequency == "Monthly") {
  //           await Workmanager().registerOneOffTask(
  //             DateTime.now().millisecondsSinceEpoch.toString(),
  //             "sendReminderNotification",
  //             inputData: {
  //               'type': reminderType,
  //               'petName': petName,
  //               'frequency': frequency,
  //               'date': DateTime(reminderTime.year, reminderTime.month + 1,
  //                       reminderTime.day)
  //                   .toIso8601String(),
  //             },
  //             initialDelay: Duration(days: 30),
  //           );
  //         }
  //       }
  //     }
  //     return Future.value(true);
  //   });
  // }

  // Future<void> scheduleReminder(Reminder reminder) async {
  //   final scheduledTime = DateTime.parse(
  //       "${reminder.date.toIso8601String().split('T')[0]} ${reminder.time}");

  //   if (scheduledTime.isAfter(DateTime.now())) {
  //     //await Workmanager().registerOneOffTask(
  //       reminder.hashCode.toString(),
  //       "sendReminderNotification",
  //       inputData: {
  //         'type': reminder.type,
  //         'petName': reminder.petModel.petName,
  //         'frequency': reminder.frequency,
  //         'date': reminder.date.toIso8601String(),
  //       },
  //       initialDelay: scheduledTime.difference(DateTime.now()),
  //     );
  //   }
  // }

  Future<void> saveReminder(Reminder reminder) async {
    final prefs = await SharedPreferences.getInstance();
    final existingReminders = prefs.getStringList(remindersKey) ?? [];

    existingReminders.add(reminder.toJson().toString());
    await prefs.setStringList(remindersKey, existingReminders);

    // await scheduleReminder(reminder);
  }

  Future<List<Reminder>> getReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson = prefs.getStringList(remindersKey) ?? [];

    return remindersJson
        .map((jsonStr) =>
            Reminder.fromJson(Map<String, dynamic>.from(json.decode(jsonStr))))
        .toList();
  }

  Future<void> removeReminder(Reminder reminder) async {
    final prefs = await SharedPreferences.getInstance();
    final existingReminders = prefs.getStringList(remindersKey) ?? [];

    final updatedReminders = existingReminders
        .where((jsonStr) =>
            Reminder.fromJson(Map<String, dynamic>.from(json.decode(jsonStr)))
                .hashCode !=
            reminder.hashCode)
        .toList();

    await prefs.setStringList(remindersKey, updatedReminders);
    // await Workmanager().cancelByUniqueName(reminder.hashCode.toString());
  }

  Future<void> clearAllReminders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(remindersKey);
    //  await Workmanager().cancelAll();
  }
}

class DataToken {
  String token;
  String tokenType;
  DateTime expiresIn;
  String refreshToken;

  DataToken({
    required this.token,
    required this.tokenType,
    required this.expiresIn,
    required this.refreshToken,
  });

  factory DataToken.fromJson(Map<String, dynamic> json) => DataToken(
        token: json["token"],
        tokenType: json["tokenType"],
        expiresIn: DateTime.parse(json["expiresIn"]),
        refreshToken: json["refreshToken"],
      );

  Map<String, dynamic> toJson() => {
        "token": token,
        "tokenType": tokenType,
        "expiresIn": expiresIn.toIso8601String(),
        "refreshToken": refreshToken,
      };
}

class TokenManager {
  Future<void> saveToken(
      String token, DateTime expiry, String refreshToken) async {
    print('saveData');
    CacheHelper.saveData('token', token);
    CacheHelper.saveData('refreshToken', refreshToken);
    CacheHelper.saveData('expiry', expiry.millisecondsSinceEpoch);
  }

  Future<void> refreshToken() async {
    CacheHelper.init();
    try {
      var dio = Dio();
      Response response = await dio.request(
        ConfigModel.baseApiimageUrlSqueak + refreshTokenGet,
        options: Options(
          method: 'POST',
          headers: {'Authorization': 'Bearer ${CacheHelper.getData('token')}'},
        ),
        data: {
          "token": CacheHelper.getData('refreshToken'),
        },
      );
      DataToken jsonResponse = DataToken.fromJson(response.data["data"]);
      String newToken = jsonResponse.token;
      String newRefreshToken = jsonResponse.refreshToken;
      DateTime newExpiry = DateTime.now().add(Duration(hours: 6));
      print('new token Successfully');
      await saveToken(newToken, newExpiry, newRefreshToken);
      print(jsonResponse.toJson());
    } on DioException catch (e) {
      print(e.response?.data);
      print('refresh token error ${e.response?.data}');
      if (e.response?.statusCode == 401) {
        CacheHelper.saveData('isExpiredToken', true);
      }
    }
  }
}
