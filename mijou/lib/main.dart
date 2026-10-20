import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'data.dart';
import 'pages_fridge.dart';
import 'pages_home.dart';
import 'pages_lists.dart';
import 'theme.dart';
import 'widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));
  runApp(const MijouApp());
}

class MijouApp extends StatelessWidget {
  const MijouApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Mijou',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: Pal.bg,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Pal.primary,
            surface: Pal.bg,
          ),
          textTheme: GoogleFonts.nunitoTextTheme(),
          splashFactory: InkRipple.splashFactory,
        ),
        home: const Shell(),
      );
}

/// Coquille principale : 4 onglets + navbar flottante.
class Shell extends StatelessWidget {
  const Shell({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppState.i;
    return ValueListenableBuilder<int>(
      valueListenable: s.tab,
      builder: (context, tab, _) => Scaffold(
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: tab,
            children: const [
              HomePage(),
              FridgePage(),
              FavoritesPage(),
              ShoppingPage(),
            ],
          ),
        ),
        bottomNavigationBar: MijouNavBar(index: tab, onTap: (i) => s.tab.value = i),
      ),
    );
  }
}
