import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:zumie/core/services/service_locator.dart';
import 'package:zumie/firebase_options.dart';
import 'package:zumie/zumie.dart';

void main() {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await dotenv.load(fileName: ".env");
    setupLocator();
    // Hive-specific initialization
    await Hive.initFlutter();

    runApp(
      ProviderScope(
        overrides: const [],
        child: ZumieApp(),
      ),
    );
  }, (e, _) => throw e);
}
