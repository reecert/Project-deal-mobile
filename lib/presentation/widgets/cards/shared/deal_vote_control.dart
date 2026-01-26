import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/deal_model.dart';
import '../../../../data/repositories/deal_repository.dart';
import '../../../../core/di/providers.dart';
import 'layout_constants.dart';

class DealVoteControl extends ConsumerStatefulWidget {
  final DealModel deal;
  final double iconSize;
  final double fontSize;

  const DealVoteControl({
    super.key,
    required this.deal,
    this.iconSize = 16,
    this.fontSize = 12,
  });

  @override
  ConsumerState<DealVoteControl> createState() => _DealVoteControlState();
}

class _DealVoteControlState extends ConsumerState<DealVoteControl>
    with WidgetsBindingObserver {
  int? _userVote;
  int _localUpvotes = 0;
  int _localDownvotes = 0;
  bool _isVoting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initVotes();
  }

  void _initVotes() {
    _localUpvotes = widget.deal.upvoteCount;
    _localDownvotes = widget.deal.downvoteCount;
    _loadUserVote();
  }

  @override
  void didUpdateWidget(DealVoteControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.deal.id != widget.deal.id ||
        oldWidget.deal.upvoteCount != widget.deal.upvoteCount ||
        oldWidget.deal.downvoteCount != widget.deal.downvoteCount) {
      _initVotes();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadUserVote();
    }
  }

  Future<void> _loadUserVote() async {
    final user = ref.read(currentUserProvider);
    if (user == null || !mounted) return;

    try {
      final repo = ref.read(dealRepositoryProvider);
      final vote = await repo.getUserVoteForDeal(widget.deal.id, user.id);
      if (mounted) setState(() => _userVote = vote);
    } catch (_) {}
  }

  Future<void> _handleVote(int newVote) async {
    if (_isVoting) return;

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
      if (oldVote == newVote) {
        _userVote = null;
        if (newVote == 1) {
          _localUpvotes--;
        } else {
          _localDownvotes--;
        }
      } else {
        if (oldVote == 1) {
          _localUpvotes--;
        } else if (oldVote == -1) {
          _localDownvotes--;
        }
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
        await repo.removeVote(widget.deal.id, user.id);
      } else {
        await repo.vote(widget.deal.id, user.id, newVote);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userVote = oldVote;
          _localUpvotes = oldUpvotes;
          _localDownvotes = oldDownvotes;
        });
      }
    } finally {
      if (mounted) setState(() => _isVoting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(fontSize: widget.fontSize);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => _handleVote(1),
          child: Icon(
            Icons.thumb_up,
            size: widget.iconSize,
            color: _userVote == 1 ? kUpvoteColor : Colors.grey,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$_localUpvotes',
          style: textStyle.copyWith(
            fontWeight: _userVote == 1 ? FontWeight.w600 : FontWeight.normal,
            color: _userVote == 1 ? kUpvoteColor : Colors.grey,
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => _handleVote(-1),
          child: Icon(
            Icons.thumb_down,
            size: widget.iconSize,
            color: _userVote == -1 ? kDownvoteColor : Colors.grey,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$_localDownvotes',
          style: textStyle.copyWith(
            fontWeight: _userVote == -1 ? FontWeight.w600 : FontWeight.normal,
            color: _userVote == -1 ? kDownvoteColor : Colors.grey,
          ),
        ),
      ],
    );
  }
}
