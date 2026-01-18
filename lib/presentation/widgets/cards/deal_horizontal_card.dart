import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/models/deal_model.dart';
import '../../../../core/utils/animation_utils.dart';
import '../store_logo.dart';
import 'shared/deal_vote_control.dart';
import 'shared/layout_constants.dart';

// ============================================================================
// DEAL HORIZONTAL CARD - Optimized for list view with animations and voting
// ============================================================================
class DealHorizontalCard extends ConsumerStatefulWidget {
  final DealModel deal;
  final VoidCallback? onTap;
  final int index;

  const DealHorizontalCard({
    super.key,
    required this.deal,
    this.onTap,
    this.index = 0,
  });

  @override
  ConsumerState<DealHorizontalCard> createState() => _DealHorizontalCardState();
}

class _DealHorizontalCardState extends ConsumerState<DealHorizontalCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: AnimDurations.fastest,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _scaleController, curve: AnimCurves.smooth),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _scaleController.forward();
  void _onTapUp(TapUpDetails _) {
    _scaleController.reverse();
    (widget.onTap ??
        () => context.push('/deal/${widget.deal.slug ?? widget.deal.id}'))();
  }

  void _onTapCancel() => _scaleController.reverse();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FadeInWidget(
      delay: StaggeredAnimationController.getDelay(widget.index),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isDark ? Colors.grey.shade800 : kBorderColor,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              child: Padding(
                padding: const EdgeInsets.all(kCardPadding),
                child: SizedBox(
                  height: kCardHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _HorizontalDealImage(deal: widget.deal, isDark: isDark),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _HorizontalDealContent(deal: widget.deal),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HorizontalDealImage extends StatelessWidget {
  final DealModel deal;
  final bool isDark;

  const _HorizontalDealImage({required this.deal, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kImageHorizontalPadding),
      child: SizedBox(
        width: kCardImageSize,
        height: kCardImageSize,
        child: Hero(
          tag: 'deal-image-list-${deal.id}',
          child: Transform.scale(
            scale: kImageScale,
            child: CachedNetworkImage(
              imageUrl: deal.imageUrl,
              fit: BoxFit.contain,
              placeholder: (c, u) => Container(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
              ),
              errorWidget: (c, u, e) => Container(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.grey[400],
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HorizontalDealContent extends StatelessWidget {
  final DealModel deal;

  const _HorizontalDealContent({required this.deal});

  String _formatTimeAgo(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${d.day}/${d.month}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          deal.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            height: 1.2, // Tighter line height
            color: theme.colorScheme.onSurface,
          ),
        ),

        const SizedBox(height: 2),

        // Price row
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '₹${deal.priceCurrent.toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (deal.priceMrp > deal.priceCurrent) ...[
              const SizedBox(width: 6),
              Text(
                '₹${deal.priceMrp.toStringAsFixed(0)}',
                style: const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: kPriceMrp,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 2),

        // Store, Time & Actions (Merged Row)
        Row(
          children: [
            // Store Info
            Expanded(
              child: Row(
                children: [
                  StoreLogo(
                    storeName: deal.storeName,
                    height: 14,
                    textStyle: const TextStyle(
                      color: kStoreGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '•',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _formatTimeAgo(deal.createdAt),
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Actions (Votes + Comment)
            Row(
              children: [
                DealVoteControl(deal: deal, iconSize: 16, fontSize: 12),
                const SizedBox(width: 12),
                Icon(
                  Icons.chat_bubble_outline,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 3),
                Text(
                  '${deal.commentCount ?? 0}',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
