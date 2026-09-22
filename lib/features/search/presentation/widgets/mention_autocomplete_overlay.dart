import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/core/utils/mention_helper.dart';
import 'package:connecthub/features/search/data/repos/search_repo.dart';
import 'package:connecthub/features/search/data/repos/search_repo_imp.dart';

class MentionAutocompleteOverlay extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final Widget child;
  final bool showAbove;
  final SearchRepo? searchRepo;

  const MentionAutocompleteOverlay({
    super.key,
    required this.controller,
    required this.child,
    this.focusNode,
    this.showAbove = true,
    this.searchRepo,
  });

  @override
  State<MentionAutocompleteOverlay> createState() =>
      _MentionAutocompleteOverlayState();
}

class _MentionAutocompleteOverlayState
    extends State<MentionAutocompleteOverlay> {
  late final SearchRepo _searchRepo;
  Timer? _debounceTimer;
  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoading = false;
  String? _activeQuery;

  @override
  void initState() {
    super.initState();
    _searchRepo = widget.searchRepo ?? SearchRepoImp();
    widget.controller.addListener(_onTextChanged);
    widget.focusNode?.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    widget.controller.removeListener(_onTextChanged);
    widget.focusNode?.removeListener(_onFocusChanged);
    super.dispose();
  }

  void _onFocusChanged() {
    if (widget.focusNode != null && !widget.focusNode!.hasFocus) {
      _hideSuggestions();
    }
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    final selection = widget.controller.selection;

    if (!selection.isValid || !selection.isCollapsed) {
      _hideSuggestions();
      return;
    }

    final query = MentionHelper.extractActiveMentionQuery(text, selection.baseOffset);

    if (query == null) {
      _hideSuggestions();
      return;
    }

    if (query == _activeQuery && _suggestions.isNotEmpty) {
      return;
    }

    _activeQuery = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final results = await _searchRepo.searchUsers(query);
      if (!mounted) return;

      // Cache all results in MentionHelper
      for (final user in results) {
        MentionHelper.cacheUser(user);
      }

      setState(() {
        _suggestions = results.take(8).toList();
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isLoading = false;
        });
      }
    }
  }

  void _hideSuggestions() {
    _debounceTimer?.cancel();
    if (_suggestions.isNotEmpty || _isLoading || _activeQuery != null) {
      setState(() {
        _suggestions = [];
        _isLoading = false;
        _activeQuery = null;
      });
    }
  }

  void _insertMention(Map<String, dynamic> user) {
    final rawUsername = (user['username'] as String? ?? '').replaceAll('@', '').trim();
    final displayName = (user['name'] as String? ?? '').trim();
    final usernameToInsert = rawUsername.isNotEmpty ? rawUsername : displayName.replaceAll(' ', '_');

    final text = widget.controller.text;
    final selection = widget.controller.selection;
    final cursor = selection.baseOffset;

    final textBeforeCursor = text.substring(0, cursor);
    final textAfterCursor = text.substring(cursor);

    // Find where the active @ starts before cursor
    final atIndex = textBeforeCursor.lastIndexOf('@');
    if (atIndex == -1) return;

    final prefix = text.substring(0, atIndex);
    final insertedText = '@$usernameToInsert ';
    final newText = '$prefix$insertedText$textAfterCursor';

    final newCursorOffset = prefix.length + insertedText.length;

    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorOffset),
    );

    _hideSuggestions();
  }

  @override
  Widget build(BuildContext context) {
    final shouldShow = _suggestions.isNotEmpty || _isLoading;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showAbove && shouldShow) _buildSuggestionsCard(),
        widget.child,
        if (!widget.showAbove && shouldShow) _buildSuggestionsCard(),
      ],
    );
  }

  Widget _buildSuggestionsCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8, top: 8),
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.divider,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: _isLoading && _suggestions.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: _suggestions.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, color: AppColors.divider),
                itemBuilder: (context, index) {
                  final user = _suggestions[index];
                  final name = user['name'] as String? ?? 'User';
                  final username = user['username'] as String? ?? '';
                  final profileImage = user['profileImage'] as String?;
                  final bio = user['bio'] as String? ?? '';

                  return InkWell(
                    onTap: () => _insertMention(user),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          UserAvatar(
                            name: name,
                            size: 38,
                            imageUrl: profileImage,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        name,
                                        style: AppTextStyles.body2.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (username.isNotEmpty) ...[
                                      const SizedBox(width: 6),
                                      Text(
                                        '@$username',
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                if (bio.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    bio,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textHint,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.north_west_rounded,
                            size: 16,
                            color: AppColors.textHint,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
