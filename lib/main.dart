import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/routes/app_router.dart';
import 'package:pebble_type/core/services/home_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure global image cache: 256 MB memory budget & 500 entries.
  // With PebbleImage decode resizing (~500 KB/image), all 160+ images
  // reside comfortably in RAM with zero cache thrashing or scroll re-decodes.
  PaintingBinding.instance.imageCache.maximumSize = 500;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 256 * 1024 * 1024;

  // Pre-load local home page snapshot into memory cache for 0ms cold starts
  await HomeService.initMemoryCache();

  runApp(const ProviderScope(child: PebbleApp()));
}

/// Allows mouse dragging on desktop web for horizontal carousels & lookbooks.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class PebbleApp extends StatelessWidget {
  const PebbleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.bricolageGrotesqueTextTheme(
      Theme.of(context).textTheme,
    );

    return MaterialApp.router(
      title: 'Pebble',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      scrollBehavior: const AppScrollBehavior(),
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),
        textTheme: textTheme,
      ),
    );
  }
}

