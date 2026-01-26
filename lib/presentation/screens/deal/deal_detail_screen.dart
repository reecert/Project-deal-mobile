import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/utils/animation_utils.dart';
import '../../../data/repositories/deal_repository.dart';
import '../../../data/models/deal_model.dart';
import '../../../core/di/providers.dart';
import '../../widgets/shimmer_loading.dart';

import '../../widgets/store_logo.dart';

class DealDetailScreen extends ConsumerStatefulWidget {
  final String slug;

  const DealDetailScreen({super.key, required this.slug});

  @override
  ConsumerState<DealDetailScreen> createState() => _DealDetailScreenState();
}

class _DealDetailScreenState extends ConsumerState<DealDetailScreen> {
  DealModel? _deal;
  bool _isLoading = true;
  bool _isSaved = false;
  bool _isVoting = false;
  bool _detailsExpanded = true;
  int _currentImageIndex = 0;
  int? _userVote;
  int _localUpvotes = 0;
  int _localDownvotes = 0;

  @override
  void initState() {
    super.initState();
    _loadDeal();
  }

  Future<void> _loadDeal() async {
    try {
      final repo = ref.read(dealRepositoryProvider);
      final deal = await repo.getDealBySlug(widget.slug);

      if (deal != null) {
        repo.incrementView(deal.id);

        // Load user's existing vote
        final user = ref.read(currentUserProvider);
        int? existingVote;
        if (user != null) {
          existingVote = await repo.getUserVoteForDeal(deal.id, user.id);
        }

        if (mounted) {
          setState(() {
            _deal = deal;
            _isLoading = false;
            _userVote = existingVote;
            _localUpvotes = deal.upvoteCount;
            _localDownvotes = deal.downvoteCount;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGetDeal() async {
    if (_deal == null) return;
    final uri = Uri.parse(_deal!.dealUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _handleShare() async {
    if (_deal == null) return;
    await Share.share(
      '${_deal!.title}\n\n₹${_deal!.priceCurrent} (${_deal!.discountPercent.round()}% off)\n\n${_deal!.dealUrl}',
      subject: _deal!.title,
    );
  }

  Future<void> _handleSave() async {
    if (_deal == null) return;
    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to save deals')),
      );
      return;
    }
    try {
      final repo = ref.read(dealRepositoryProvider);
      final saved = await repo.toggleSave(_deal!.id, user.id);
      setState(() => _isSaved = saved);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(saved ? 'Deal saved!' : 'Removed from saved')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _handleVote(int newVote) async {
    if (_deal == null || _isVoting) return;

    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please sign in to vote')));
      return;
    }

    final oldVote = _userVote;
    final oldUpvotes = _localUpvotes;
    final oldDownvotes = _localDownvotes;

    setState(() {
      _isVoting = true;

      // If clicking the same vote button, remove the vote
      if (oldVote == newVote) {
        _userVote = null;
        if (newVote == 1) {
          _localUpvotes--;
        } else {
          _localDownvotes--;
        }
      } else {
        // New vote or switching votes
        // First, remove old vote if exists
        if (oldVote == 1) {
          _localUpvotes--;
        } else if (oldVote == -1) {
          _localDownvotes--;
        }

        // Then add new vote
        _userVote = newVote;
        if (newVote == 1) {
          _localUpvotes++;
        } else {
          _localDownvotes++;
        }
      }
    });

    try {
      final repo = ref.read(dealRepositoryProvider);

      if (oldVote == newVote) {
        // User clicked same button - remove vote
        await repo.removeVote(_deal!.id, user.id);
      } else {
        // User voted or changed vote - upsert
        await repo.vote(_deal!.id, user.id, newVote);
      }
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() {
          _userVote = oldVote;
          _localUpvotes = oldUpvotes;
          _localDownvotes = oldDownvotes;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error voting: $e')));
      }
    } finally {
      if (mounted) setState(() => _isVoting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    if (_deal == null) {
      return Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: Text('Deal not found')),
      );
    }

    final deal = _deal!;
    final allImages = [deal.imageUrl, ...deal.galleryUrls];
    final score = _localUpvotes - _localDownvotes;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: CustomScrollView(
        slivers: [
          // Minimal app bar with just back button
          SliverAppBar(
            backgroundColor: isDark ? Colors.black : const Color(0xFFF5F5F7),
            elevation: 0,
            pinned: true,
            expandedHeight: 320,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: isDark
                    ? const Color(0xFF1C1C1E)
                    : const Color(0xFFF5F5F7),
                child: Stack(
                  children: [
                    // Image carousel
                    PageView.builder(
                      itemCount: allImages.length,
                      onPageChanged: (i) =>
                          setState(() => _currentImageIndex = i),
                      itemBuilder: (context, index) {
                        final img = Padding(
                          padding: const EdgeInsets.all(24),
                          child: CachedNetworkImage(
                            imageUrl: allImages[index],
                            fit: BoxFit.contain,
                            placeholder: (_, __) =>
                                const ShimmerLoading(height: 280),
                            errorWidget: (_, __, ___) => Icon(
                              Icons.image_not_supported,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                          ),
                        );
                        return index == 0
                            ? Hero(tag: 'deal-image-${deal.id}', child: img)
                            : img;
                      },
                    ),
                    // Image indicators
                    if (allImages.length > 1)
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            allImages.length,
                            (i) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentImageIndex == i
                                    ? (isDark ? Colors.white : Colors.black54)
                                    : Colors.grey[400],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              color: isDark ? Colors.black : Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category + Time row
                        FadeInWidget(
                          delay: Duration.zero,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.grey[800]
                                      : const Color(0xFFE8E8ED),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Frontpage',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _formatDate(deal.createdAt),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.grey[500]
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Title
                        FadeInWidget(
                          delay: AnimDurations.fastest,
                          child: Text(
                            deal.title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                              letterSpacing: -0.3,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Price row
                        FadeInWidget(
                          delay: AnimDurations.fast,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '₹${deal.priceCurrent.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              if (deal.priceMrp > deal.priceCurrent) ...[
                                const SizedBox(width: 10),
                                Text(
                                  '₹${deal.priceMrp.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${deal.discountPercent.round()}% Off',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFEA580C),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Store + shipping
                        FadeInWidget(
                          delay: AnimDurations.normal,
                          child: Row(
                            children: [
                              StoreLogo(
                                storeName: deal.storeName,
                                height: 16,
                                textStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2563EB),
                                ),
                              ),
                              Text(
                                ' + Free Shipping',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Disclaimer
                        FadeInWidget(
                          delay: AnimDurations.normal,
                          child: Text(
                            'To remain free, we may earn a commission on some deals.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Divider
                  Divider(
                    height: 1,
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                  ),

                  // Action bar
                  FadeInWidget(
                    delay: AnimDurations.slow,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          // Good Deal? voting
                          _ActionButton(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () => _handleVote(1),
                                  child: Icon(
                                    _userVote == 1
                                        ? Icons.thumb_up
                                        : Icons.thumb_up_outlined,
                                    size: 22,
                                    color: _userVote == 1
                                        ? const Color(0xFF2563EB)
                                        : (isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[600]),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$score',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => _handleVote(-1),
                                  child: Icon(
                                    _userVote == -1
                                        ? Icons.thumb_down
                                        : Icons.thumb_down_outlined,
                                    size: 20,
                                    color: _userVote == -1
                                        ? const Color(0xFFEF4444)
                                        : (isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[600]),
                                  ),
                                ),
                              ],
                            ),
                            label: 'Good Deal?',
                            isDark: isDark,
                          ),
                          _ActionButton(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 20,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${deal.commentCount ?? 0}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            label: 'Comments',
                            isDark: isDark,
                          ),
                          _ActionButton(
                            child: Icon(
                              _isSaved
                                  ? Icons.bookmark
                                  : Icons.bookmark_outline,
                              size: 22,
                              color: _isSaved
                                  ? const Color(0xFF2563EB)
                                  : (isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600]),
                            ),
                            label: 'Save',
                            isDark: isDark,
                            onTap: _handleSave,
                          ),
                          _ActionButton(
                            child: Icon(
                              Icons.ios_share,
                              size: 22,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                            label: 'Share',
                            isDark: isDark,
                            onTap: _handleShare,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Divider
                  Divider(
                    height: 1,
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                  ),

                  // Details section
                  FadeInWidget(
                    delay: AnimDurations.slower,
                    child: Theme(
                      data: theme.copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        initiallyExpanded: _detailsExpanded,
                        onExpansionChanged: (v) =>
                            setState(() => _detailsExpanded = v),
                        tilePadding: const EdgeInsets.symmetric(horizontal: 20),
                        title: Text(
                          'Details',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Posted by',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundImage:
                                          deal.authorAvatarUrl.isNotEmpty
                                          ? CachedNetworkImageProvider(
                                              deal.authorAvatarUrl,
                                            )
                                          : null,
                                      backgroundColor: Colors.grey[300],
                                      child: deal.authorAvatarUrl.isEmpty
                                          ? Icon(
                                              Icons.person,
                                              size: 16,
                                              color: Colors.grey[600],
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      deal.authorUsername,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Staff',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '•',
                                      style: TextStyle(color: Colors.grey[500]),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatDate(deal.createdAt),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Floating bottom bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                // Share button
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.ios_share,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    onPressed: _handleShare,
                  ),
                ),
                const SizedBox(width: 12),
                // See Deal button
                Expanded(
                  child: TapScaleWidget(
                    onTap: _handleGetDeal,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Text(
                          'See Deal At ${deal.storeName}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Today ${_timeFormat(date)}';
    if (diff.inDays < 2) return 'Yesterday ${_timeFormat(date)}';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _timeFormat(DateTime date) {
    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${date.minute.toString().padLeft(2, '0')} $ampm';
  }
}

class _ActionButton extends StatelessWidget {
  final Widget child;
  final String label;
  final bool isDark;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.child,
    required this.label,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            child,
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
