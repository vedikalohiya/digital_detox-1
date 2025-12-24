import 'gamification_service.dart';
import 'dart:async';

/// Helper class to integrate gamification with focus sessions
class GamificationIntegration {
  static final GamificationService _service = GamificationService();

  /// Award XP when a focus session completes
  /// Call this when a user completes a focus session
  static Future<int> onFocusSessionComplete({
    required int focusMinutes,
    bool noAppSwitching = false,
    bool completedWithoutForceExit = false,
    bool usedDetoxMode = false,
    bool isPeakHours = false,
    DateTime? startTime,
    DateTime? endTime,
    bool appWasBackgrounded = false,
  }) async {
    // Validate session (anti-cheat)
    if (startTime != null && endTime != null) {
      final isValid = _service.validateFocusSession(
        focusMinutes: focusMinutes,
        startTime: startTime,
        endTime: endTime,
        appWasBackgrounded: appWasBackgrounded,
      );

      if (!isValid) {
        print('⚠️ Invalid focus session - no XP awarded');
        return 0;
      }
    }

    // Award XP
    final xpAwarded = await _service.awardFocusXP(
      focusMinutes: focusMinutes,
      noAppSwitching: noAppSwitching,
      completedWithoutForceExit: completedWithoutForceExit,
      usedDetoxMode: usedDetoxMode,
      isPeakHours: isPeakHours,
    );

    // Update streak
    await _service.updateStreakForToday();

    return xpAwarded;
  }

  /// Award XP when detox mode is used
  static Future<int> onDetoxModeUsed({
    required int blockedMinutes,
    bool isPeakHours = false,
  }) async {
    return await _service.awardFocusXP(
      focusMinutes: blockedMinutes,
      usedDetoxMode: true,
      isPeakHours: isPeakHours,
    );
  }

  /// Check if it's peak distraction hours (e.g., 6 PM - 10 PM)
  static bool isPeakHours() {
    final now = DateTime.now();
    final hour = now.hour;
    // Peak hours: 6 PM - 10 PM (18:00 - 22:00)
    return hour >= 18 && hour < 22;
  }

  /// Initialize gamification service
  static Future<void> initialize() async {
    await _service.initialize();
  }
}






