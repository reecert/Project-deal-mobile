import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/supabase_config.dart';
import '../models/deal_model.dart';

class DealRepository {
  /// Fetch feed with pagination
  Future<List<DealModel>> getFeed({
    int limit = 20,
    int offset = 0,
    String? category,
  }) async {
    var query = supabase
        .from('deals')
        .select('*, profiles(id, username, avatar_url)')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    final response = await query;
    return (response as List).map((json) => DealModel.fromJson(json)).toList();
  }

  /// Search deals
  Future<List<DealModel>> searchDeals({
    required String query,
    String? category,
    int limit = 20,
    int offset = 0,
  }) async {
    var dbQuery = supabase
        .from('deals')
        .select('*, profiles(id, username, avatar_url)')
        .ilike('title', '%$query%')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    final response = await dbQuery;
    return (response as List).map((json) => DealModel.fromJson(json)).toList();
  }

  /// Get deal by slug or ID
  Future<DealModel?> getDealBySlug(String slug) async {
    // Try slug first
    var response = await supabase
        .from('deals')
        .select('*, profiles(id, username, avatar_url)')
        .eq('slug', slug)
        .maybeSingle();

    // If not found by slug, try by ID
    if (response == null) {
      response = await supabase
          .from('deals')
          .select('*, profiles(id, username, avatar_url)')
          .eq('id', slug)
          .maybeSingle();
    }

    if (response == null) return null;
    return DealModel.fromJson(response);
  }

  /// Get user's saved deals
  Future<List<DealModel>> getSavedDeals(String userId) async {
    final response = await supabase
        .from('saved_deals')
        .select('deals(*, profiles(id, username, avatar_url))')
        .eq('user_id', userId);

    return (response as List)
        .map((item) => DealModel.fromJson(item['deals']))
        .toList();
  }

  /// Save/unsave a deal
  Future<bool> toggleSave(String dealId, String userId) async {
    // Check if already saved
    final existing = await supabase
        .from('saved_deals')
        .select()
        .eq('deal_id', dealId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null) {
      // Remove save
      await supabase
          .from('saved_deals')
          .delete()
          .eq('deal_id', dealId)
          .eq('user_id', userId);
      return false;
    } else {
      // Add save
      await supabase.from('saved_deals').insert({
        'deal_id': dealId,
        'user_id': userId,
      });
      return true;
    }
  }

  /// Get user votes for deals
  Future<Map<String, int>> getUserVotes(
    String userId,
    List<String> dealIds,
  ) async {
    if (dealIds.isEmpty) return {};

    final response = await supabase
        .from('votes')
        .select('deal_id, vote_type')
        .eq('user_id', userId)
        .inFilter('deal_id', dealIds);

    final Map<String, int> votes = {};
    for (final vote in response) {
      votes[vote['deal_id']] = vote['vote_type'];
    }
    return votes;
  }

  /// Vote on a deal (1 = upvote, -1 = downvote)
  Future<void> vote(String dealId, String userId, int voteType) async {
    await supabase.from('votes').upsert({
      'deal_id': dealId,
      'user_id': userId,
      'vote_type': voteType,
    }, onConflict: 'user_id,deal_id');

    // Update deal vote counts
    await _updateDealVoteCounts(dealId);
  }

  /// Remove a vote
  Future<void> removeVote(String dealId, String userId) async {
    await supabase
        .from('votes')
        .delete()
        .eq('deal_id', dealId)
        .eq('user_id', userId);

    // Update deal vote counts
    await _updateDealVoteCounts(dealId);
  }

  /// Get user's vote for a specific deal
  Future<int?> getUserVoteForDeal(String dealId, String userId) async {
    final response = await supabase
        .from('votes')
        .select('vote_type')
        .eq('deal_id', dealId)
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;
    return response['vote_type'] as int;
  }

  /// Update deal vote counts (recalculate from votes table)
  Future<void> _updateDealVoteCounts(String dealId) async {
    try {
      // Get upvote count
      final upvotes = await supabase
          .from('votes')
          .select()
          .eq('deal_id', dealId)
          .eq('vote_type', 1);

      // Get downvote count
      final downvotes = await supabase
          .from('votes')
          .select()
          .eq('deal_id', dealId)
          .eq('vote_type', -1);

      // Update deal
      await supabase
          .from('deals')
          .update({
            'upvote_count': (upvotes as List).length,
            'downvote_count': (downvotes as List).length,
          })
          .eq('id', dealId);
    } catch (e) {
      // Silently fail - counts might be handled by database triggers
    }
  }

  /// Increment view count
  Future<void> incrementView(String dealId) async {
    try {
      await supabase.rpc('increment_view', params: {'row_id': dealId});
    } catch (e) {
      // RPC might not exist, ignore silently
    }
  }
}

/// Riverpod provider
final dealRepositoryProvider = Provider<DealRepository>((ref) {
  return DealRepository();
});
