import 'package:authentication_repository/authentication_repository.dart';
import 'package:cache/cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

const _mockUserID = "mock-user-id";
const _mockEmail = "mock-email";

class MockCacheClient extends Mock implements CacheClient {}

class MockSupabaseAuth extends Mock implements supabase.GoTrueClient {}

class MockGoTrueClientUser extends Mock implements supabase.User {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockAuthResponse extends Mock implements supabase.AuthResponse {}

class MockAuthState extends Mock implements supabase.AuthState {}

class MockAuthSession extends Mock implements supabase.Session {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const email = "test@gmail.com";
  const password = "securepassword";
    const user = User(
    id: _mockUserID,
    email: _mockEmail,
    name: _mockEmail,
  );

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
          googleSignIn: googleSignIn);
    });

    test('creates SupabaseAuth instance internally when not injected', () {
      expect(AuthenticationRepository.new, isNot(throwsException));
    });

    group('signUp', () {
      setUp(() {
        when(() => supabaseAuth.signUp(email: email, password: password))
            .thenAnswer((_) async => Future.value(MockAuthResponse()));
      });

      test('calls signUp on SupabaseAuth', () async {
        await authenticationRepository.signUp(email: email, password: password);
        verify(() => supabaseAuth.signUp(email: email, password: password))
            .called(1);
      });

      test('succeeds when signUp on SupabaseAuth succeeds', () async {
        expect(
            authenticationRepository.signUp(email: email, password: password),
            completes);
      });

      test('throws AuthFailure when signUp on SupabaseAuth fails', () async {
        when(() => supabaseAuth.signUp(email: email, password: password))
            .thenThrow(Exception());
        expect(
            authenticationRepository.signUp(email: email, password: password),
            throwsA(isA<AuthFailure>()));
      });
    });

    group('loginWithGoogle', () {
      const accessToken = 'access-token';
      const idToken = "id-token";

      setUp(() {
        final googleSignInAuthentication = MockGoogleSignInAuthentication();
        final googleSignInAccount = MockGoogleSignInAccount();

        when(() => googleSignIn.signIn())
            .thenAnswer((_) async => googleSignInAccount);
        when(() => googleSignInAccount.authentication)
            .thenAnswer((_) async => googleSignInAuthentication);
        when(() => googleSignInAuthentication.accessToken)
            .thenReturn(accessToken);
        when(() => googleSignInAuthentication.idToken).thenReturn(idToken);
        when(() => supabaseAuth.signInWithIdToken(
              provider: supabase.OAuthProvider.google,
              idToken: "id-token",
              accessToken: "access-token",
            )).thenAnswer((_) async => MockAuthResponse());
      });

      test('calls signIn on GoogleSignIn', () async {
        await authenticationRepository.logInWithGoogle();
        verify(() => googleSignIn.signIn()).called(1);
        verify(() => supabaseAuth.signInWithIdToken(
            provider: supabase.OAuthProvider.google,
            idToken: "id-token",
            accessToken: "access-token")).called(1);
      });

      test('succeeds when signIn succeeds', () {
        expect(authenticationRepository.logInWithGoogle(), completes);
      });

      test('throws AuthFailure when signIn fails', () {
        when(() => googleSignIn.signIn()).thenThrow(Exception());
        expect(authenticationRepository.logInWithGoogle(),
            throwsA(isA<AuthFailure>()));
      });
    });
 
    group('logInWithEmailAndPassword', () {
      setUp(() {
        when(() => supabaseAuth.signInWithPassword(email: email, password: password))
            .thenAnswer((_) async => Future.value(MockAuthResponse()));
      });

      test('calls signIn on SupabaseAuth', () async {
        await authenticationRepository.logInWithEmailAndPassword(
            email: email, password: password);
        verify(() => supabaseAuth.signInWithPassword(email: email, password: password))
            .called(1);
      });

      test('succeeds when signIn on SupabaseAuth succeeds', () async {
        expect(authenticationRepository.logInWithEmailAndPassword(
            email: email, password: password), completes);
      });

      test('throws AuthFailure when signIn on SupabaseAuth fails', () async {
        when(() => supabaseAuth.signInWithPassword(email: email, password: password))
            .thenThrow(Exception());
        expect(authenticationRepository.logInWithEmailAndPassword(
            email: email, password: password), throwsA(isA<AuthFailure>()));
      });
    });

    group('logOut', () {
      setUp(() {
        when(() => supabaseAuth.signOut()).thenAnswer((_) async => Future.value());
        when(() => googleSignIn.signOut()).thenAnswer((_) async => Future.value(MockGoogleSignInAccount()));
      });

      test('calls signOut on SupabaseAuth', () async {
        await authenticationRepository.logOut();
        verify(() => supabaseAuth.signOut()).called(1);
      });

      test('succeeds when signOut on SupabaseAuth succeeds', () async {
        expect(authenticationRepository.logOut(), completes);
      });

      test('throws LogOutFailure when signOut on SupabaseAuth fails', () async {
        when(() => supabaseAuth.signOut()).thenThrow(Exception());
        expect(authenticationRepository.logOut(), throwsA(isA<LogOutFailure>()));
      });
    });

    group('user', () {
      
      test('emits User.empty when no user is signed in', () async{
        when(() => supabaseAuth.onAuthStateChange).thenAnswer((_) => Stream.value(MockAuthState()));
        await expectLater(
          authenticationRepository.user,
           emitsInOrder(const <User>[User.empty]),
        );
      });

      test('emits User when user is signed in', () async{
        final supabaseUser = MockGoTrueClientUser();
        when(() => supabaseUser.id).thenReturn(_mockUserID);
        when(() => supabaseUser.email).thenReturn(_mockEmail);
        final authSession = MockAuthSession();
        when(() => authSession.user).thenReturn(supabaseUser);
        final mockAuthState = MockAuthState();
        when(() => mockAuthState.session).thenReturn(authSession);
        when(() => supabaseAuth.onAuthStateChange).thenAnswer((_) => Stream.value(mockAuthState));

        await expectLater(
          authenticationRepository.user,
          emitsInOrder(const <User>[user]),
        );
        verify(
          () => cacheClient.write(
            key: AuthenticationRepository.userCacheKey,
            value: user,
          ),
        ).called(1);        
      });

    });
  });


}
