import 'package:flutter_riverpod/legacy.dart';

/// Tracks whether the desktop cart slide-in drawer is open.
final cartDrawerOpenProvider = StateProvider<bool>((ref) => false);
