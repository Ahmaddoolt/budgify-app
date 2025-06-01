import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

class SoundService extends GetxService {
  final AudioPlayer _buttonPlayer = AudioPlayer();
  final AudioPlayer _completionPlayer = AudioPlayer();
  bool isInitialized = false;
  final RxBool _isSoundDisabled = false.obs;
  DateTime? _lastButtonPlayTime;
  DateTime? _lastCompletionPlayTime;
  final Duration _debounceDuration = const Duration(milliseconds: 100);
  SharedPreferences? _prefs;

  static const _buttonClickSound = 'assets/budgify_sound_short.mp3';
  static const _taskCompletedSound = 'assets/budgify_sound_short.mp3';

  Future<SoundService> init() async {
    if (isInitialized) {
      debugPrint("SoundService: Already initialized.");
      return this;
    }
    debugPrint('🚀 Starting SoundService initialization');
    try {
      _prefs = await SharedPreferences.getInstance();
      debugPrint('✅ SharedPreferences loaded for SoundService');
      _isSoundDisabled.value = _prefs?.getBool('isSoundDisabled') ?? false;
      debugPrint('🔊 Sound disabled: ${_isSoundDisabled.value}');

      debugPrint('🔧 Configuring audio session');
      final session = await AudioSession.instance;
      await session.configure(
        const AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.ambient,
          avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
          avAudioSessionMode: AVAudioSessionMode.defaultMode,
          androidAudioAttributes: AndroidAudioAttributes(
            contentType: AndroidAudioContentType.sonification,
            usage: AndroidAudioUsage.notification,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientMayDuck,
        ),
      );

      if (Platform.isIOS) {
        await session.setActive(true);
        debugPrint('✅ iOS audio session activated');
      }
      debugPrint('✅ Audio session configured');

      debugPrint('🔊 Preloading button click sound');
      await _preloadSound(_buttonPlayer, _buttonClickSound, volume: 0.8);
      debugPrint('🔊 Preloading task completed sound');
      await _preloadSound(_completionPlayer, _taskCompletedSound, volume: 1.0);

      isInitialized = true;
      debugPrint('✅ SoundService initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing SoundService: $e\nStackTrace: $stackTrace');
      isInitialized = false;
    }
    return this;
  }

  Future<void> _preloadSound(AudioPlayer player, String path, {double volume = 1.0}) async {
    try {
      await player.setAsset(path);
      await player.setVolume(volume.clamp(0.0, 1.0));
      await player.setLoopMode(LoopMode.off);
      await player.stop();
      debugPrint('✅ Preloaded sound: $path at volume $volume');
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to preload $path: $e\nStackTrace: $stackTrace');
      rethrow;
    }
  }

  Future<void> playButtonClickSound() async {
    debugPrint('🔊 playButtonClickSound: isSoundDisabled=${_isSoundDisabled.value}, isInitialized=$isInitialized');
    if (!isInitialized || _isSoundDisabled.value) return;
    final now = DateTime.now();
    if (_lastButtonPlayTime != null && now.difference(_lastButtonPlayTime!) < _debounceDuration) return;
    _lastButtonPlayTime = now;
    try {
      await _buttonPlayer.seek(Duration.zero);
      await _buttonPlayer.play();
      debugPrint('✅ Button click sound played');
    } catch (e) {
      debugPrint('❌ Error playing button click sound: $e');
      await _recoverPlayer(_buttonPlayer, _buttonClickSound, volume: 0.8);
    }
  }

  Future<void> playTaskCompletedSound() async {
    debugPrint('🔊 playTaskCompletedSound: isSoundDisabled=${_isSoundDisabled.value}, isInitialized=$isInitialized');
    if (!isInitialized || _isSoundDisabled.value) return;
    final now = DateTime.now();
    if (_lastCompletionPlayTime != null && now.difference(_lastCompletionPlayTime!) < _debounceDuration) return;
    _lastCompletionPlayTime = now;
    try {
      await _completionPlayer.seek(Duration.zero);
      await _completionPlayer.play();
      debugPrint('✅ Task completed sound played');
    } catch (e) {
      debugPrint('❌ Error playing task completed sound: $e');
      await _recoverPlayer(_completionPlayer, _taskCompletedSound, volume: 1.0);
    }
  }

  Future<void> _recoverPlayer(AudioPlayer player, String assetPath, {double volume = 1.0}) async {
    try {
      await player.setAsset(assetPath);
      await player.setVolume(volume.clamp(0.0, 1.0));
      await player.setLoopMode(LoopMode.off);
      await player.stop();
      debugPrint('✅ Recovered player for $assetPath');
    } catch (e) {
      debugPrint('❌ Error recovering player for $assetPath: $e');
    }
  }

  Future<void> toggleSound(bool disabled) async {
    try {
      _isSoundDisabled.value = disabled;
      await _prefs?.setBool('isSoundDisabled', disabled);
      debugPrint('✅ Saved sound state: isSoundDisabled=$disabled');
    } catch (e) {
      debugPrint('❌ Error saving sound state: $e');
      rethrow;
    }
  }

  bool get isSoundDisabled => _isSoundDisabled.value;

  @override
  void onClose() {
    _buttonPlayer.dispose();
    _completionPlayer.dispose();
    super.onClose();
    debugPrint('✅ SoundService closed');
  }
}