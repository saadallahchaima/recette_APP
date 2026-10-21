import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/utils/theme.dart';
import 'core/utils/widgets.dart';
import 'features/fridge/presentation/pages/fridge_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/lists/presentation/pages/lists_page.dart';
import 'features/recipes/presentation/controllers/app_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const MijouApp(),
    ),
  );
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
    final s = context.watch<AppState>();
    if (s.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: s.tab,
          children: const [
            HomePage(),
            FridgePage(),
            FavoritesPage(),
            ShoppingPage(),
          ],
        ),
      ),
      bottomNavigationBar: MijouNavBar(index: s.tab, onTap: s.setTab),
    );
  }
}
