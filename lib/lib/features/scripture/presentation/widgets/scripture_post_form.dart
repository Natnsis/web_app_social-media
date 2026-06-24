import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/scripture/presentation/bloc/new_post_bloc.dart';
import 'package:faithconnect/features/scripture/presentation/bloc/new_post_event.dart';
import 'package:faithconnect/features/scripture/presentation/bloc/new_post_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ScripturePostForm extends StatefulWidget {
  const ScripturePostForm({super.key});

  @override
  ScripturePostFormState createState() => ScripturePostFormState();
}

class ScripturePostFormState extends State<ScripturePostForm> {
  final _referenceController = TextEditingController(text: 'John 3:16');
  final _verseController = TextEditingController(
    text: 'For God so loved the world...',
  );

  @override
  void dispose() {
    _referenceController.dispose();
    _verseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewPostBloc, NewPostState>(
      buildWhen: (previous, current) =>
          current is NewPostEditing || current is NewPostFailure,
      builder: (context, state) {
        final editing = state is NewPostFailure ? state.previous : state;
        if (editing is! NewPostEditing) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppLabeledField(
              label: 'Bible Reference',
              controller: _referenceController,
              hint: 'e.g. John 3:16',
              maxLines: 1,
            ),
            SizedBox(height: 20.h),
            AppLabeledField(
              label: 'Verse Text',
              controller: _verseController,
              hint: 'For God so loved the world...',
              maxLines: 4,
              showDivider: false,
            ),
            SizedBox(height: 32.h),
            AppSettingsSwitchTile(
              title: 'Notify Community',
              subtitle: 'Push notification to your followers',
              value: editing.notifyCommunity,
              onChanged: (_) => context.read<NewPostBloc>().add(
                    const ScriptureNotifyCommunityToggled(),
                  ),
            ),
          ],
        );
      },
    );
  }

  void publish(BuildContext context) {
    final reference = _referenceController.text.trim();
    final verse = _verseController.text.trim();

    if (reference.isEmpty || verse.isEmpty) {
      showWarning(context, 'Please enter a Bible reference and verse text.');
      return;
    }

    context.read<NewPostBloc>().add(
          ScripturePostPublishRequested(
            bibleReference: reference,
            verseText: verse,
          ),
        );
  }
}

/// Placeholder when Event or Attachment tab is selected.
class NewPostTypePlaceholder extends StatelessWidget {
  final String message;

  const NewPostTypePlaceholder({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 15.sp,
            color: DarkTheme.feedMutedText,
          ),
        ),
      ),
    );
  }
}
