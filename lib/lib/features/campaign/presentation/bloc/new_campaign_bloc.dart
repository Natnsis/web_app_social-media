import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:faithconnect/features/campaign/application/campaign_service.dart';
import 'package:faithconnect/features/campaign/domain/entities/new_campaign_draft.dart';
import 'package:faithconnect/features/campaign/presentation/bloc/new_campaign_event.dart';
import 'package:faithconnect/features/campaign/presentation/bloc/new_campaign_state.dart';

class NewCampaignBloc extends Bloc<NewCampaignEvent, NewCampaignState> {
  final CampaignService _campaignService;

  NewCampaignBloc({required CampaignService campaignService})
      : _campaignService = campaignService,
        super(const NewCampaignEditing(NewCampaignDraft())) {
    on<NewCampaignDraftUpdated>(_onDraftUpdated);
    on<NewCampaignSubmitted>(_onSubmitted);
  }

  void _onDraftUpdated(
    NewCampaignDraftUpdated event,
    Emitter<NewCampaignState> emit,
  ) {
    emit(NewCampaignEditing(event.draft));
  }

  Future<void> _onSubmitted(
    NewCampaignSubmitted event,
    Emitter<NewCampaignState> emit,
  ) async {
    final current = switch (state) {
      NewCampaignEditing(:final draft) => draft,
      NewCampaignFailure(:final draft) => draft,
      _ => const NewCampaignDraft(),
    };

    final validation = _validate(current);
    if (validation != null) {
      emit(
        NewCampaignFailure(
          draft: current,
          message: validation,
        ),
      );
      return;
    }

    emit(NewCampaignEditing(current.copyWith(isSubmitting: true)));

    final result = await _campaignService.launchCampaign(current);
    result.fold(
      (failure) => emit(
        NewCampaignFailure(
          draft: current.copyWith(isSubmitting: false),
          message: failure.message,
        ),
      ),
      (id) => emit(NewCampaignSuccess(id)),
    );
  }

  String? _validate(NewCampaignDraft draft) {
    if (draft.title.trim().isEmpty) {
      return 'Campaign title is required.';
    }
    if (draft.description.trim().isEmpty) {
      return 'Description is required.';
    }
    final goal = draft.parsedGoal;
    if (goal == null || goal <= 0) {
      return 'Enter a valid goal amount in ETB.';
    }
    return null;
  }
}
