import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/post/presentation/bloc/post_compose_bloc.dart';
import 'package:faithconnect/features/post/presentation/bloc/post_compose_event.dart';
import 'package:faithconnect/features/post/presentation/bloc/post_compose_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PostComposeSettings extends StatelessWidget {
  final bool showNotifyCommunity;

  const PostComposeSettings({
    super.key,
    this.showNotifyCommunity = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostComposeBloc, PostComposeState>(
      buildWhen: (previous, current) => current is PostComposeEditing,
      builder: (context, state) {
        final draft = switch (state) {
          PostComposeEditing(:final draft) => draft,
          PostComposeFailure(:final draft) => draft,
          _ => null,
        };
        if (draft == null) return const SizedBox.shrink();

        return Column(
          children: [
            AppSettingsSwitchTile(
              title: 'Allow Comments',
              subtitle: 'Let people share their reflections',
              value: draft.allowComments,
              onChanged: (_) => context.read<PostComposeBloc>().add(
                    const PostComposeAllowCommentsToggled(),
                  ),
            ),
            if (showNotifyCommunity)
              AppSettingsSwitchTile(
                title: 'Notify Community',
                subtitle: 'Push notification to your followers',
                value: draft.notifyCommunity,
                onChanged: (_) => context.read<PostComposeBloc>().add(
                      const PostComposeNotifyCommunityToggled(),
                    ),
              ),
            SizedBox(height: 8.h),
          ],
        );
      },
    );
  }
}
