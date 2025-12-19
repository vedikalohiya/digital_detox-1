import 'package:flutter/material.dart';
import 'gamification_models.dart';
import 'firestore_service.dart';
import 'dart:math';

/// Service for managing all gamification features
class GamificationService extends ChangeNotifier {
  static final GamificationService _instance = GamificationService._internal();
  factory GamificationService() => _instance;
  GamificationService._internal();

  final FirestoreService _firestore = FirestoreService();
  UserGamificationData? _userData;
  bool _isLoading = false;

  UserGamificationData? get userData => _userData;
  bool get isLoading => _isLoading;

  // Initialize and load user data
  Future<void> initialize() async {
    if (!_firestore.isLoggedIn) return;
    await loadUserData();
  }

  Future<void> loadUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _firestore.getGamificationData();
      _userData = data != null 
          ? UserGamificationData.fromMap(data as Map<String, dynamic>)
          : UserGamificationData();
      await _updateLevelFromXP();
      await _checkStreak();
      await _checkBadgeUnlocks();
      await _updateAvatarState();
    } catch (e) {
      print('❌ Error loading gamification data: $e');
      _userData = UserGamificationData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============== XP & LEVELS ==============

  /// Award XP for focus time
  /// Returns the amount of XP awarded
  Future<int> awardFocusXP({
    required int focusMinutes,
    bool noAppSwitching = false,
    bool completedWithoutForceExit = false,
    bool usedDetoxMode = false,
    bool isPeakHours = false,
  }) async {
    if (!_firestore.isLoggedIn) return 0;

    int baseXP = focusMinutes; // 1 XP per minute
    int bonusXP = 0;

    // Bonus XP calculations
    if (noAppSwitching) bonusXP += (focusMinutes * 0.2).round();
    if (completedWithoutForceExit) bonusXP += 50;
    if (usedDetoxMode && isPeakHours) bonusXP += 100;

    int totalXP = baseXP + bonusXP;

    _userData = _userData?.copyWith(
          totalXP: (_userData!.totalXP + totalXP),
          totalFocusMinutes: _userData!.totalFocusMinutes + focusMinutes,
          totalSessions: _userData!.totalSessions + 1,
          lastSessionDate: DateTime.now(),
          hasUsedDetoxMode: _userData!.hasUsedDetoxMode || usedDetoxMode,
          hasCompletedSessionWithoutForceExit:
              _userData!.hasCompletedSessionWithoutForceExit ||
                  completedWithoutForceExit,
        ) ??
        UserGamificationData(
          totalXP: totalXP,
          totalFocusMinutes: focusMinutes,
          totalSessions: 1,
          lastSessionDate: DateTime.now(),
          hasUsedDetoxMode: usedDetoxMode,
          hasCompletedSessionWithoutForceExit: completedWithoutForceExit,
        );

    await _updateLevelFromXP();
    await _checkChestUnlocks(focusMinutes);
    await _updateGrowthEntity(focusMinutes);
    await _saveUserData();

    notifyListeners();
    return totalXP;
  }

  Future<void> _updateLevelFromXP() async {
    if (_userData == null) return;

    final currentLevel = Level.getLevelForXP(_userData!.totalXP);
    if (currentLevel.level != _userData!.currentLevel) {
      _userData = _userData!.copyWith(currentLevel: currentLevel.level);
      // Level up notification could be shown here
    }
  }

  int getXPForNextLevel() {
    if (_userData == null) return 0;
    return Level.getXPForNextLevel(_userData!.totalXP);
  }

  Level getCurrentLevel() {
    if (_userData == null) return Level.levels[0];
    return Level.getLevelForXP(_userData!.totalXP);
  }

  // ============== STREAKS ==============

  Future<void> _checkStreak() async {
    if (_userData == null) return;

    final now = DateTime.now();
    final lastDate = _userData!.streak.lastStreakDate;
    final streak = _userData!.streak;

    if (lastDate == null) {
      // First time, start streak
      _userData = _userData!.copyWith(
        streak: streak.copyWith(
          currentStreak: 1,
          lastStreakDate: now,
        ),
      );
      await _saveUserData();
      return;
    }

    final daysDifference = now.difference(lastDate).inDays;

    if (daysDifference == 0) {
      // Same day, streak continues
      return;
    } else if (daysDifference == 1) {
      // Consecutive day, increment streak
      _userData = _userData!.copyWith(
        streak: streak.copyWith(
          currentStreak: streak.currentStreak + 1,
          lastStreakDate: now,
        ),
      );
    } else if (daysDifference > 1) {
      // Streak broken
      if (streak.streakFrozen && streak.freezeExpiry != null) {
        if (now.isBefore(streak.freezeExpiry!)) {
          // Streak is frozen, continue it
          _userData = _userData!.copyWith(
            streak: streak.copyWith(
              lastStreakDate: now,
            ),
          );
        } else {
          // Freeze expired, break streak
          _userData = _userData!.copyWith(
            streak: streak.copyWith(
              currentStreak: 0,
              lastStreakDate: now,
              streakFrozen: false,
              freezeExpiry: null,
            ),
          );
        }
      } else if (streak.graceTokens > 0) {
        // Use grace token
        _userData = _userData!.copyWith(
          streak: streak.copyWith(
            graceTokens: streak.graceTokens - 1,
            lastStreakDate: now,
          ),
        );
      } else {
        // Streak broken
        _userData = _userData!.copyWith(
          streak: streak.copyWith(
            currentStreak: 0,
            lastStreakDate: now,
          ),
        );
      }
    }

    await _saveUserData();
  }

  Future<bool> useStreakFreeze() async {
    if (_userData == null) return false;
    if (_userData!.streak.streakFrozen) return false; // Already frozen

    final now = DateTime.now();
    final expiry = now.add(const Duration(days: 1));

    _userData = _userData!.copyWith(
      streak: _userData!.streak.copyWith(
        streakFrozen: true,
        freezeExpiry: expiry,
      ),
    );

    await _saveUserData();
    notifyListeners();
    return true;
  }

  Future<void> updateStreakForToday() async {
    await _checkStreak();
  }

  // ============== BADGES ==============

  Future<void> _checkBadgeUnlocks() async {
    if (_userData == null) return;

    final newBadges = <String>[];

    // Check various badge conditions
    if (_userData!.totalSessions >= 1 &&
        !_userData!.unlockedBadges.contains('first_focus')) {
      newBadges.add('first_focus');
    }

    if (_userData!.streak.currentStreak >= 7 &&
        !_userData!.unlockedBadges.contains('week_warrior')) {
      newBadges.add('week_warrior');
    }

    if (_userData!.streak.currentStreak >= 30 &&
        !_userData!.unlockedBadges.contains('month_master')) {
      newBadges.add('month_master');
    }

    if (_userData!.totalSessions >= 100 &&
        !_userData!.unlockedBadges.contains('detox_dedicated')) {
      newBadges.add('detox_dedicated');
    }

    if (_userData!.hasUsedDetoxMode &&
        !_userData!.unlockedBadges.contains('parent_hero')) {
      // This would be checked when detox mode is used
    }

    if (newBadges.isNotEmpty) {
      final badgeXP = newBadges.fold<int>(
        0,
        (sum, badgeId) {
          final badge = GamificationBadge.allBadges.firstWhere(
            (b) => b.id == badgeId,
            orElse: () => GamificationBadge.allBadges[0],
          );
          return sum + badge.xpReward;
        },
      );

      _userData = _userData!.copyWith(
        unlockedBadges: [..._userData!.unlockedBadges, ...newBadges],
        totalXP: _userData!.totalXP + badgeXP,
      );

      await _saveUserData();
      notifyListeners();
    }
  }

  Future<void> unlockBadge(String badgeId) async {
    if (_userData == null) return;
    if (_userData!.unlockedBadges.contains(badgeId)) return;

    final badge = GamificationBadge.allBadges.firstWhere(
      (b) => b.id == badgeId,
      orElse: () => GamificationBadge.allBadges[0],
    );

    _userData = _userData!.copyWith(
      unlockedBadges: [..._userData!.unlockedBadges, badgeId],
      totalXP: _userData!.totalXP + badge.xpReward,
    );

    await _saveUserData();
    await _updateLevelFromXP();
    notifyListeners();
  }

  List<GamificationBadge> getUnlockedBadges() {
    if (_userData == null) return [];
    return GamificationBadge.allBadges
        .where((b) => _userData!.unlockedBadges.contains(b.id))
        .toList();
  }

  List<GamificationBadge> getLockedBadges() {
    if (_userData == null) return GamificationBadge.allBadges;
    return GamificationBadge.allBadges
        .where((b) => !_userData!.unlockedBadges.contains(b.id))
        .toList();
  }

  // ============== CHALLENGES ==============

  Future<bool> completeChallenge(String challengeId) async {
    if (_userData == null) return false;
    if (_userData!.completedChallenges.contains(challengeId)) return false;

    final challenge = Challenge.getDailyChallenges()
            .firstWhere(
              (c) => c.id == challengeId,
              orElse: () => Challenge.getWeeklyChallenges()
                  .firstWhere(
                    (c) => c.id == challengeId,
                    orElse: () => Challenge.getDailyChallenges()[0],
                  ),
            );

    _userData = _userData!.copyWith(
      completedChallenges: [..._userData!.completedChallenges, challengeId],
      totalXP: _userData!.totalXP + challenge.xpReward,
    );

    if (challenge.badgeId != null) {
      await unlockBadge(challenge.badgeId!);
    }

    await _saveUserData();
    await _updateLevelFromXP();
    notifyListeners();
    return true;
  }

  // ============== AVATAR ==============

  Future<void> _updateAvatarState() async {
    if (_userData == null) return;

    String newState = 'tired';
    if (_userData!.totalXP >= 5000) {
      newState = 'confident';
    } else if (_userData!.totalXP >= 2000) {
      newState = 'calm';
    } else if (_userData!.totalXP >= 500) {
      newState = 'energetic';
    }

    if (newState != _userData!.avatar.state) {
      _userData = _userData!.copyWith(
        avatar: _userData!.avatar.copyWith(
          state: newState,
          level: _userData!.currentLevel,
        ),
      );
      await _saveUserData();
    }
  }

  Future<void> unlockAvatarItem(String itemId) async {
    if (_userData == null) return;
    if (_userData!.avatar.unlockedItems.contains(itemId)) return;

    _userData = _userData!.copyWith(
      avatar: _userData!.avatar.copyWith(
        unlockedItems: [..._userData!.avatar.unlockedItems, itemId],
      ),
    );

    await _saveUserData();
    notifyListeners();
  }

  // ============== FOCUS CHESTS ==============

  Future<void> _checkChestUnlocks(int focusMinutes) async {
    if (_userData == null) return;

    for (final chest in FocusChest.chests) {
      if (_userData!.totalFocusMinutes >= chest.minutesRequired &&
          !(_userData!.openedChests[chest.id] ?? false)) {
        // Chest unlocked but not opened yet
        // This will be handled when user opens the chest
      }
    }
  }

  Future<List<ChestReward>?> openChest(String chestId) async {
    if (_userData == null) return null;
    if (_userData!.openedChests[chestId] ?? false) return null; // Already opened

    final chest = FocusChest.chests.firstWhere(
      (c) => c.id == chestId,
      orElse: () => FocusChest.chests[0],
    );

    if (_userData!.totalFocusMinutes < chest.minutesRequired) {
      return null; // Not enough focus time
    }

    // Award rewards
    int totalXP = 0;
    for (final reward in chest.rewards) {
      if (reward.type == RewardType.xp) {
        totalXP += reward.value;
      } else if (reward.type == RewardType.badge && reward.badgeId != null) {
        await unlockBadge(reward.badgeId!);
      } else if (reward.type == RewardType.avatarItem &&
          reward.itemId != null) {
        await unlockAvatarItem(reward.itemId!);
      }
    }

    if (totalXP > 0) {
      _userData = _userData!.copyWith(
        totalXP: _userData!.totalXP + totalXP,
      );
    }

    final updatedChests = Map<String, bool>.from(_userData!.openedChests);
    updatedChests[chestId] = true;

    _userData = _userData!.copyWith(openedChests: updatedChests);

    await _saveUserData();
    await _updateLevelFromXP();
    notifyListeners();

    return chest.rewards;
  }

  List<FocusChest> getAvailableChests() {
    if (_userData == null) return [];
    return FocusChest.chests.where((chest) {
      final isUnlocked = _userData!.totalFocusMinutes >= chest.minutesRequired;
      final isOpened = _userData!.openedChests[chest.id] ?? false;
      return isUnlocked && !isOpened;
    }).toList();
  }

  // ============== GROWTH ENTITY ==============

  Future<void> _updateGrowthEntity(int focusMinutes) async {
    if (_userData == null) return;

    GrowthEntity? entity = _userData!.growthEntity;

    if (entity == null) {
      // Create initial growth entity
      entity = GrowthEntity(
        type: 'plant',
        name: 'Focus Plant',
        growthStage: 0,
        totalGrowth: 0,
      );
    }

    if (!entity.isPaused) {
      entity = entity.copyWith(
        totalGrowth: entity.totalGrowth + focusMinutes,
        lastWatered: DateTime.now(),
      );

      // Update growth stage based on total growth
      int newStage = 0;
      if (entity.totalGrowth >= 1000) {
        newStage = 4; // Fully grown
      } else if (entity.totalGrowth >= 500) {
        newStage = 3;
      } else if (entity.totalGrowth >= 200) {
        newStage = 2;
      } else if (entity.totalGrowth >= 50) {
        newStage = 1;
      }

      entity = entity.copyWith(growthStage: newStage);
    }

    _userData = _userData!.copyWith(growthEntity: entity);
    await _saveUserData();
    notifyListeners();
  }

  Future<void> pauseGrowth() async {
    if (_userData == null || _userData!.growthEntity == null) return;

    _userData = _userData!.copyWith(
      growthEntity: _userData!.growthEntity!.copyWith(isPaused: true),
    );

    await _saveUserData();
    notifyListeners();
  }

  Future<void> resumeGrowth() async {
    if (_userData == null || _userData!.growthEntity == null) return;

    _userData = _userData!.copyWith(
      growthEntity: _userData!.growthEntity!.copyWith(isPaused: false),
    );

    await _saveUserData();
    notifyListeners();
  }

  // ============== ANTI-CHEAT ==============

  bool validateFocusSession({
    required int focusMinutes,
    required DateTime startTime,
    required DateTime endTime,
    bool appWasBackgrounded = false,
  }) {
    // Check if app was backgrounded
    if (appWasBackgrounded) {
      return false; // No XP if app was backgrounded
    }

    // Check time consistency
    final actualDuration = endTime.difference(startTime).inMinutes;
    if ((actualDuration - focusMinutes).abs() > 5) {
      // More than 5 minutes difference is suspicious
      return false;
    }

    return true;
  }

  // ============== DATA PERSISTENCE ==============

  Future<void> _saveUserData() async {
    if (_userData == null || !_firestore.isLoggedIn) return;

    try {
      await _firestore.saveGamificationData(_userData!.toMap());
    } catch (e) {
      print('❌ Error saving gamification data: $e');
    }
  }

  // ============== QUOTES ==============

  static String getMotivationalQuote() {
    final quotes = [
      "Every moment of focus is a step toward your goals 🌟",
      "You're building something amazing, one minute at a time 💪",
      "Focus is a superpower. You're using it right now ⚡",
      "Small consistent actions create extraordinary results 🔑",
      "Your mind is getting stronger with every session 🧠",
      "You're not just avoiding distractions, you're choosing focus 🎯",
      "This focus time is an investment in your future self 🌱",
      "You're doing something most people can't - staying focused 🏆",
    ];
    return quotes[Random().nextInt(quotes.length)];
  }
}