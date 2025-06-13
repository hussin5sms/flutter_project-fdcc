import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'main_menu.dart';

void main() {
  runApp(GetMaterialApp(
    home: LoginScreen(),
    // إعدادات الترجمة
    localizationsDelegates: [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: [
      Locale('en'), // الإنجليزية
      Locale('ar'), // العربية، إذا كنت ستدعمها
    ],
  ));
}

class LoginScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("تسجيل الدخول")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: "اسم المستخدم"),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "كلمة المرور"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.off(() => MainMenu());
              },
              child: Text("دخول"),
            )
          ],
        ),
      ),
    );
  }
}
