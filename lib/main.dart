import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:juskar/utils/app_theme.dart';
import 'package:juskar/screens/main_layout.dart';
import 'package:juskar/services/initial_data_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'es_CO';
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Crear categorías por defecto si no existen
  await InitialDataService.createDefaultCategories();
  
  runApp(const JuskarApp());
}

class JuskarApp extends StatelessWidget {
  const JuskarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Juskar - Repostería',
      locale: const Locale('es', 'CO'),
      supportedLocales: const [
        Locale('es', 'CO'),
        Locale('es', 'ES'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.darkTheme,
      builder: (context, child) {
        return Stack(
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
              ),
              child: SizedBox.expand(),
            ),
            Center(
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.7,
                  child: Image.asset(
                    'assets/LogoJuskar.png',
                    width: 240,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            if (child != null) child,
          ],
        );
      },
      home: const MainLayout(),
      debugShowCheckedModeBanner: false,
    );
  }
}
