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
// DEAL GRID CARD - Optimized for 2-column grid with animations and voting
// ============================================================================
class DealGridCard extends ConsumerStatefulWidget {
  final DealModel deal;
  final VoidCallback? onTap;
  final int index;

  const DealGridCard({
    super.key,
    required this.deal,
    this.onTap,
    this.index = 0,
  });

  @override
  ConsumerState<DealGridCard> createState() => _DealGridCardState();
}

class _DealGridCardState extends ConsumerState<DealGridCard>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
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

    return FadeInWidget(
      delay: StaggeredAnimationController.getDelay(widget.index),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isDark ? Colors.grey.shade800 : kBorderColor,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero image - square aspect ratio
                  AspectRatio(
                    aspectRatio: 1,
                    child: Hero(
                      tag: 'deal-image-${deal.id}',
                      child: Container(
                        color: isDark ? Colors.grey[850] : Colors.white,
                        child: CachedNetworkImage(
                          imageUrl: deal.imageUrl,
                          width: double.infinity,
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

                  const SizedBox(height: 8),

                  // Content section - expands to fill remaining space
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Title
                        Text(
                          deal.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            height: 1.3,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),

                        // Price + Store + Actions
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Price row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '₹${deal.priceCurrent.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
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
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ],
                            ),

                            const SizedBox(height: 4),

                            // Store name
                            StoreLogo(
                              storeName: deal.storeName,
                              height: 12,
                              textStyle: const TextStyle(
                                color: kStoreGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 6),

                            // Action row with voting
                            Row(
                              children: [
                                DealVoteControl(
                                  deal: deal,
                                  iconSize: 16,
                                  fontSize: 11,
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.chat_bubble,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${deal.commentCount ?? 0}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
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
        ),
      ),
    );
  }
}
