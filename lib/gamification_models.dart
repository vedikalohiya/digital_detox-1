/// Gamification Models for Digital Detox App

// Level definitions with titles
class Level {
  final int level;
  final String title;
  final int xpRequired;
  final String? emoji;

  const Level({
    required this.level,
    required this.title,
    required this.xpRequired,
    this.emoji,
  });

  static const List<Level> levels = [
    Level(level: 1, title: 'Digital Beginner', xpRequired: 0),
    Level(level: 5, title: 'Focus Explorer', xpRequired: 500),
    Level(level: 10, title: 'Mindful Master', xpRequired: 2000),
    Level(level: 20, title: 'Detox Champion', xpRequired: 8000),
    Level(level: 50, title: 'Zen Guardian', xpRequired: 50000, emoji: '🧘'),
  ];

  static Level getLevelForXP(int xp) {
    for (int i = levels.length - 1; i >= 0; i--) {
      if (xp >= levels[i].xpRequired) {
        return levels[i];
      }
    }
    return levels[0];
  }

  static int getXPForNextLevel(int currentXP) {
    final currentLevel = getLevelForXP(currentXP);
    final nextLevelIndex = levels.indexWhere((l) => l.level > currentLevel.level);
    if (nextLevelIndex == -1) return 0; // Max level
    return levels[nextLevelIndex].xpRequired - currentXP;
  }
}

// Badge definitions
class GamificationBadge {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final int xpReward;
  final BadgeCategory category;

  const GamificationBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    this.xpReward = 50,
    required this.category,
  });

  static const List<GamificationBadge> allBadges = [
    // Focus badges
    GamificationBadge(
      id: 'mind_over_scroll',
      name: 'Mind Over Scroll',
      description: '1 hour without social apps',
      emoji: '🧠',
      xpReward: 100,
      category: BadgeCategory.focus,
    ),
    GamificationBadge(
      id: 'night_monk',
      name: 'Night Monk',
      description: 'No phone after bedtime',
      emoji: '🌙',
      xpReward: 150,
      category: BadgeCategory.sleep,
    ),
    GamificationBadge(
      id: 'silence_seeker',
      name: 'Silence Seeker',
      description: 'Zero notifications session',
      emoji: '🔕',
      xpReward: 75,
      category: BadgeCategory.focus,
    ),
    GamificationBadge(
      id: 'parent_hero',
      name: 'Parent Hero',
      description: 'Kids mode used consistently',
      emoji: '👶',
      xpReward: 200,
      category: BadgeCategory.family,
    ),
    GamificationBadge(
      id: 'first_focus',
      name: 'First Focus',
      description: 'Complete your first focus session',
      emoji: '⭐',
      xpReward: 50,
      category: BadgeCategory.milestone,
    ),
    GamificationBadge(
      id: 'week_warrior',
      name: 'Week Warrior',
      description: '7 day streak',
      emoji: '🔥',
      xpReward: 300,
      category: BadgeCategory.streak,
    ),
    GamificationBadge(
      id: 'month_master',
      name: 'Month Master',
      description: '30 day streak',
      emoji: '👑',
      xpReward: 1000,
      category: BadgeCategory.streak,
    ),
    GamificationBadge(
      id: 'detox_dedicated',
      name: 'Detox Dedicated',
      description: '100 focus sessions completed',
      emoji: '💎',
      xpReward: 500,
      category: BadgeCategory.milestone,
    ),
  ];
}

enum BadgeCategory {
  focus,
  sleep,
  family,
  milestone,
  streak,
  challenge,
}

