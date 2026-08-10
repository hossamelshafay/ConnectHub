import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'core/utils/app_theme.dart';
import 'features/auth/presentation/manager/cubit/auth_cubit.dart';
import 'features/home/presentation/manager/cubit/posts_cubit.dart';
import 'features/chatbot/presentation/manager/cubit/chatbot_cubit.dart';
import 'features/splash/presentation/views/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ConnectHubApp());
}

class ConnectHubApp extends StatelessWidget {
  const ConnectHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => PostsCubit()),
        BlocProvider(create: (_) => ChatbotCubit()),
      ],
      child: MaterialApp(
        title: 'ConnectHub',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const SplashView(),
      ),
    );
  }
}
