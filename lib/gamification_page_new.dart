import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'gamification_models.dart';
import 'gamification_service.dart';
import 'firestore_service.dart';
import 'app_theme.dart';
import 'dart:math' as math;

class GamificationPageNew extends StatefulWidget {
  const GamificationPageNew({super.key});

  @override
  State<GamificationPageNew> createState() => _GamificationPageNewState();
}

class _GamificationPageNewState extends State<GamificationPageNew>
    with TickerProviderStateMixin {
  final GamificationService _gamificationService = GamificationService();
  int _selectedTab = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _gamificationService.addListener(_onGamificationUpdate);
    _gamificationService.initialize();
  }

  @override
  void dispose() {
    _gamificationService.removeListener(_onGamificationUpdate);
    _tabController.dispose();
    super.dispose();
  }

  void _onGamificationUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildLevelsTab(),
                    _buildBadgesTab(),
                    _buildChallengesTab(),
                    _buildAvatarTab(),
                    _buildLeaderboardTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gamification',
                  style: AppTheme.heading1.copyWith(color: Colors.white),
                ),
                Text(
                  'Level up your focus journey',
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicator: BoxDecoration(
          color: AppTheme.accentTeal,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Levels'),
          Tab(text: 'Badges'),
          Tab(text: 'Challenges'),
          Tab(text: 'Avatar'),
          Tab(text: 'Leaderboard'),
        ],
      ),
    );
  }

  // ============== OVERVIEW TAB ==============

  Widget _buildOverviewTab() {
    final userData = _gamificationService.userData;
    if (userData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentLevel = _gamificationService.getCurrentLevel();
    final xpForNext = _gamificationService.getXPForNextLevel();
    final progress = userData.totalXP > 0
        ? (userData.totalXP - currentLevel.xpRequired) /
            (xpForNext + currentLevel.xpRequired - currentLevel.xpRequired)
        : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // XP & Level Card
          _buildXPLevelCard(userData, currentLevel, progress, xpForNext),
          const SizedBox(height: 16),

          // Streak Card
          _buildStreakCard(userData),
          const SizedBox(height: 16),

          // Stats Row
          Row(
            children: [
              Expanded(child: _buildStatCard('Total Sessions', '${userData.totalSessions}', Icons.check_circle)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Focus Minutes', '${userData.totalFocusMinutes}', Icons.timer)),
            ],
          ),
          const SizedBox(height: 16),

          // Growth Entity Card
          if (userData.growthEntity != null)
            _buildGrowthCard(userData.growthEntity!),
          const SizedBox(height: 16),

          // Available Chests
          _buildChestsSection(),
        ],
      ),
    );
  }

  Widget _buildXPLevelCard(
    UserGamificationData userData,
    Level level,
    double progress,
    int xpForNext,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Level ${level.level}',
                    style: AppTheme.heading2.copyWith(color: Colors.white),
                  ),
                  Text(
                    level.title,
                    style: AppTheme.bodyLarge.copyWith(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentTeal.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${level.level}',
                  style: AppTheme.heading1.copyWith(
                    color: Colors.white,
                    fontSize: 32,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // XP Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${userData.totalXP} XP',
                    style: AppTheme.bodyMedium.copyWith(color: Colors.white),
                  ),
                  Text(
                    '${level.xpRequired + xpForNext} XP',
                    style: AppTheme.bodyMedium.copyWith(color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 12,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentTeal),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$xpForNext XP to next level',
                style: AppTheme.bodySmall.copyWith(color: Colors.white60),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(UserGamificationData userData) {
    final streak = userData.streak;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withOpacity(0.3),
            Colors.red.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department,
              color: Colors.orange, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${streak.currentStreak} Day Streak',
                  style: AppTheme.heading2.copyWith(color: Colors.white),
                ),
                Text(
                  '${streak.graceTokens} grace tokens',
                  style: AppTheme.bodyMedium.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          if (streak.streakFrozen)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.ac_unit, color: Colors.blue, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.heading2.copyWith(color: Colors.white),
          ),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthCard(GrowthEntity entity) {
    final emoji = entity.type == 'plant'
        ? '🌱'
        : entity.type == 'tree'
            ? '🌳'
            : entity.type == 'city'
                ? '🏙️'
                : '🐾';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withOpacity(0.3),
            Colors.teal.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entity.name,
                  style: AppTheme.heading2.copyWith(color: Colors.white),
                ),
                Text(
                  'Stage ${entity.growthStage}/4',
                  style: AppTheme.bodyMedium.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (entity.growthStage / 4).clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ),
                if (entity.isPaused)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '⏸️ Growth Paused',
                      style: AppTheme.bodySmall.copyWith(color: Colors.orange),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChestsSection() {
    final availableChests = _gamificationService.getAvailableChests();
    if (availableChests.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Chests',
          style: AppTheme.heading2.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 12),
        ...availableChests.map((chest) => _buildChestCard(chest)),
      ],
    );
  }

  Widget _buildChestCard(FocusChest chest) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium, color: Colors.amber, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${chest.minutesRequired} min Focus Chest',
                  style: AppTheme.bodyLarge.copyWith(color: Colors.white),
                ),
                Text(
                  'Tap to open!',
                  style: AppTheme.bodySmall.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.amber),
            onPressed: () => _openChest(chest),
          ),
        ],
      ),
    );
  }

  Future<void> _openChest(FocusChest chest) async {
    final rewards = await _gamificationService.openChest(chest.id);
    if (rewards == null) return;

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => _buildChestRewardDialog(rewards),
    );
  }

  Widget _buildChestRewardDialog(List<ChestReward> rewards) {
    return AlertDialog(
      backgroundColor: AppTheme.primaryDeepTeal,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Chest Opened!', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: rewards.map((reward) {
          if (reward.type == RewardType.xp) {
            return ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: Text('+${reward.value} XP', style: const TextStyle(color: Colors.white)),
            );
          } else if (reward.type == RewardType.badge) {
            return ListTile(
              leading: const Icon(Icons.workspace_premium, color: Colors.purple),
              title: const Text('Badge Unlocked!', style: TextStyle(color: Colors.white)),
            );
          } else if (reward.type == RewardType.avatarItem) {
            return ListTile(
              leading: const Icon(Icons.face, color: Colors.blue),
              title: const Text('Avatar Item Unlocked!', style: TextStyle(color: Colors.white)),
            );
          } else if (reward.type == RewardType.quote) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '"${GamificationService.getMotivationalQuote()}"',
                style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            );
          }
          return const SizedBox.shrink();
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Awesome!', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  // ============== LEVELS TAB ==============

  Widget _buildLevelsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: Level.levels.map((level) => _buildLevelCard(level)).toList(),
    );
  }

  Widget _buildLevelCard(Level level) {
    final userData = _gamificationService.userData;
    final isUnlocked = userData != null && userData.totalXP >= level.xpRequired;
    final isCurrent = userData != null &&
        _gamificationService.getCurrentLevel().level == level.level;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnlocked
            ? Colors.white.withOpacity(0.2)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent
              ? AppTheme.accentTeal
              : Colors.white.withOpacity(0.2),
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? AppTheme.accentTeal.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${level.level}',
              style: TextStyle(
                color: isUnlocked ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      level.title,
                      style: AppTheme.bodyLarge.copyWith(
                        color: isUnlocked ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentTeal,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'CURRENT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '${level.xpRequired} XP required',
                  style: AppTheme.bodySmall.copyWith(
                    color: isUnlocked ? Colors.white70 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (isUnlocked)
            const Icon(Icons.check_circle, color: Colors.green)
          else
            const Icon(Icons.lock, color: Colors.grey),
        ],
      ),
    );
  }

  // ============== BADGES TAB ==============

  Widget _buildBadgesTab() {
    final unlocked = _gamificationService.getUnlockedBadges();
    final locked = _gamificationService.getLockedBadges();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (unlocked.isNotEmpty) ...[
            Text(
              'Unlocked Badges (${unlocked.length})',
              style: AppTheme.heading2.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: unlocked.length,
              itemBuilder: (context, index) => _buildBadgeCard(unlocked[index], true),
            ),
            const SizedBox(height: 24),
          ],
          Text(
            'Locked Badges (${locked.length})',
            style: AppTheme.heading2.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: locked.length,
            itemBuilder: (context, index) => _buildBadgeCard(locked[index], false),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(GamificationBadge badge, bool isUnlocked) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnlocked
            ? Colors.white.withOpacity(0.2)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? Colors.amber.withOpacity(0.5)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            badge.emoji,
            style: TextStyle(
              fontSize: isUnlocked ? 48 : 32,
              color: isUnlocked ? null : Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            badge.name,
            style: AppTheme.bodyMedium.copyWith(
              color: isUnlocked ? Colors.white : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            badge.description,
            style: AppTheme.bodySmall.copyWith(
              color: isUnlocked ? Colors.white70 : Colors.grey,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (!isUnlocked)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Icon(Icons.lock, color: Colors.grey, size: 16),
            ),
        ],
      ),
    );
  }

  // ============== CHALLENGES TAB ==============

  Widget _buildChallengesTab() {
    final dailyChallenges = Challenge.getDailyChallenges();
    final weeklyChallenges = Challenge.getWeeklyChallenges();
    final userData = _gamificationService.userData;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Challenges',
            style: AppTheme.heading2.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 12),
          ...dailyChallenges.map((challenge) => _buildChallengeCard(
                challenge,
                userData?.completedChallenges.contains(challenge.id) ?? false,
              )),
          const SizedBox(height: 24),
          Text(
            'Weekly Challenges',
            style: AppTheme.heading2.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 12),
          ...weeklyChallenges.map((challenge) => _buildChallengeCard(
                challenge,
                userData?.completedChallenges.contains(challenge.id) ?? false,
              )),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(Challenge challenge, bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green.withOpacity(0.2)
            : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? Colors.green.withOpacity(0.5)
              : Colors.white.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.green.withOpacity(0.3)
                  : AppTheme.accentTeal.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCompleted ? Icons.check_circle : Icons.flag,
              color: isCompleted ? Colors.green : Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: AppTheme.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  challenge.description,
                  style: AppTheme.bodySmall.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '+${challenge.xpReward} XP',
                      style: AppTheme.bodySmall.copyWith(color: Colors.amber),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isCompleted)
            const Icon(Icons.check_circle, color: Colors.green)
          else
            IconButton(
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              onPressed: () {
                // Challenge completion would be handled by the service
                // when user actually completes the challenge
              },
            ),
        ],
      ),
    );
  }

  // ============== AVATAR TAB ==============

  Widget _buildAvatarTab() {
    final userData = _gamificationService.userData;
    if (userData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final avatar = userData.avatar;
    final stateEmoji = avatar.state == 'tired'
        ? '😴'
        : avatar.state == 'energetic'
            ? '⚡'
            : avatar.state == 'calm'
                ? '🧘'
                : '✨';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Avatar Display
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
            ),
            child: Text(
              stateEmoji,
              style: const TextStyle(fontSize: 80),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your Avatar',
            style: AppTheme.heading2.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'State: ${avatar.state.toUpperCase()}',
            style: AppTheme.bodyLarge.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          // Unlocked Items
          if (avatar.unlockedItems.isNotEmpty) ...[
            Text(
              'Unlocked Items',
              style: AppTheme.heading3.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: avatar.unlockedItems
                  .map((item) => Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getItemEmoji(item),
                          style: const TextStyle(fontSize: 32),
                        ),
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 24),
          // Avatar Evolution Info
          _buildAvatarEvolutionInfo(avatar),
        ],
      ),
    );
  }

  String _getItemEmoji(String itemId) {
    switch (itemId) {
      case 'crown':
        return '👑';
      case 'glasses':
        return '👓';
      case 'hat':
        return '🎩';
      default:
        return '✨';
    }
  }

  Widget _buildAvatarEvolutionInfo(AvatarState avatar) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Avatar Evolution',
            style: AppTheme.heading3.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 12),
          _buildEvolutionStage('Tired', '😴', 0, avatar.state == 'tired'),
          _buildEvolutionStage('Energetic', '⚡', 500, avatar.state == 'energetic'),
          _buildEvolutionStage('Calm', '🧘', 2000, avatar.state == 'calm'),
          _buildEvolutionStage('Confident', '✨', 5000, avatar.state == 'confident'),
        ],
      ),
    );
  }

  Widget _buildEvolutionStage(
      String name, String emoji, int xpRequired, bool isCurrent) {
    final userData = _gamificationService.userData;
    final isUnlocked = userData != null && userData.totalXP >= xpRequired;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTheme.bodyMedium.copyWith(
                    color: isCurrent ? Colors.white : Colors.white70,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Text(
                  '$xpRequired XP',
                  style: AppTheme.bodySmall.copyWith(color: Colors.white60),
                ),
              ],
            ),
          ),
          if (isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accentTeal,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'CURRENT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else if (isUnlocked)
            const Icon(Icons.check, color: Colors.green, size: 20)
          else
            const Icon(Icons.lock, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  // ============== LEADERBOARD TAB ==============

  Widget _buildLeaderboardTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: FirestoreService().getLeaderboard(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No leaderboard data yet',
              style: AppTheme.bodyLarge.copyWith(color: Colors.white70),
            ),
          );
        }

        final leaderboard = snapshot.data!;
        final currentUserId = FirestoreService().currentUserId;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: leaderboard.length,
          itemBuilder: (context, index) {
            final entry = leaderboard[index];
            final isCurrentUser = entry['userId'] == currentUserId;
            final rank = index + 1;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? AppTheme.accentTeal.withOpacity(0.3)
                    : Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCurrentUser
                      ? AppTheme.accentTeal
                      : Colors.white.withOpacity(0.2),
                  width: isCurrentUser ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  // Rank
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: rank <= 3
                          ? Colors.amber.withOpacity(0.3)
                          : Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry['fullName'] ?? 'Anonymous',
                          style: AppTheme.bodyLarge.copyWith(
                            color: Colors.white,
                            fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        Text(
                          'Level ${entry['currentLevel']} • ${entry['totalXP']} XP',
                          style: AppTheme.bodySmall.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  // Streak
                  if (entry['currentStreak'] > 0)
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department,
                            color: Colors.orange, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '${entry['currentStreak']}',
                          style: AppTheme.bodyMedium.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}