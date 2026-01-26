import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/deal_model.dart';
import '../../../data/repositories/deal_repository.dart';
import '../../widgets/deal_card.dart';
import '../../widgets/shimmer_loading.dart';
import '../../../core/utils/animation_utils.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  List<DealModel> _deals = [];
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String _selectedCategory = 'For You';
  bool _isGridView = true;

  final List<String> _categories = [
    'For You',
    'Electronics',
    'Fashion',
    'Grocery',
    'Home',
    'Beauty',
    'Books',
    'Sports',
  ];

  @override
  void initState() {
    super.initState();
    _loadLayoutPreference();
    _loadDeals();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadLayoutPreference() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isGridView = prefs.getBool('isGridView') ?? true;
      });
    }
  }

  Future<void> _toggleLayout() async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !_isGridView;
    await prefs.setBool('isGridView', newValue);
    if (mounted) {
      setState(() {
        _isGridView = newValue;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMoreDeals();
    }
  }

  Future<void> _loadDeals() async {
    try {
      final deals = await ref
          .read(dealRepositoryProvider)
          .getFeed(
            category: _selectedCategory == 'For You' ? null : _selectedCategory,
          );
      if (mounted) {
        setState(() {
          _deals = deals;
        });
      }
    } catch (e) {}
  }

  Future<void> _loadMoreDeals() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);

    try {
      final deals = await ref
          .read(dealRepositoryProvider)
          .getFeed(
            offset: _deals.length,
            category: _selectedCategory == 'For You' ? null : _selectedCategory,
          );
      if (mounted) {
        setState(() {
          if (deals.isEmpty) _hasMore = false;
          _deals.addAll(deals);
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _hasMore = true;
      _deals = [];
    });
    await _loadDeals();
  }

  void _onCategorySelected(String category) {
    if (_selectedCategory == category) return;
    setState(() {
      _selectedCategory = category;
      _deals = [];
      _hasMore = true;
    });
    _loadDeals();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with avatar and category chips
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  // User avatar - tappable to open profile
                  GestureDetector(
                    onTap: () => context.go('/profile'),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: theme.colorScheme.primary.withOpacity(
                        0.2,
                      ),
                      child: Icon(
                        Icons.person,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categories.map((category) {
                          final isSelected = _selectedCategory == category;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: AnimatedScale(
                              scale: isSelected ? 1.0 : 0.95,
                              duration: AnimDurations.fast,
                              curve: AnimCurves.smooth,
                              child: ChoiceChip(
                                label: Text(category),
                                selected: isSelected,
                                onSelected: (_) =>
                                    _onCategorySelected(category),
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : theme.colorScheme.onSurface,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  fontSize: 13,
                                ),
                                backgroundColor: theme.cardColor,
                                selectedColor: theme.colorScheme.primary,
                                side: BorderSide.none,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Section header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Deals based on your interests',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.tune, size: 20),
                        onPressed: () {},
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(width: 8),
                      // Layout toggle button
                      IconButton(
                        icon: Icon(
                          _isGridView ? Icons.view_list : Icons.grid_view,
                          size: 22,
                          color: theme.colorScheme.onSurface,
                        ),
                        onPressed: _toggleLayout,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Deals grid (2 per row)
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: _deals.isEmpty
                    ? _buildLoadingGrid()
                    : _isGridView
                    ? GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(4),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 0,
                              crossAxisSpacing: 0,
                              childAspectRatio: 0.65,
                            ),
                        itemCount: _deals.length + (_isLoadingMore ? 2 : 0),
                        itemBuilder: (context, index) {
                          if (index >= _deals.length) {
                            return const DealCardSkeleton();
                          }
                          return DealGridCard(
                            deal: _deals[index],
                            index: index,
                          );
                        },
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _deals.length + (_isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= _deals.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          return DealHorizontalCard(
                            deal: _deals[index],
                            index: index,
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.55,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => const DealCardSkeleton(),
    );
  }
}
