import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/post/data/repos/post_repo.dart';
import 'package:connecthub/features/post/data/repos/post_repo_imp.dart';

class LikedBySheet extends StatelessWidget {
  final List<String> userIds;
  final PostRepo postRepo;

  LikedBySheet({
    super.key,
    required this.userIds,
    PostRepo? postRepo,
  }) : postRepo = postRepo ?? PostRepoImp();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text('Liked By', style: AppTextStyles.headline3),
          const SizedBox(height: 4),
          Text('${userIds.length} people', style: AppTextStyles.caption),
          const SizedBox(height: 16),
          if (userIds.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text('No likes yet.', style: AppTextStyles.body2),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: userIds.length,
                itemBuilder: (context, index) {
                  return FutureBuilder<DocumentSnapshot>(
                    future: postRepo.getUser(userIds[index]),
                    builder: (context, snap) {
                      final name = snap.data?.exists == true
                          ? (snap.data!.data()
                                  as Map<String, dynamic>)['name'] ??
                              'User'
                          : 'User';
                      final email = snap.data?.exists == true
                          ? (snap.data!.data()
                                  as Map<String, dynamic>)['email'] ??
                              ''
                          : '';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            UserAvatar(name: name.toString(), size: 42),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name.toString(),
                                    style: AppTextStyles.body1.copyWith(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  if (email.toString().isNotEmpty)
                                    Text(email.toString(),
                                        style: AppTextStyles.caption),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
