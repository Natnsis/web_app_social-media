import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:faithconnect/features/church/application/church_service.dart';
import 'package:faithconnect/features/shortvideo/application/short_video_service.dart';
import 'package:faithconnect/features/shortvideo/presentation/bloc/shorts_feed_event.dart';
import 'package:faithconnect/features/shortvideo/presentation/bloc/shorts_feed_state.dart';

class ShortsFeedBloc extends Bloc<ShortsFeedEvent, ShortsFeedState> {
  final ShortVideoService _shortVideoService;
  final ChurchService _churchService;

  ShortsFeedBloc({
    required ShortVideoService shortVideoService,
    required ChurchService churchService,
  })  : _shortVideoService = shortVideoService,
        _churchService = churchService,
        super(const ShortsFeedInitial()) {
      on<ShortsFeedRequested>(_onRequested);
      on<ShortsPageChanged>(_onPageChanged);
      on<ShortVideoLikeToggled>(_onLikeToggled);
      on<ShortVideoFollowToggled>(_onFollowToggled);
      on<ShortVideoReflectionCountChanged>(_onReflectionCountChanged);
    }

  Future<void> _onRequested(
    ShortsFeedRequested event,
    Emitter<ShortsFeedState> emit,
  ) async {
    emit(const ShortsFeedLoading());
    final result = await _shortVideoService.getShortVideos();
    result.fold(
      (failure) => emit(ShortsFeedFailure(failure.message)),
      (videos) => emit(ShortsFeedLoaded(videos: videos)),
    );
  }

  void _onPageChanged(ShortsPageChanged event, Emitter<ShortsFeedState> emit) {
    final current = state;
    if (current is ShortsFeedLoaded) {
      emit(current.copyWith(currentIndex: event.index));
    }
  }

  void _onLikeToggled(
    ShortVideoLikeToggled event,
    Emitter<ShortsFeedState> emit,
  ) {
    final current = state;
    if (current is! ShortsFeedLoaded) return;

    final videos = List.of(current.videos);
    final video = videos[event.index];
    final liked = !video.isLiked;
    final delta = liked ? 1 : -1;

    videos[event.index] = video.copyWith(
      isLiked: liked,
      likeCount: (video.likeCount + delta).clamp(0, 999999999),
    );
    emit(current.copyWith(videos: videos));
  }

  Future<void> _onFollowToggled(
    ShortVideoFollowToggled event,
    Emitter<ShortsFeedState> emit,
  ) async {
    final current = state;
    if (current is! ShortsFeedLoaded) return;

    final videos = List.of(current.videos);
    final video = videos[event.index];
    final churchId = video.authorProfileId;
    if (churchId == null || churchId.isEmpty) return;

    final follow = !video.isFollowing;
    videos[event.index] = video.copyWith(isFollowing: follow);
    emit(current.copyWith(videos: videos));

    final result = follow
        ? await _churchService.toggleFollowChurch(
            churchId: churchId,
            follow: true,
          )
        : await _churchService.unfollowChurch(churchId: churchId);

    result.fold(
      (_) {
        videos[event.index] = video;
        emit(current.copyWith(videos: videos));
      },
      (_) {},
    );
  }

  void _onReflectionCountChanged(
    ShortVideoReflectionCountChanged event,
    Emitter<ShortsFeedState> emit,
  ) {
    final current = state;
    if (current is! ShortsFeedLoaded) return;

    final videos = List.of(current.videos);
    final video = videos[event.index];
    videos[event.index] = video.copyWith(
      reflectionCount: event.count,
    );
    emit(current.copyWith(videos: videos));
  }
}
