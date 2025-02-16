import 'package:authentication_repository/authentication_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_supabase_bloc/firebase_options.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/view/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Bloc.observer = const AppBlocObserver();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'].toString(),
      anonKey: dotenv.env['SUPABASE_ANON_KEY'].toString());

  final webClientId = dotenv.env['WEB_CLIENT_ID'];
  final googleSignIn = GoogleSignIn(
    serverClientId: webClientId,
  );
  final authenticationRepository = AuthenticationRepository(
    googleSignIn: googleSignIn,
  );
  await authenticationRepository.user.first;

  runApp(App(authenticationRepository: authenticationRepository));
}
