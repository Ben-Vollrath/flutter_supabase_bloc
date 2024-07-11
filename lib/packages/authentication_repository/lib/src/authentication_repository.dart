import 'package:cache/cache.dart';
import 'package:meta/meta.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import './models/user.dart' as UserModel;

/// {@template auth_failure}
/// Thrown during the auth process if a failure occurs.
/// {@endtemplate}
class AuthFailure {
  /// The associated error message.
  final String message;

  /// {@macro auth_failure}
  const AuthFailure([this.message = 'An unknown error occurred.']);

  /// Create an authentication message from a detailed Supabase error code.
  factory AuthFailure.fromException(AuthException exception) {
    if (exception is AuthApiException) {
      final code = exception.statusCode;
      switch (code) {
        case 'bad_code_verifier':
          return const AuthFailure(
              'The provided code verifier does not match the expected one.');
        case 'bad_json':
          return const AuthFailure('The request body is not valid JSON.');
        case 'bad_jwt':
          return const AuthFailure('The JWT provided is not valid.');
        case 'bad_oauth_callback':
          return const AuthFailure(
              'OAuth callback from provider is missing required attributes.');
        case 'bad_oauth_state':
          return const AuthFailure('OAuth state is not in the correct format.');
        case 'captcha_failed':
          return const AuthFailure('Captcha verification failed.');
        case 'conflict':
          return const AuthFailure('A conflict occurred. Please try again.');
        case 'email_conflict_identity_not_deletable':
          return const AuthFailure(
              'Cannot unlink this identity. Email address already in use.');
        case 'email_exists':
          return const AuthFailure('Email address already exists.');
        case 'email_not_confirmed':
          return const AuthFailure('Email address not confirmed.');
        case 'email_provider_disabled':
          return const AuthFailure('Email and password signups are disabled.');
        case 'flow_state_expired':
          return const AuthFailure(
              'Sign-in flow state has expired. Please sign in again.');
        case 'flow_state_not_found':
          return const AuthFailure(
              'Sign-in flow state not found. Please sign in again.');
        case 'identity_already_exists':
          return const AuthFailure('Identity already linked to another user.');
        case 'identity_not_found':
          return const AuthFailure('Identity not found.');
        case 'insufficient_aal':
          return const AuthFailure(
              'Higher Authenticator Assurance Level required.');
        case 'invite_not_found':
          return const AuthFailure('Invite is expired or already used.');
        case 'manual_linking_disabled':
          return const AuthFailure('Manual linking is disabled.');
        case 'mfa_challenge_expired':
          return const AuthFailure(
              'MFA challenge expired. Please request a new challenge.');
        case 'mfa_factor_name_conflict':
          return const AuthFailure(
              'MFA factors should not have the same name.');
        case 'mfa_factor_not_found':
          return const AuthFailure('MFA factor not found.');
        case 'mfa_ip_address_mismatch':
          return const AuthFailure(
              'MFA enrollment must use the same IP address.');
        case 'mfa_verification_failed':
          return const AuthFailure(
              'MFA verification failed. Incorrect TOTP code.');
        case 'mfa_verification_rejected':
          return const AuthFailure('MFA verification rejected.');
        case 'no_authorization':
          return const AuthFailure('Authorization header is missing.');
        case 'not_admin':
          return const AuthFailure('User is not an admin.');
        case 'oauth_provider_not_supported':
          return const AuthFailure('OAuth provider is disabled.');
        case 'otp_disabled':
          return const AuthFailure('Sign in with OTP is disabled.');
        case 'otp_expired':
          return const AuthFailure('OTP code expired. Please sign in again.');
        case 'over_email_send_rate_limit':
          return const AuthFailure(
              'Too many emails sent to this address. Please wait.');
        case 'over_request_rate_limit':
          return const AuthFailure('Too many requests. Please wait.');
        case 'over_sms_send_rate_limit':
          return const AuthFailure(
              'Too many SMS messages sent to this number. Please wait.');
        case 'phone_exists':
          return const AuthFailure('Phone number already exists.');
        case 'phone_not_confirmed':
          return const AuthFailure('Phone number not confirmed.');
        case 'phone_provider_disabled':
          return const AuthFailure('Phone and password signups are disabled.');
        case 'provider_disabled':
          return const AuthFailure('OAuth provider is disabled.');
        case 'provider_email_needs_verification':
          return const AuthFailure(
              'Email verification required after OAuth sign-in.');
        case 'reauthentication_needed':
          return const AuthFailure('Reauthentication required.');
        case 'reauthentication_not_valid':
          return const AuthFailure('Reauthentication failed. Incorrect code.');
        case 'same_password':
          return const AuthFailure(
              'New password must be different from the current one.');
        case 'saml_assertion_no_email':
          return const AuthFailure('SAML assertion missing email address.');
        case 'saml_assertion_no_user_id':
          return const AuthFailure('SAML assertion missing user ID.');
        case 'saml_entity_id_mismatch':
          return const AuthFailure('SAML entity ID mismatch.');
        case 'saml_idp_already_exists':
          return const AuthFailure('SAML identity provider already exists.');
        case 'saml_idp_not_found':
          return const AuthFailure('SAML identity provider not found.');
        case 'saml_metadata_fetch_failed':
          return const AuthFailure('Failed to fetch SAML metadata.');
        case 'saml_provider_disabled':
          return const AuthFailure('SAML provider is disabled.');
        case 'saml_relay_state_expired':
          return const AuthFailure(
              'SAML relay state expired. Please sign in again.');
        case 'saml_relay_state_not_found':
          return const AuthFailure(
              'SAML relay state not found. Please sign in again.');
        case 'session_not_found':
          return const AuthFailure('Session not found.');
        case 'signup_disabled':
          return const AuthFailure('Signups are disabled.');
        case 'single_identity_not_deletable':
          return const AuthFailure(
              'Cannot delete the only identity for this user.');
        case 'sms_send_failed':
          return const AuthFailure(
              'Failed to send SMS. Check your provider configuration.');
        case 'sso_domain_already_exists':
          return const AuthFailure('SSO domain already registered.');
        case 'sso_provider_not_found':
          return const AuthFailure('SSO provider not found.');
        case 'too_many_enrolled_mfa_factors':
          return const AuthFailure('Too many MFA factors enrolled.');
        case 'unexpected_audience':
          return const AuthFailure('Unexpected audience in JWT.');
        case 'unexpected_failure':
          return const AuthFailure(
              'Unexpected failure. Auth service is degraded.');
        case 'user_already_exists':
          return const AuthFailure('User already exists.');
        case 'user_banned':
          return const AuthFailure('User is banned.');
        case 'user_not_found':
          return const AuthFailure('User not found.');
        case 'user_sso_managed':
          return const AuthFailure(
              'Cannot update fields for SSO managed user.');
        case 'validation_failed':
          return const AuthFailure('Validation failed. Check your input.');
        case 'weak_password':
          return const AuthFailure(
              'Weak password. Please choose a stronger password.');
        default:
          return const AuthFailure();
      }
    }
    return const AuthFailure();
  }
}
/// Thrown during the logout process if a failure occurs.
class LogOutFailure implements Exception {}

