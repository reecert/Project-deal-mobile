import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/repositories/auth_repository.dart';

import '../../../data/models/deal_model.dart';
import '../../widgets/deal_card.dart';

// ============================================================================
// PROFILE SCREEN - Clean mobile layout with tabs
// ============================================================================
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  // Stats
  int _reputation = 0;
  int _profileViews = 0;
  final int _dealViews = 0;
  int _dealsPosted = 0;
  int _comments = 0;
  int _votesGiven = 0;

  // Data
  List<Map<String, dynamic>> _activities = [];
  List<DealModel> _myDeals = [];
  List<DealModel> _savedDeals = [];

  String _activityFilter = 'All My Activity';
  final List<String> _activityFilters = [
    'All My Activity',
    'Reputation Points',
    'Replies',
    'Votes',
    'New Threads',
  ];

  static const Color _primary = Color(0xFF2563EB);
  static const Color _storeGreen = Color(0xFF16A34A);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    // Use Supabase directly for more reliable user fetch
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      debugPrint('ProfileScreen: No user found - not authenticated');
      setState(() => _isLoading = false);
      return;
    }

    debugPrint('ProfileScreen: Loading profile for user ${user.id}');
    setState(() => _isLoading = true);

    try {
      // 1. Fetch Profile
      final profileData = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      debugPrint('ProfileScreen: Profile data = $profileData');

      // 2. Fetch Stats via counts - use count query pattern
      // Note: votes table uses composite key (user_id, deal_id), not 'id'
      List<dynamic> dealsData = [];
      List<dynamic> votesData = [];
      List<dynamic> commentsData = [];

      try {
        dealsData =
            await supabase
                    .from('deals')
                    .select('user_id')
                    .eq('user_id', user.id)
                as List;
      } catch (e) {
        debugPrint('ProfileScreen: Error fetching deals: $e');
      }

      try {
        votesData =
            await supabase
                    .from('votes')
                    .select('deal_id')
                    .eq('user_id', user.id)
                as List;
      } catch (e) {
        debugPrint('ProfileScreen: Error fetching votes: $e');
      }

      try {
        commentsData =
            await supabase
                    .from('comments')
                    .select('user_id')
                    .eq('user_id', user.id)
                as List;
      } catch (e) {
        debugPrint('ProfileScreen: Error fetching comments: $e');
      }

      debugPrint(
        'ProfileScreen: Deals=${dealsData.length}, Votes=${votesData.length}, Comments=${commentsData.length}',
      );

      // 3. Fetch My Deals
      final myDealsData = await supabase
          .from('deals')
          .select('*, profiles(*)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(20);

      // 4. Fetch Saved Deals
      final savedData = await supabase
          .from('saved_deals')
          .select('deal_id, deals(*, profiles(*))')
          .eq('user_id', user.id)
          .limit(20);

      // 5. Fetch Activity - Votes with deal titles
      final votesActivity = await supabase
          .from('votes')
          .select('*, deals(title)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(10);

      debugPrint(
        'ProfileScreen: VotesActivity=${(votesActivity as List).length}',
      );

      // 6. Fetch Reputation Log
      List<Map<String, dynamic>> reputationLog = [];
      try {
        final repData = await supabase
            .from('reputation_log')
            .select('*')
            .eq('user_id', user.id)
            .order('created_at', ascending: false)
            .limit(10);
        reputationLog = (repData as List).cast<Map<String, dynamic>>();
        debugPrint('ProfileScreen: ReputationLog=${reputationLog.length}');
      } catch (e) {
        debugPrint('ProfileScreen: reputation_log table error: $e');
      }

      // Combine activities
      List<Map<String, dynamic>> allActivities = [];

      // Add votes as activities
      for (final v in votesActivity) {
        allActivities.add({
          'id': 'vote-${v['deal_id']}-${v['created_at']}',
          'type': 'vote',
          'title': v['deals']?['title'] ?? 'Unknown Deal',
          'vote_value': v['vote_value'] ?? 1,
          'deal_id': v['deal_id'],
          'created_at': v['created_at'],
        });
      }

      // Add reputation as activities
      for (final r in reputationLog) {
        allActivities.add({
          'id': 'rep-${r['id']}',
          'type': 'reputation',
          'title': r['action_type'] ?? 'Reputation Earned',
          'points': r['points_change'] ?? 0,
          'deal_id': r['target_id'],
          'created_at': r['created_at'],
        });
      }

      // Sort by created_at descending
      allActivities.sort((a, b) {
        final aDate =
            DateTime.tryParse(a['created_at'] ?? '') ?? DateTime.now();
        final bDate =
            DateTime.tryParse(b['created_at'] ?? '') ?? DateTime.now();
        return bDate.compareTo(aDate);
      });

      if (mounted) {
        setState(() {
          _profile = profileData;
          _reputation = profileData?['points'] ?? 0;
          _profileViews = profileData?['profile_views'] ?? 0;
          _dealsPosted = dealsData.length;
          _votesGiven = votesData.length;
          _comments = commentsData.length;
          _myDeals = (myDealsData as List)
              .map((d) => DealModel.fromJson(d))
              .toList();
          _savedDeals = (savedData as List)
              .where((s) => s['deals'] != null)
              .map((s) => DealModel.fromJson(s['deals']))
              .toList();
          _activities = allActivities;
          _isLoading = false;
        });
        debugPrint(
          'ProfileScreen: Loaded successfully - reputation=$_reputation, activities=${_activities.length}',
        );
      }
    } catch (e, stack) {
      debugPrint('ProfileScreen: Error loading profile: $e');
      debugPrint('ProfileScreen: Stack trace: $stack');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getRankName(int points) {
    if (points >= 1000) return 'Legend';
    if (points >= 500) return 'Expert';
    if (points >= 200) return 'Hunter';
    if (points >= 100) return 'Scout';
    if (points >= 50) return 'Explorer';
    return 'Scavenger';
  }

  int _getNextRankPoints(int points) {
    if (points >= 1000) return 1000;
    if (points >= 500) return 1000;
    if (points >= 200) return 500;
    if (points >= 100) return 200;
    if (points >= 50) return 100;
    return 50;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Profile'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: _primary,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
          indicatorColor: _primary,
          indicatorWeight: 2,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 13,
          ),
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'My Profile'),
            Tab(text: 'My Deals'),
            Tab(text: 'Saved Items'),
            Tab(text: 'Inbox'),
            Tab(text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyProfileTab(theme, isDark),
          _buildMyDealsTab(theme),
          _buildSavedItemsTab(theme),
          _buildInboxTab(theme),
          _buildSettingsTab(theme, isDark),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 1: MY PROFILE - Clean vertical layout
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildMyProfileTab(ThemeData theme, bool isDark) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    // Use Supabase directly for reliable auth data
    final user = Supabase.instance.client.auth.currentUser;
    final username =
        _profile?['username'] ??
        _profile?['full_name'] ??
        user?.email?.split('@').first ??
        'User';
    final avatarUrl = _profile?['avatar_url'];
    final createdAt = _profile?['created_at'] ?? user?.createdAt;
    final rankName = _getRankName(_reputation);
    final nextRank = _getNextRankPoints(_reputation);
    final progress = _reputation / nextRank;

    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─────────────────────────────────────────────────────────
            // PROFILE HEADER CARD
            // ─────────────────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    // Avatar + Name row
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                          backgroundImage: avatarUrl != null
                              ? NetworkImage(avatarUrl)
                              : null,
                          child: avatarUrl == null
                              ? Icon(
                                  Icons.person,
                                  size: 36,
                                  color: Colors.grey.shade400,
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.military_tech,
                                    size: 14,
                                    color: _storeGreen,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      rankName,
                                      style: TextStyle(
                                        color: _storeGreen,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 12,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      _formatJoinDate(createdAt),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.5),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Progress bar
                    Row(
                      children: [
                        Text(
                          'Next Rank: ',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        Text(
                          _getRankName(nextRank),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$_reputation/$nextRank pts',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                      color: _primary,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),

                    const SizedBox(height: 16),

                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildActionIcon(Icons.mail_outline, 'Message', theme),
                        const SizedBox(width: 16),
                        _buildActionIcon(
                          Icons.visibility_outlined,
                          'Views',
                          theme,
                        ),
                        const SizedBox(width: 16),
                        _buildActionIcon(
                          Icons.settings_outlined,
                          'Settings',
                          theme,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ─────────────────────────────────────────────────────────
            // STATS GRID - 2x3 layout
            // ─────────────────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildStatTile(
                          'REPUTATION',
                          _reputation,
                          Colors.red,
                          theme,
                        ),
                        _buildStatTile(
                          'PROFILE VIEWS',
                          _profileViews,
                          _primary,
                          theme,
                        ),
                        _buildStatTile(
                          'DEAL VIEWS',
                          _dealViews,
                          Colors.amber,
                          theme,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildStatTile(
                          'DEALS POSTED',
                          _dealsPosted,
                          _storeGreen,
                          theme,
                        ),
                        _buildStatTile('COMMENTS', _comments, _primary, theme),
                        _buildStatTile(
                          'VOTES GIVEN',
                          _votesGiven,
                          Colors.amber,
                          theme,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ─────────────────────────────────────────────────────────
            // CTA CARD
            // ─────────────────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'Ready to help the community and post your first deal?!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.push('/post'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                      ),
                      child: const Text('Post A Deal'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ─────────────────────────────────────────────────────────
            // MY ACTIVITY
            // ─────────────────────────────────────────────────────────
            const Text(
              'My Activity',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),

            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _activityFilters.map((filter) {
                  final isSelected = _activityFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (_) =>
                          setState(() => _activityFilter = filter),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                      ),
                      backgroundColor: theme.cardColor,
                      selectedColor: _primary,
                      side: BorderSide(
                        color: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Activity list
            if (_activities.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No activity yet',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else
              ..._activities
                  .take(10)
                  .map((a) => _buildActivityItem(a, theme, isDark)),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, String label, ThemeData theme) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, int value, Color color, ThemeData theme) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    Map<String, dynamic> activity,
    ThemeData theme,
    bool isDark,
  ) {
    final type = activity['type'] ?? 'vote';
    final title = activity['title'] ?? 'Unknown';
    final voteValue = activity['vote_value'] ?? 1;
    final points = activity['points'] ?? 0;
    final createdAt = DateTime.tryParse(activity['created_at'] ?? '');

    String actionText;
    IconData icon;

    if (type == 'reputation') {
      actionText = 'earned reputation';
      icon = Icons.star;
    } else {
      actionText = voteValue > 0 ? 'thumbed up' : 'thumbed down';
      icon = voteValue > 0 ? Icons.thumb_up : Icons.thumb_down;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: type == 'reputation'
                      ? [Colors.amber.shade400, Colors.orange.shade500]
                      : voteValue > 0
                      ? [const Color(0xFF60A5FA), const Color(0xFF2563EB)]
                      : [Colors.grey.shade400, Colors.grey.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'You ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: actionText),
                      ],
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (type == 'reputation' && points != 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '+$points Points',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (createdAt != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatActivityDate(createdAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatJoinDate(String? dateStr) {
    if (dateStr == null) return 'Recently';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return 'Recently';
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatActivityDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    return '${months[date.month - 1]} ${date.day}, $hour:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 2: MY DEALS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildMyDealsTab(ThemeData theme) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_myDeals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No deals posted yet',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.push('/post'),
              child: const Text('Post Your First Deal'),
            ),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
        childAspectRatio: 0.6,
      ),
      itemCount: _myDeals.length,
      itemBuilder: (context, index) => DealGridCard(deal: _myDeals[index]),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 3: SAVED ITEMS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSavedItemsTab(ThemeData theme) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_savedDeals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No saved deals yet',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Save deals to find them easily later',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(6),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 3,
        crossAxisSpacing: 3,
        childAspectRatio: 0.6,
      ),
      itemCount: _savedDeals.length,
      itemBuilder: (context, index) => DealGridCard(deal: _savedDeals[index]),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 4: INBOX
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildInboxTab(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 5: SETTINGS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSettingsTab(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSettingsSection('Account', [
            _buildSettingsTile(
              Icons.person_outline,
              'Edit Profile',
              'Update your username and avatar',
              () {},
            ),
            _buildSettingsTile(
              Icons.email_outlined,
              'Change Email',
              'Update your email address',
              () {},
            ),
            _buildSettingsTile(
              Icons.lock_outline,
              'Change Password',
              'Update your password',
              () {},
            ),
          ], isDark),
          const SizedBox(height: 24),
          _buildSettingsSection('Notifications', [
            _buildSettingsTile(
              Icons.notifications_outlined,
              'Push Notifications',
              'Manage notification preferences',
              () => context.push('/settings/notifications'),
            ),
            _buildSettingsTile(
              Icons.email_outlined,
              'Email Preferences',
              'Choose what emails you receive',
              () {},
            ),
          ], isDark),
          const SizedBox(height: 24),
          _buildSettingsSection('Preferences', [
            _buildSettingsTile(
              Icons.palette_outlined,
              'Theme',
              isDark ? 'Dark' : 'Light',
              () {},
            ),
            _buildSettingsTile(Icons.language, 'Language', 'English', () {}),
            _buildSettingsTile(Icons.attach_money, 'Currency', '₹ INR', () {}),
          ], isDark),
          const SizedBox(height: 24),
          _buildSettingsSection('Support', [
            _buildSettingsTile(
              Icons.help_outline,
              'Help Center',
              'Get help and support',
              () {},
            ),
            _buildSettingsTile(
              Icons.article_outlined,
              'Terms of Service',
              'Read our terms',
              () {},
            ),
            _buildSettingsTile(
              Icons.privacy_tip_outlined,
              'Privacy Policy',
              'Read our privacy policy',
              () {},
            ),
          ], isDark),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final authRepo = ref.read(authRepositoryProvider);
                await authRepo.signOut();
                if (mounted) context.go('/login');
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'GetOnDeals v1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> tiles, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: tiles.asMap().entries.map((entry) {
              final isLast = entry.key == tiles.length - 1;
              return Column(
                children: [
                  entry.value,
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 56,
                      color: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
