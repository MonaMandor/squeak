import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:squeak/core/constant/global_widget/toast.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:squeak/core/helper/cache/cache_helper.dart';
import 'package:squeak/core/thames/styles.dart';
import 'package:squeak/features/auth/login/presentation/pages/login_screen.dart';

class WebViewExample extends StatelessWidget {
  WebViewExample({super.key, required this.imageUrl, required this.isAuth});

  final String imageUrl;
  final bool isAuth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            if (isAuth == true) {
              if (CacheHelper.getBool('IsLoginInVet') == true) {
                return await showExitConfirmationDialog(context);
              } else {
                navigateAndFinish(context, LoginScreen());
                return false;
              }
            } else {
              Navigator.pop(context);
              return false;
            }
          },
          child: InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri.uri(Uri.parse(imageUrl)),
            ),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                // Enable JavaScript
                javaScriptEnabled: true,
                cacheEnabled: true,
                // Other optional settings
              ),
            ),
            onWebViewCreated: (controller) {},
            onLoadStart: (controller, imageUrl) {
              print('''Loading: $imageUrl''');
              print("Started loading: $imageUrl");
            },
            onUpdateVisitedHistory: (controller, imageUrl, isReload) {
              if (isAuth) {
                if (imageUrl.toString().contains('authentication')) {
                  CacheHelper.saveData("IsLoginInVet", false);
                } else {
                  CacheHelper.saveData("IsLoginInVet", true);
                }
              }
            },
            onLoadStop: (controller, imageUrl) {
              if (isAuth) {
                if (imageUrl.toString().contains('authentication')) {
                  CacheHelper.saveData("IsLoginInVet", false);
                } else {
                  CacheHelper.saveData("IsLoginInVet", true);
                }
              }
            },
            onConsoleMessage: (controller, consoleMessage) {
              print("Console message: ${consoleMessage.message}");
              errorToast(context, consoleMessage.message);
            },
            onLoadError: (controller, imageUrl, code, message) {
              print("Error loading: $imageUrl, $code, $message");
              errorToast(context, message);
            },
          ),
        ),
      ),
    );
  }
}

Future<bool> showExitConfirmationDialog(BuildContext context) async {
  return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Confirm Exit'),
          content: Text('Are you sure you want to close the app?'),
          actions: <Widget>[
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(false), // Dismiss the dialog
              child: Text('No'),
            ),
            TextButton(
              onPressed: () => SystemNavigator.pop(), // Close the app
              child: Text('Yes'),
            ),
          ],
        ),
      ) ??
      false;
}
