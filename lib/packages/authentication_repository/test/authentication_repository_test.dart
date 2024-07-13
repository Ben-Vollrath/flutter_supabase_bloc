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

  });

}