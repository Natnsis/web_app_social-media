import 'package:faithconnect/core/core.dart';
import 'package:faithconnect/features/live_streaming/presentation/blocs/live_stream_bloc.dart';
import 'package:faithconnect/features/live_streaming/presentation/blocs/live_stream_event.dart';
import 'package:faithconnect/features/live_streaming/presentation/blocs/live_stream_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:faithconnect/features/live_streaming/presentation/navigation/live_stream_navigation.dart';
import 'package:go_router/go_router.dart';

class GoLivePage extends StatefulWidget {
  const GoLivePage({super.key});

  @override
  State<GoLivePage> createState() => _GoLivePageState();
}

class _GoLivePageState extends State<GoLivePage> {
  final _titleController = TextEditingController(
    text: "Sunday Morning Worship Service",
  );
  final _descriptionController = TextEditingController(
    text: "Join us for our weekly Sunday service live broadcast.",
  );
  final _startAtController = TextEditingController(
    text: "2026-06-15T08:00:00.000Z",
  );
  final _endAtController = TextEditingController(
    text: "2026-06-15T10:00:00.000Z",
  );

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startAtController.dispose();
    _endAtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Go Live')),
      body: BlocConsumer<LiveStreamBloc, LiveStreamState>(
        listener: (context, state) {
          if (state is GoLiveSuccess) {
            showSuccess(context, 'You are live');
            context.pop();
            LiveStreamNavigation.openWatch(context, state.stream.id);
          } else if (state is LiveStreamFailure) {
            showError(context, state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is GoLiveInProgress;

          if (state is GoLiveCreated) {
            return _buildCreatedState(context, state.stream, isLoading);
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: AppSpacing.screenPadding,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppSpacing.v24,
                        CustomTextField(
                          controller: _titleController,
                          hint: 'Stream title',
                        ),
                        AppSpacing.v16,
                        CustomTextField(
                          controller: _descriptionController,
                          hint: 'Description',
                          maxLines: 3,
                        ),
                        AppSpacing.v16,
                        CustomTextField(
                          controller: _startAtController,
                          hint: 'Start At (ISO 8601)',
                        ),
                        AppSpacing.v16,
                        CustomTextField(
                          controller: _endAtController,
                          hint: 'End At (ISO 8601)',
                        ),
                        AppSpacing.v24,
                        const Spacer(),
                        PrimaryButton(
                          text: 'Create Live Stream',
                          isLoading: isLoading,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          textColor: Colors.white,
                          onPressed: isLoading
                              ? null
                              : () {
                                  final title = _titleController.text.trim();
                                  if (title.isEmpty) {
                                    showWarning(context, 'Please enter a stream title');
                                    return;
                                  }
                                  context.read<LiveStreamBloc>().add(
                                    GoLiveRequested(
                                      title: title,
                                      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
                                      startAt: _startAtController.text.trim().isEmpty ? null : _startAtController.text.trim(),
                                      endAt: _endAtController.text.trim().isEmpty ? null : _endAtController.text.trim(),
                                    ),
                                  );
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCreatedState(BuildContext context, dynamic stream, bool isLoading) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSpacing.v24,
          Text(
            'Stream Created!',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          AppSpacing.v16,
          Text(
            'Configure your broadcasting software using the details below. Once you start streaming, click Publish.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          AppSpacing.v24,
          CustomTextField(
            hint: 'RTMP URL',
            controller: TextEditingController(text: stream.rtmpUrl ?? 'Not provided'),
            enabled: false,
          ),
          AppSpacing.v16,
          CustomTextField(
            hint: 'Stream Key',
            controller: TextEditingController(text: stream.streamCode ?? 'Not provided'),
            enabled: false,
          ),
          const Spacer(),
          PrimaryButton(
            text: 'Publish Stream',
            isLoading: isLoading,
            backgroundColor: Theme.of(context).colorScheme.primary,
            textColor: Colors.white,
            onPressed: isLoading
                ? null
                : () {
                    context.read<LiveStreamBloc>().add(
                      PublishLiveStreamRequested(stream.id),
                    );
                  },
          ),
          AppSpacing.v24,
        ],
      ),
    );
  }
}
