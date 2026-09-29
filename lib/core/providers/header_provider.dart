import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Tracks which nav item's mega menu is currently active / hovered.
/// `null` means no mega menu is open.
final activeMegaMenuProvider = StateProvider<String?>((ref) => null);

/// Tracks whether the search overlay is open.
final isSearchOpenProvider = StateProvider<bool>((ref) => false);

/// Screen position of the desktop header search control for its dropdown.
final searchAnchorProvider = StateProvider<Rect?>((ref) => null);

/// Tracks whether the user has scrolled past the top hero threshold.
final isHeaderScrolledProvider = StateProvider<bool>((ref) => false);

/// Tracks whether the mobile navigation drawer is open.
final mobileNavDrawerOpenProvider = StateProvider<bool>((ref) => false);
