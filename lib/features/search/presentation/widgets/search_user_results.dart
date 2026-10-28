import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/search/presentation/widgets/user_search_tile.dart';

class SearchUserResults extends StatelessWidget {
  final List<Map<String, dynamic>> users;

  const SearchUserResults({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return Center(
        child: Text('No people found', style: AppTextStyles.body2),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: users.length,
      separatorBuilder: (context, index) => Divider(
        color: AppColors.divider,
        height: 1,
        indent: 76,
      ),
      itemBuilder: (context, index) => UserSearchTile(user: users[index]),
    );
  }
}
