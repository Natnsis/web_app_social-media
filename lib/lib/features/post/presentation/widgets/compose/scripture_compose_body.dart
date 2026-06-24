import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/post/domain/entities/post_compose_draft.dart';
import 'package:faithconnect/features/post/presentation/bloc/post_compose_bloc.dart';
import 'package:faithconnect/features/post/presentation/bloc/post_compose_event.dart';
import 'package:faithconnect/features/post/presentation/widgets/compose/post_compose_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScriptureComposeBody extends StatefulWidget {
  final PostComposeDraft draft;

  const ScriptureComposeBody({super.key, required this.draft});

  @override
  State<ScriptureComposeBody> createState() => _ScriptureComposeBodyState();
}

class _ScriptureComposeBodyState extends State<ScriptureComposeBody> {
  late final TextEditingController _referenceController;
  late final TextEditingController _verseController;

  @override
  void initState() {
    super.initState();
    _referenceController =
        TextEditingController(text: widget.draft.bibleReference);
    _verseController = TextEditingController(text: widget.draft.verseText);
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _verseController.dispose();
    super.dispose();
  }

  void _syncReference(String value) {
    context.read<PostComposeBloc>().add(
          PostComposeDraftUpdated(widget.draft.copyWith(bibleReference: value)),
        );
  }

  void _syncVerse(String value) {
    context.read<PostComposeBloc>().add(
          PostComposeDraftUpdated(widget.draft.copyWith(verseText: value)),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppLabeledField(
          label: 'Bible Reference',
          controller: _referenceController,
          hint: 'e.g. John 3:16',
          onChanged: _syncReference,
          maxLines: 1,
        ),
        SizedBox(height: 20.h),
        AppLabeledField(
          label: 'Verse Text',
          controller: _verseController,
          hint: 'For God so loved the world...',
          onChanged: _syncVerse,
          maxLines: 4,
          showDivider: false,
        ),
        SizedBox(height: 24.h),
        const PostComposeSettings(showNotifyCommunity: false),
      ],
    );
  }
}
