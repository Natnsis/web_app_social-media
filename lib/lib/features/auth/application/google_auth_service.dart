import 'package:faithconnect/core/constants/api_endpoint.dart';
import 'package:faithconnect/core/utils/faith_logger.dart';
import 'package:faithconnect/features/auth/data/auth_exception.dart';
import 'package:faithconnect/features/auth/data/constants/google_sign_in_constants.dart';
import 'package:faithconnect/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:faithconnect/features/auth/data/models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Google Sign-In SDK + `POST /v1/auth/login/google`.
class GoogleAuthService {
  static const _tag = 'GoogleSignIn';

  final AuthRemoteDataSource _remoteDataSource;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _initialized = false;

  GoogleAuthService({required AuthRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  Future<void> initialize() async {
    const clientId = GoogleSignInConstants.clientId;

    if (_initialized) {
      FaithLogger.d(_tag, 'initialize: already initialized — clientId=$clientId');
      return;
    }

    FaithLogger.i(_tag, 'initialize: clientId=$clientId');
    FaithLogger.i(_tag, 'initialize: serverClientId=$clientId');

    await _googleSignIn.initialize(serverClientId: clientId);
    _initialized = true;
    FaithLogger.i(_tag, 'initialize: GoogleSignIn SDK ready');
  }

  Future<UserModel> signIn() async {
    FaithLogger.i(
      _tag,
      'signIn: starting flow clientId=${GoogleSignInConstants.clientId}',
    );

    try {
      await initialize();

      FaithLogger.d(_tag, 'signIn: opening Google account picker…');
      final GoogleSignInAccount user = await _googleSignIn.authenticate();

      FaithLogger.i(
        _tag,
        'signIn: Google account selected email=${user.email} id=${user.id}',
      );

      final GoogleSignInAuthentication auth = user.authentication;
      final String? idToken = auth.idToken;

      if (idToken == null || idToken.isEmpty) {
        FaithLogger.e(_tag, 'signIn: Google ID token is null or empty');
        throw const AuthException('Google ID Token is null');
      }

      FaithLogger.i(
        _tag,
        'signIn: idToken received length=${idToken.length} — calling backend',
      );

      final userModel = await _loginToBackend(idToken);

      FaithLogger.i(
        _tag,
        'signIn: success userId=${userModel.id} email=${userModel.email}',
      );
      return userModel;
    } on GoogleSignInException catch (e) {
      FaithLogger.e(
        _tag,
        'signIn: GoogleSignInException code=${e.code.name} '
        'description=${e.description}',
        e,
      );

      if (e.code == GoogleSignInExceptionCode.canceled) {
        FaithLogger.d(_tag, 'signIn: cancelled by user');
        throw const AuthException(
          'Google sign-in was cancelled.',
          code: AuthErrorCode.cancelled,
        );
      }
      throw AuthException(
        e.description ?? 'Google sign-in failed (${e.code.name}).',
      );
    } on AuthException catch (e) {
      FaithLogger.e(_tag, 'signIn: auth error — ${e.message}');
      rethrow;
    } catch (e, stack) {
      FaithLogger.e(_tag, 'signIn: unexpected error', e);
      FaithLogger.d(_tag, 'signIn stack: $stack');
      throw AuthException('Google sign-in failed: $e');
    }
  }

  Future<UserModel> _loginToBackend(String idToken) async {
    FaithLogger.i(
      _tag,
      'backend: POST ${AuthApiEndpoint.loginGoogle} body={"idToken":"<len=${idToken.length}>"}',
    );

    final user = await _remoteDataSource.loginWithGoogle(idToken: idToken);

    FaithLogger.i(
      _tag,
      'backend: JWT received and saved for userId=${user.id}',
    );
    return user;
  }

  Future<void> signOut() async {
    FaithLogger.i(_tag, 'signOut: clearing Google session');
    await _googleSignIn.signOut();
    FaithLogger.d(_tag, 'signOut: complete');
  }
}
