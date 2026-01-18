import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/models/deal_model.dart';
import '../../../../core/utils/animation_utils.dart';
import '../shimmer_loading.dart';
import '../store_logo.dart';
import 'shared/layout_constants.dart';

// ============================================================================
// FULL DEALCARD - Used for detail views and single-column lists
// ============================================================================
class DealCard extends StatefulWidget {
  final DealModel deal;
  final VoidCallback? onTap;
  final VoidCallback? onShare;

  const DealCard({super.key, required this.deal, this.onTap, this.onShare});

  @override
  State<DealCard> createState() => _DealCardState();
}

class _DealCardState extends State<DealCard>
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
    final deal = widget.deal;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.amber.shade100,
                      backgroundImage: deal.authorAvatarUrl.isNotEmpty
                          ? CachedNetworkImageProvider(deal.authorAvatarUrl)
                          : null,
                      child: deal.authorAvatarUrl.isEmpty
                          ? Icon(
                              Icons.lightbulb,
                              color: Colors.amber.shade700,
                              size: 20,
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface,
                              ),
                              children: [
                                const TextSpan(text: 'Found by '),
                                TextSpan(
                                  text: deal.authorUsername,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _formatDate(deal.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.remove_red_eye_outlined,
                      size: 16,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${deal.views ?? 0}',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Hero image
                Hero(
                  tag: 'deal-image-${deal.id}',
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: CachedNetworkImage(
                        imageUrl: deal.imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (c, u) =>
                            const ShimmerLoading(height: 200),
                        errorWidget: (c, u, e) => Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  deal.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      '₹${deal.priceCurrent.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (deal.priceMrp > deal.priceCurrent)
                      Text(
                        '₹${deal.priceMrp.toStringAsFixed(0)}',
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: kPriceMrp,
                          fontSize: 16,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                StoreLogo(
                  storeName: deal.storeName,
                  height: 16,
                  textStyle: const TextStyle(color: kStoreGreen, fontSize: 14),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.thumb_up,
                      size: 20,
                      color: Color(0xFFF97316),
                    ),
                    const SizedBox(width: 4),
                    Text('${deal.upvoteCount}'),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.thumb_down_outlined,
                      size: 20,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text('${deal.downvoteCount}'),
                    const SizedBox(width: 24),
                    const Icon(
                      Icons.chat_bubble_outline,
                      size: 20,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text('${deal.commentCount ?? 0}'),
                    const Spacer(),
                    IconButton(
                      onPressed: widget.onShare,
                      icon: const Icon(
                        Icons.share_outlined,
                        color: Colors.grey,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
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
    final hour = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
    return '${months[d.month - 1]} ${d.day}, $hour:${d.minute.toString().padLeft(2, '0')} ${d.hour >= 12 ? 'PM' : 'AM'}';
  }
}
