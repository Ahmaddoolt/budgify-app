import 'package:budgify/viewmodels/providers/sound_toggle_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class SoundSwitchState {
  final bool isSoundEnabled; // true means sound is enabled
  SoundSwitchState({required this.isSoundEnabled});
}

class SoundSwitchNotifier extends StateNotifier<SoundSwitchState> {
  final SoundService _soundService = Get.find<SoundService>();

  SoundSwitchNotifier() : super(SoundSwitchState(isSoundEnabled: true)) {
    _loadSoundState();
  }

  Future<void> _loadSoundState() async {
    try {
      if (!_soundService.isInitialized) {
        await _soundService.init();
      }
      if (!_soundService.isInitialized) {
        debugPrint('❌ SoundService failed to initialize');
        state = SoundSwitchState(isSoundEnabled: false); // Fallback to disabled
        return;
      }
      state = SoundSwitchState(isSoundEnabled: !_soundService.isSoundDisabled);
      debugPrint('✅ Loaded sound state: isSoundEnabled=${state.isSoundEnabled}');
    } catch (e) {
      debugPrint('❌ Error loading sound state: $e');
      state = SoundSwitchState(isSoundEnabled: false); // Fallback to disabled
    }
  }

  Future<void> toggleSound(bool isEnabled) async {
    try {
      await _soundService.toggleSound(!isEnabled); // Inverse due to isSoundDisabled
      state = SoundSwitchState(isSoundEnabled: isEnabled);
      debugPrint('✅ Toggled sound: isSoundEnabled=$isEnabled');
    } catch (e) {
      debugPrint('❌ Error toggling sound: $e');
      rethrow; // Let the UI handle errors
    }
  }
}

final soundSwitchProvider =
    StateNotifierProvider<SoundSwitchNotifier, SoundSwitchState>(
  (ref) => SoundSwitchNotifier(),
);