import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/cart_provider.dart';
import 'providers/book_provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id', null); // ← tambah ini
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const BookishPOSApp());
}

class BookishPOSApp extends StatelessWidget {
  const BookishPOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookProvider()..loadDummyData()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: MaterialApp(
        title: 'Bookish POS',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const DashboardScreen(),
      ),
    );
  }

  ThemeData _buildTheme() {
    const Color primaryBrown = Color(0xFF3D2B1F);
    const Color accentAmber = Color(0xFFE8A838);
    const Color bgCream = Color(0xFFFAF6F0);
    const Color cardLight = Color(0xFFFFFFFF);
    const Color textDark = Color(0xFF1A1208);
    const Color textMuted = Color(0xFF8C7B6B);
    const Color successGreen = Color(0xFF2E7D32);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryBrown,
        secondary: accentAmber,
        surface: cardLight,
        background: bgCream,
        onPrimary: Colors.white,
        onSecondary: textDark,
        onSurface: textDark,
        onBackground: textDark,
        error: const Color(0xFFC62828),
        tertiary: successGreen,
      ),
      scaffoldBackgroundColor: bgCream,
      textTheme: GoogleFonts.libreCaslonTextTextTheme().copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        titleLarge: GoogleFonts.libreCaslonText(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        titleMedium: GoogleFonts.libreCaslonText(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textDark,
        ),
        bodyLarge: GoogleFonts.libreCaslonText(
          fontSize: 15,
          color: textDark,
        ),
        bodyMedium: GoogleFonts.libreCaslonText(
          fontSize: 13,
          color: textMuted,
        ),
        labelLarge: GoogleFonts.libreCaslonText(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryBrown,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: primaryBrown.withOpacity(0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: cardLight,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBrown,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.libreCaslonText(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primaryBrown.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primaryBrown.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: accentAmber, width: 2),
        ),
        hintStyle: GoogleFonts.libreCaslonText(color: textMuted, fontSize: 13),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: bgCream,
        selectedColor: accentAmber.withOpacity(0.2),
        labelStyle: GoogleFonts.libreCaslonText(fontSize: 12),
        side: BorderSide(color: primaryBrown.withOpacity(0.2)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: DividerThemeData(
        color: primaryBrown.withOpacity(0.1),
        thickness: 1,
      ),
    );
  }
}
