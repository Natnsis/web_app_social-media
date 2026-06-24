import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:faithconnect/features/campaign/application/campaign_service.dart';
import 'package:faithconnect/features/campaign/domain/entities/campaign_hub_filter.dart';
import 'package:faithconnect/features/campaign/presentation/bloc/campaigns_hub_event.dart';
import 'package:faithconnect/features/campaign/presentation/bloc/campaigns_hub_state.dart';

class CampaignsHubBloc extends Bloc<CampaignsHubEvent, CampaignsHubState> {
  final CampaignService _campaignService;
  CampaignHubFilter _filter = CampaignHubFilter.ourCampaigns;
  String _searchQuery = '';

  CampaignsHubBloc({required CampaignService campaignService})
      : _campaignService = campaignService,
        super(const CampaignsHubInitial()) {
    on<CampaignsHubRequested>(_onRequested);
    on<CampaignsHubRefreshed>(_onRefreshed);
    on<CampaignsHubFilterChanged>(_onFilterChanged);
    on<CampaignsHubSearchChanged>(_onSearchChanged);
  }

  Future<void> _onRequested(
    CampaignsHubRequested event,
    Emitter<CampaignsHubState> emit,
  ) async {
    await _load(emit, showLoading: true);
  }

  Future<void> _onRefreshed(
    CampaignsHubRefreshed event,
    Emitter<CampaignsHubState> emit,
  ) async {
    await _load(emit, showLoading: false);
  }

  Future<void> _onFilterChanged(
    CampaignsHubFilterChanged event,
    Emitter<CampaignsHubState> emit,
  ) async {
    _filter = event.filter;
    final keepContent = state is CampaignsHubLoaded;
    await _load(emit, showLoading: !keepContent);
  }

  Future<void> _onSearchChanged(
    CampaignsHubSearchChanged event,
    Emitter<CampaignsHubState> emit,
  ) async {
    _searchQuery = event.query.trim();
    final keepContent = state is CampaignsHubLoaded;
    await _load(emit, showLoading: !keepContent);
  }

  Future<void> _load(
    Emitter<CampaignsHubState> emit, {
    required bool showLoading,
  }) async {
    if (showLoading) {
      emit(CampaignsHubLoading(filter: _filter));
    }

    final result = await _campaignService.getHubContent(
      _filter,
      search: _searchQuery.isEmpty ? null : _searchQuery,
    );
    result.fold(
      (failure) => emit(
        CampaignsHubFailure(message: failure.message, filter: _filter),
      ),
      (content) => emit(CampaignsHubLoaded(content)),
    );
  }
}
