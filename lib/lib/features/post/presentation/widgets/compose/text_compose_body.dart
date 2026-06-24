import 'package:faithconnect/core/theme/dark_theme.dart';
import 'package:faithconnect/features/post/domain/entities/post_compose_draft.dart';
import 'package:faithconnect/features/post/presentation/bloc/post_compose_bloc.dart';
import 'package:faithconnect/features/post/presentation/bloc/post_compose_event.dart';
import 'package:faithconnect/features/post/presentation/widgets/compose/post_compose_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class TextComposeBody extends StatefulWidget {
  final PostComposeDraft draft;

  const TextComposeBody({super.key, required this.draft});

  @override
  State<TextComposeBody> createState() => _TextComposeBodyState();
}

class _TextComposeBodyState extends State<TextComposeBody> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.draft.textBody);
  }

  @override
  void didUpdateWidget(TextComposeBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.draft.textBody != widget.draft.textBody &&
        _controller.text != widget.draft.textBody) {
      _controller.text = widget.draft.textBody;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sync(String value) {
    context.read<PostComposeBloc>().add(
          PostComposeDraftUpdated(widget.draft.copyWith(textBody: value)),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 280.h,
          child: TextField(
            controller: _controller,
            onChanged: _sync,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: GoogleFonts.inter(
              fontSize: 22.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              height: 1.45,
            ),
            cursorColor: DarkTheme.brandBlue,
            decoration: InputDecoration(
              hintText: 'Write a message to your congregation...',
              hintStyle: GoogleFonts.inter(
                fontSize: 22.sp,
                fontWeight: FontWeight.w500,
                color: DarkTheme.feedMutedText.withValues(alpha: 0.65),
                height: 1.45,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        const PostComposeSettings(),
      ],
    );
  }
}