// Challenge definitions
class Challenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final int targetValue;
  final int xpReward;
  final String? badgeId;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    this.xpReward = 100,
    this.badgeId,
    this.startDate,
    this.endDate,
    this.isActive = true,
  });

  static List<Challenge> getDailyChallenges() {
    final now = DateTime.now();
    return [
      Challenge(
        id: 'no_social_2h',
        title: 'No Social Media for 2 Hours',
        description: 'Stay away from social apps for 2 hours',
        type: ChallengeType.daily,
        targetValue: 120, // minutes
        xpReward: 150,
      ),
      Challenge(
        id: 'complete_3_sessions',
        title: 'Complete 3 Focus Sessions',
        description: 'Finish 3 focus sessions today',
        type: ChallengeType.daily,
        targetValue: 3,
        xpReward: 200,
      ),
      Challenge(
        id: 'phone_free_morning',
        title: 'Phone-Free Morning',
        description: 'No phone use before 10 AM',
        type: ChallengeType.daily,
        targetValue: 1,
        xpReward: 100,
      ),
    ];
  }

  static List<Challenge> getWeeklyChallenges() {
    return [
      Challenge(
        id: 'sleep_detox_week',
        title: 'Sleep Detox Week',
        description: 'No phone after 10 PM all week',
        type: ChallengeType.weekly,
        targetValue: 7,
        xpReward: 500,
        badgeId: 'night_monk',
      ),
      Challenge(
        id: 'focus_master_week',
        title: 'Focus Master Week',
        description: 'Complete 10 focus sessions this week',
        type: ChallengeType.weekly,
        targetValue: 10,
        xpReward: 400,
      ),
    ];
  }
}

enum ChallengeType {
  daily,
  weekly,
  special,
}

// Avatar state
class AvatarState {
  final String state; // 'tired', 'energetic', 'calm', 'confident'
  final int level;
  final List<String> unlockedItems;
  final String? currentTheme;

  AvatarState({
    required this.state,
    required this.level,
    this.unlockedItems = const [],
    this.currentTheme,
  });

  Map<String, dynamic> toMap() => {
        'state': state,
        'level': level,
        'unlockedItems': unlockedItems,
        'currentTheme': currentTheme,
      };

  factory AvatarState.fromMap(Map<String, dynamic> map) => AvatarState(
        state: map['state'] ?? 'tired',
        level: map['level'] ?? 1,
        unlockedItems: List<String>.from(map['unlockedItems'] ?? []),
        currentTheme: map['currentTheme'],
      );

  AvatarState copyWith({
    String? state,
    int? level,
    List<String>? unlockedItems,
    String? currentTheme,
  }) =>
      AvatarState(
        state: state ?? this.state,
        level: level ?? this.level,
        unlockedItems: unlockedItems ?? this.unlockedItems,
        currentTheme: currentTheme ?? this.currentTheme,
      );
}

// Focus Chest rewards
class FocusChest {
  final String id;
  final int minutesRequired;
  final List<ChestReward> rewards;
  final bool isOpened;

  const FocusChest({
    required this.id,
    required this.minutesRequired,
    required this.rewards,
    this.isOpened = false,
  });

  static const List<FocusChest> chests = [
    FocusChest(
      id: 'chest_30min',
      minutesRequired: 30,
      rewards: [
        ChestReward(type: RewardType.xp, value: 50),
        ChestReward(type: RewardType.quote),
      ],
    ),
    FocusChest(
      id: 'chest_1hr',
      minutesRequired: 60,
      rewards: [
        ChestReward(type: RewardType.xp, value: 150),
        ChestReward(type: RewardType.badge, value: 0, badgeId: 'first_focus'),
        ChestReward(type: RewardType.quote),
      ],
    ),
    FocusChest(
      id: 'chest_3hr',
      minutesRequired: 180,
      rewards: [
        ChestReward(type: RewardType.xp, value: 500),
        ChestReward(type: RewardType.avatarItem, value: 0, itemId: 'crown'),
        ChestReward(type: RewardType.quote),
      ],
    ),
  ];
}

class ChestReward {
  final RewardType type;
  final int value;
  final String? badgeId;
  final String? itemId;
  final String? quote;

  const ChestReward({
    required this.type,
    this.value = 0,
    this.badgeId,
    this.itemId,
    this.quote,
  });
}

enum RewardType {
  xp,
  badge,
  avatarItem,
  quote,
  theme,
}

