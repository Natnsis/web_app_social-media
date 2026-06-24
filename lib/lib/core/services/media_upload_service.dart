import 'package:faithconnect/core/media/uploaded_media.dart';
import 'package:image_picker/image_picker.dart';

/// Picks images and videos from the device gallery for compose flows.
class MediaUploadService {
  final ImagePicker _picker;

  MediaUploadService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  Future<UploadedMedia?> pickImage({ImageSource source = ImageSource.gallery}) {
    return _pick(
      picker: () => _picker.pickImage(
        source: source,
        imageQuality: 88,
        maxWidth: 4096,
      ),
      kind: MediaUploadKind.image,
    );
  }

  Future<UploadedMedia?> pickVideo({
    ImageSource source = ImageSource.gallery,
    Duration maxDuration = const Duration(minutes: 10),
  }) {
    return _pick(
      picker: () => _picker.pickVideo(
        source: source,
        maxDuration: maxDuration,
      ),
      kind: MediaUploadKind.video,
    );
  }

  Future<UploadedMedia?> _pick({
    required Future<XFile?> Function() picker,
    required MediaUploadKind kind,
  }) async {
    final file = await picker();
    if (file == null) return null;

    return UploadedMedia(
      filePath: file.path,
      kind: kind,
    );
  }
}
