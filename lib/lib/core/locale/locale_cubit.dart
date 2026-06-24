import 'package:faithconnect/core/locale/app_language.dart';
import 'package:faithconnect/core/services/shared_prefs_Service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Persists and exposes the active app [AppLanguage].
class LocaleCubit extends Cubit<AppLanguage> {
  LocaleCubit() : super(AppLanguage.english);

  bool _loaded = false;

  bool get isLoaded => _loaded;

  Future<void> load() async {
    final stored = await SharedPrefsService.getLanguage();
    emit(AppLanguage.fromCode(stored));
    _loaded = true;
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (state == language) return;
    await SharedPrefsService.setLanguage(language.code);
    emit(language);
  }
}