// Growth entity (plant/tree/city/pet)
class GrowthEntity {
  final String type; // 'plant', 'tree', 'city', 'pet'
  final String name;
  final int growthStage;
  final int totalGrowth;
  final DateTime? lastWatered;
  final bool isPaused;

  GrowthEntity({
    required this.type,
    required this.name,
    this.growthStage = 0,
    this.totalGrowth = 0,
    this.lastWatered,
    this.isPaused = false,
  });

  Map<String, dynamic> toMap() => {
        'type': type,
        'name': name,
        'growthStage': growthStage,
        'totalGrowth': totalGrowth,
        'lastWatered': lastWatered?.toIso8601String(),
        'isPaused': isPaused,
      };

  factory GrowthEntity.fromMap(Map<String, dynamic> map) => GrowthEntity(
        type: map['type'] ?? 'plant',
        name: map['name'] ?? 'Focus Plant',
        growthStage: map['growthStage'] ?? 0,
        totalGrowth: map['totalGrowth'] ?? 0,
        lastWatered: map['lastWatered'] != null
            ? DateTime.parse(map['lastWatered'])
            : null,
        isPaused: map['isPaused'] ?? false,
      );

  GrowthEntity copyWith({
    String? type,
    String? name,
    int? growthStage,
    int? totalGrowth,
    DateTime? lastWatered,
    bool? isPaused,
  }) =>
      GrowthEntity(
        type: type ?? this.type,
        name: name ?? this.name,
        growthStage: growthStage ?? this.growthStage,
        totalGrowth: totalGrowth ?? this.totalGrowth,
        lastWatered: lastWatered ?? this.lastWatered,
        isPaused: isPaused ?? this.isPaused,
      );
}

// Streak data
class StreakData {
  final int currentStreak;
  final DateTime? lastStreakDate;
  final int graceTokens;
  final bool streakFrozen;
  final DateTime? freezeExpiry;

  StreakData({
    this.currentStreak = 0,
    this.lastStreakDate,
    this.graceTokens = 2,
    this.streakFrozen = false,
    this.freezeExpiry,
  });

  Map<String, dynamic> toMap() => {
        'currentStreak': currentStreak,
        'lastStreakDate': lastStreakDate?.toIso8601String(),
        'graceTokens': graceTokens,
        'streakFrozen': streakFrozen,
        'freezeExpiry': freezeExpiry?.toIso8601String(),
      };

  factory StreakData.fromMap(Map<String, dynamic> map) => StreakData(
        currentStreak: map['currentStreak'] ?? 0,
        lastStreakDate: map['lastStreakDate'] != null
            ? DateTime.parse(map['lastStreakDate'])
            : null,
        graceTokens: map['graceTokens'] ?? 2,
        streakFrozen: map['streakFrozen'] ?? false,
        freezeExpiry: map['freezeExpiry'] != null
            ? DateTime.parse(map['freezeExpiry'])
            : null,
      );

  StreakData copyWith({
    int? currentStreak,
    DateTime? lastStreakDate,
    int? graceTokens,
    bool? streakFrozen,
    DateTime? freezeExpiry,
  }) =>
      StreakData(
        currentStreak: currentStreak ?? this.currentStreak,
        lastStreakDate: lastStreakDate ?? this.lastStreakDate,
        graceTokens: graceTokens ?? this.graceTokens,
        streakFrozen: streakFrozen ?? this.streakFrozen,
        freezeExpiry: freezeExpiry ?? this.freezeExpiry,
      );
}

// User gamification data
class UserGamificationData {
  final int totalXP;
  final int currentLevel;
  final StreakData streak;
  final List<String> unlockedBadges;
  final List<String> completedChallenges;
  final AvatarState avatar;
  final GrowthEntity? growthEntity;
  final Map<String, bool> openedChests;
  final int totalFocusMinutes;
  final int totalSessions;
  final DateTime? lastSessionDate;
  final bool hasUsedDetoxMode;
  final bool hasCompletedSessionWithoutForceExit;

