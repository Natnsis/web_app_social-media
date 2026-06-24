import 'package:equatable/equatable.dart';
import 'package:faithconnect/core/media/uploaded_media.dart';
import 'package:faithconnect/features/post/domain/entities/post_compose_type.dart';

class PostComposeDraft extends Equatable {
  final PostComposeType selectedType;
  final String textBody;
  final String caption;
  final String description;
  final String bibleReference;
  final String verseText;
  final String eventTitle;
  final String eventDateLabel;
  final String eventTimeLabel;
  final String eventDetails;
  final bool allowComments;
  final bool notifyCommunity;
  final bool isPublishing;
  final UploadedMedia? uploadedMedia;

  const PostComposeDraft({
    this.selectedType = PostComposeType.post,
    this.textBody = '',
    this.caption = '',
    this.description = '',
    this.bibleReference = 'John 3:16',
    this.verseText = 'For God so loved the world...',
    this.eventTitle = '',
    this.eventDateLabel = 'October 24, 2024',
    this.eventTimeLabel = '07:00 PM',
    this.eventDetails = '',
    this.allowComments = false,
    this.notifyCommunity = true,
    this.isPublishing = false,
    this.uploadedMedia,
  });

  PostComposeDraft copyWith({
    PostComposeType? selectedType,
    String? textBody,
    String? caption,
    String? description,
    String? bibleReference,
    String? verseText,
    String? eventTitle,
    String? eventDateLabel,
    String? eventTimeLabel,
    String? eventDetails,
    bool? allowComments,
    bool? notifyCommunity,
    bool? isPublishing,
    UploadedMedia? uploadedMedia,
    bool clearUploadedMedia = false,
  }) {
    return PostComposeDraft(
      selectedType: selectedType ?? this.selectedType,
      textBody: textBody ?? this.textBody,
      caption: caption ?? this.caption,
      description: description ?? this.description,
      bibleReference: bibleReference ?? this.bibleReference,
      verseText: verseText ?? this.verseText,
      eventTitle: eventTitle ?? this.eventTitle,
      eventDateLabel: eventDateLabel ?? this.eventDateLabel,
      eventTimeLabel: eventTimeLabel ?? this.eventTimeLabel,
      eventDetails: eventDetails ?? this.eventDetails,
      allowComments: allowComments ?? this.allowComments,
      notifyCommunity: notifyCommunity ?? this.notifyCommunity,
      isPublishing: isPublishing ?? this.isPublishing,
      uploadedMedia: clearUploadedMedia
          ? null
          : (uploadedMedia ?? this.uploadedMedia),
    );
  }

  @override
  List<Object?> get props => [
        selectedType,
        textBody,
        caption,
        description,
        bibleReference,
        verseText,
        eventTitle,
        eventDateLabel,
        eventTimeLabel,
        eventDetails,
        allowComments,
        notifyCommunity,
        isPublishing,
        uploadedMedia,
      ];
}
