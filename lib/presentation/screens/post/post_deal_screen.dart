import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PostDealScreen extends ConsumerStatefulWidget {
  const PostDealScreen({super.key});

  @override
  ConsumerState<PostDealScreen> createState() => _PostDealScreenState();
}

class _PostDealScreenState extends ConsumerState<PostDealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _mrpController = TextEditingController();
  final _storeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dealUrlController = TextEditingController();

  String? _selectedCategory;

  bool _isFetching = false;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Electronics',
    'Fashion',
    'Home & Kitchen',
    'Beauty',
    'Sports',
    'Books',
    'Grocery',
    'Toys',
    'Other',
  ];

  // User's color palette
  static const Color _primary = Color(0xFF1D4ED8);

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    _priceController.dispose();
    _mrpController.dispose();
    _storeController.dispose();
    _descriptionController.dispose();
    _dealUrlController.dispose();
    super.dispose();
  }

  Future<void> _fetchDealFromUrl() async {
    if (_urlController.text.isEmpty) return;

    setState(() => _isFetching = true);

    try {
      // TODO: Call scraper API to auto-fetch deal details
      // For now, simulate with a delay
      await Future.delayed(const Duration(seconds: 1));

      // Placeholder - in real implementation, this would populate from scraper
      setState(() {
        _dealUrlController.text = _urlController.text;
        // Other fields would be auto-filled from scraper response
      });
    } finally {
      setState(() => _isFetching = false);
    }
  }

  Future<void> _submitDeal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // TODO: Submit deal to Supabase
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deal posted successfully!')),
        );
        context.go('/');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a New Deal'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtitle
              Text(
                'Found something awesome? Share it with the community and help others save money.',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Section 1: Deal Source & Images
              _buildSectionCard(
                number: '1',
                title: 'Deal Source & Images',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Paste Deal URL
                    Row(
                      children: [
                        Icon(
                          Icons.link,
                          size: 18,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Paste Deal URL',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _urlController,
                            decoration: InputDecoration(
                              hintText: 'https://www.amazon.com/dp/...',
                              hintStyle: TextStyle(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.url,
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.icon(
                          onPressed: _isFetching ? null : _fetchDealFromUrl,
                          icon: _isFetching
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.arrow_forward, size: 18),
                          label: const Text('Fetch Deal'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Auto-fetches title, price, and HD images.',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Image upload area
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.2,
                          ),
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 48,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Enter a URL above to scrape images, or upload manually.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              // TODO: Image picker
                            },
                            child: const Text('Click to upload from device'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Section 2: Description
              _buildSectionCard(
                number: '2',
                title: 'Description',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Why is this a good deal?',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        hintText:
                            'Tell us about the features, the discount, or why you recommend this...',
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ),
                      maxLines: 5,
                      minLines: 4,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Markdown is supported. Keep it helpful and concise.',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Section 3: Deal Details
              _buildSectionCard(
                number: '3',
                title: 'Deal Details',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    const Text(
                      'Title',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Product Name',
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Price and MRP
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Price',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _priceController,
                                decoration: InputDecoration(
                                  hintText: '₹ 0.00',
                                  hintStyle: TextStyle(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.4),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'MRP',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _mrpController,
                                decoration: InputDecoration(
                                  hintText: '₹ 0.00',
                                  hintStyle: TextStyle(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.4),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Store
                    const Text(
                      'Store',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _storeController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Amazon',
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Category
                    const Text(
                      'Category',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      hint: const Text('Select Category'),
                      decoration: const InputDecoration(),
                      items: _categories.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedCategory = value);
                      },
                    ),

                    const SizedBox(height: 16),

                    // Deal URL
                    const Text(
                      'Deal URL',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _dealUrlController,
                      decoration: InputDecoration(
                        hintText: 'https://...',
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.url,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the deal URL';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Publish button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: _isSubmitting ? null : _submitDeal,
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Publish Deal',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'By posting, you agree to our community guidelines.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String number,
    required String title,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      number,
                      style: TextStyle(
                        color: _primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}