  UserGamificationData({
    this.totalXP = 0,
    this.currentLevel = 1,
    StreakData? streak,
    this.unlockedBadges = const [],
    this.completedChallenges = const [],
    AvatarState? avatar,
    this.growthEntity,
    this.openedChests = const {},
    this.totalFocusMinutes = 0,
    this.totalSessions = 0,
    this.lastSessionDate,
    this.hasUsedDetoxMode = false,
    this.hasCompletedSessionWithoutForceExit = false,
  }) : streak = streak ?? StreakData(),
       avatar = avatar ?? AvatarState(state: 'tired', level: 1);

  Map<String, dynamic> toMap() => {
        'totalXP': totalXP,
        'currentLevel': currentLevel,
        'streak': streak.toMap(),
        'unlockedBadges': unlockedBadges,
        'completedChallenges': completedChallenges,
        'avatar': avatar.toMap(),
        'growthEntity': growthEntity?.toMap(),
        'openedChests': openedChests,
        'totalFocusMinutes': totalFocusMinutes,
        'totalSessions': totalSessions,
        'lastSessionDate': lastSessionDate?.toIso8601String(),
        'hasUsedDetoxMode': hasUsedDetoxMode,
        'hasCompletedSessionWithoutForceExit':
            hasCompletedSessionWithoutForceExit,
      };

  factory UserGamificationData.fromMap(Map<String, dynamic> map) =>
      UserGamificationData(
        totalXP: map['totalXP'] ?? 0,
        currentLevel: map['currentLevel'] ?? 1,
        streak: map['streak'] != null
            ? StreakData.fromMap(map['streak'] as Map<String, dynamic>)
            : StreakData(),
        unlockedBadges: List<String>.from(map['unlockedBadges'] ?? []),
        completedChallenges: List<String>.from(map['completedChallenges'] ?? []),
        avatar: map['avatar'] != null
            ? AvatarState.fromMap(map['avatar'] as Map<String, dynamic>)
            : AvatarState(state: 'tired', level: 1),
        growthEntity: map['growthEntity'] != null
            ? GrowthEntity.fromMap(
                map['growthEntity'] as Map<String, dynamic>)
            : null,
        openedChests: Map<String, bool>.from(map['openedChests'] ?? {}),
        totalFocusMinutes: map['totalFocusMinutes'] ?? 0,
        totalSessions: map['totalSessions'] ?? 0,
        lastSessionDate: map['lastSessionDate'] != null
            ? DateTime.parse(map['lastSessionDate'])
            : null,
        hasUsedDetoxMode: map['hasUsedDetoxMode'] ?? false,
        hasCompletedSessionWithoutForceExit:
            map['hasCompletedSessionWithoutForceExit'] ?? false,
      );

  UserGamificationData copyWith({
    int? totalXP,
    int? currentLevel,
    StreakData? streak,
    List<String>? unlockedBadges,
    List<String>? completedChallenges,
    AvatarState? avatar,
    GrowthEntity? growthEntity,
    Map<String, bool>? openedChests,
    int? totalFocusMinutes,
    int? totalSessions,
    DateTime? lastSessionDate,
    bool? hasUsedDetoxMode,
    bool? hasCompletedSessionWithoutForceExit,
  }) =>
      UserGamificationData(
        totalXP: totalXP ?? this.totalXP,
        currentLevel: currentLevel ?? this.currentLevel,
        streak: streak ?? this.streak,
        unlockedBadges: unlockedBadges ?? this.unlockedBadges,
        completedChallenges: completedChallenges ?? this.completedChallenges,
        avatar: avatar ?? this.avatar,
        growthEntity: growthEntity ?? this.growthEntity,
        openedChests: openedChests ?? this.openedChests,
        totalFocusMinutes: totalFocusMinutes ?? this.totalFocusMinutes,
        totalSessions: totalSessions ?? this.totalSessions,
        lastSessionDate: lastSessionDate ?? this.lastSessionDate,
        hasUsedDetoxMode: hasUsedDetoxMode ?? this.hasUsedDetoxMode,
        hasCompletedSessionWithoutForceExit:
            hasCompletedSessionWithoutForceExit ??
                this.hasCompletedSessionWithoutForceExit,
      );
}