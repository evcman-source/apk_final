import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'screens/chat_screen.dart';
import 'services/chat_provider.dart';

// Debug modunda SSL sertifika kontrolünü devre dışı bırak
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Debug modunda SSL kontrolünü devre dışı bırak
  HttpOverrides.global = MyHttpOverrides();
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
  ));
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const EvaApp());
}

class EvaApp extends StatelessWidget {
  const EvaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatProvider(),
      child: Consumer<ChatProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            title: 'Eva Mobile',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF0A0A0A),
              textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
              colorScheme: ColorScheme.dark(
                primary: provider.getModeColor(),
                secondary: provider.getModeColor().withOpacity(0.8),
                surface: const Color(0xFF1A1A2E),
              ),
            ),
            home: const ChatScreen(),
          );
        },
      ),
    );
  }
}
