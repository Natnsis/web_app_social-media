import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/scripture/domain/entities/new_post_type.dart'
    show NewPostType, NewPostTypeX;
import 'package:faithconnect/features/scripture/presentation/bloc/new_post_bloc.dart';
import 'package:faithconnect/features/scripture/presentation/bloc/new_post_event.dart';
import 'package:faithconnect/features/scripture/presentation/bloc/new_post_state.dart';
import 'package:faithconnect/features/scripture/presentation/widgets/scripture_post_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Scripture hub compose: scripture verse, media attachment, or event placeholder.
class ScriptureNewPostPage extends StatefulWidget {
  const ScriptureNewPostPage({super.key});

  @override
  State<ScriptureNewPostPage> createState() => _ScriptureNewPostPageState();
}

class _ScriptureNewPostPageState extends State<ScriptureNewPostPage> {
  final _scriptureFormKey = GlobalKey<ScripturePostFormState>();

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;
    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      body: SafeArea(
        child: BlocConsumer<NewPostBloc, NewPostState>(
          listener: (context, state) {
            if (state is NewPostPublishSuccess) {
              showSuccess(context, 'Scripture post published');
              context.pop();
            } else if (state is NewPostFailure) {
              showWarning(context, state.message);
              context.read<NewPostBloc>().add(
                    NewPostEditingRestored(state.previous),
                  );
            }
          },
          builder: (context, state) {
            final editing = switch (state) {
              NewPostEditing() => state,
              NewPostFailure(:final previous) => previous,
              _ => const NewPostEditing(),
            };
            const tabs = [
              NewPostType.event,
              NewPostType.scripture,
            ];
            final tabIndex =
                tabs.indexOf(editing.selectedType).clamp(0, tabs.length - 1);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _NewPostAppBar(onClose: () => context.pop()),
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: CustomPillTabBar(
                    labels: tabs.map((t) => t.label).toList(),
                    selectedIndex: tabIndex,
                    onTabSelected: (index) => context.read<NewPostBloc>().add(
                          NewPostTypeChanged(tabs[index]),
                        ),
                  ),
                ),
                SizedBox(height: 20.h),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: _ComposeBody(
                      type: editing.selectedType,
                      scriptureFormKey: _scriptureFormKey,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
                  child: SizedBox(
                    width: double.infinity,
                    child: PrimaryButton.publish(
                      isLoading: editing.isPublishing,
                      onPressed: editing.isPublishing
                          ? null
                          : () => _onPublish(context, editing.selectedType),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _onPublish(BuildContext context, NewPostType type) {
    switch (type) {
      case NewPostType.scripture:
        _scriptureFormKey.currentState?.publish(context);
      case NewPostType.event:
        showInfo(context, 'Event posts coming soon');
      case NewPostType.attachment:
        showInfo(context, 'Attachment posts are unavailable');
    }
  }
}

class _ComposeBody extends StatelessWidget {
  final NewPostType type;
  final GlobalKey<ScripturePostFormState> scriptureFormKey;

  const _ComposeBody({
    required this.type,
    required this.scriptureFormKey,
  });

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      NewPostType.scripture => ScripturePostForm(key: scriptureFormKey),
      NewPostType.event => const NewPostTypePlaceholder(
          message: 'Event scheduling is coming soon.',
        ),
      NewPostType.attachment => const NewPostTypePlaceholder(
          message: 'Attachment posts are unavailable.',
        ),
    };
  }
}

class _NewPostAppBar extends StatelessWidget {
  final VoidCallback onClose;

  const _NewPostAppBar({required this.onClose});

  @override
  Widget build(BuildContext context) {
    final colors = context.faithColors;

    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 8.h, 16.w, 0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(
                Iconsax.close_circle,
                color: colors.iconMuted,
                size: 26.r,
              ),
              onPressed: onClose,
            ),
          ),
          Text(
            'New Post',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: colors.headerTitle,
            ),
          ),
        ],
      ),
    );
  }
}
