import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pebble_type/core/services/auth_service.dart';
import 'package:pebble_type/feature/profile/models/user_model.dart';

class ProfileProvider extends AsyncNotifier<UserModel> {
  @override
  FutureOr<UserModel> build() async {
    final data = await AuthService.getMe();
    return UserModel.fromJson(data);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final data = await AuthService.getMe();
      return UserModel.fromJson(data);
    });
  }
}

final profileProvider = AsyncNotifierProvider<ProfileProvider, UserModel>(
  ProfileProvider.new,
);
