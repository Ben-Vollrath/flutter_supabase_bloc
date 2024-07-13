import 'package:authentication_repository/authentication_repository.dart';
import 'package:cache/cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class MockCacheClient extends Mock implements CacheClient {}

class MockSupabaseAuth extends Mock implements supabase.GoTrueClient {}

class MockGoTrueClientUser extends Mock implements supabase.User{}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockAuthResponse extends Mock implements supabase.AuthResponse {}

class MockGoogleSignInAuthentication extends Mock implements GoogleSignInAuthentication {}

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();

  const email = "test@gmail.com";
  const password = "securepassword";

  group('AuthenticationRepository', () {
    late CacheClient cacheClient;
    late supabase.GoTrueClient supabaseAuth;
    late GoogleSignIn googleSignIn;
    late AuthenticationRepository authenticationRepository;

    setUp(() {
      cacheClient = MockCacheClient();
      supabaseAuth = MockSupabaseAuth();
      googleSignIn = MockGoogleSignIn();
      authenticationRepository = AuthenticationRepository(
        cache: cacheClient, 
        supabaseAuth: supabaseAuth, 
        googleSignIn: googleSignIn
      );
    });

    test('creates SupabaseAuth instance internally when not injected', () {
      expect(AuthenticationRepository.new, isNot(throwsException));
    });


    group('signUp', () {
      setUp(() {
        when(
          () => supabaseAuth.signUp(
            email: email, 
            password: password
            )
          ).thenAnswer((_) async => Future.value(MockAuthResponse()));
      });

      test('calls signUp on SupabaseAuth', () async {
        await authenticationRepository.signUp(email: email, password: password);
        verify(() => supabaseAuth.signUp(email: email, password: password)).called(1);
      });

      test('succeeds when signUp on SupabaseAuth succeeds', () async {
        expect(
          authenticationRepository.signUp(email: email, password: password),
          completes
        );
      });

      test ('throws AuthFailure when signUp on SupabaseAuth fails', () async {
        when(() => supabaseAuth.signUp(email: email, password: password))
          .thenThrow(Exception());
        expect(
          authenticationRepository.signUp(email: email, password: password),
          throwsA(isA<AuthFailure>())
        );
      });

    });

  });

}