/// {@temaplate authentication_repository}
/// Repository which manages user authentication.
/// {@endtemplate}
class AuthenticationRepository{
  /// {@macro authentication_repository}
  AuthenticationRepository({
    CacheClient? cache,
    SupabaseClient? supabaseClient,
    GoogleSignIn? googleSignIn,
  })  : _cache = cache ?? CacheClient(),
        _supabaseClient = supabaseClient ?? Supabase.instance.client,
        _googleSignIn = googleSignIn ?? GoogleSignIn.standard();

  final CacheClient _cache;
  final SupabaseClient _supabaseClient;
  final GoogleSignIn _googleSignIn;


  /// Whether or not the current environment is web
  /// Should only be overridden for testing purposes. Otherwise,
  /// defaults to [kIsWeb]
  @visibleForTesting
  bool isWeb = kIsWeb;

  /// User cache KEy
  /// Should only be used for testing purposes.
  @visibleForTesting
  static const userCacheKey = '__user_cache_key__';

  /// Stream of [User] which will emit the current user when
  /// the authentication state changes.
  ///
  /// Emits [User.empty] if the user is not authenticated.
  Stream<UserModel.User> get user {
    return _supabaseClient.auth.onAuthStateChange.map((authState){
      final user = authState.session == null ? UserModel.User.empty : authState.toUser;
      _cache.write(key: userCacheKey, value: user);
      return user;
    });
  }
}

extension on AuthState {
  /// Maps the [AuthState] to a [User] object.
  UserModel.User get toUser {
    User user = session!.user;
    return UserModel.User(id: user.id, email: user.email, name: user.email!.split('@')[0]);
  }
}