import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'firebase_options.dart';
import 'core/theme/theme_cubit.dart';
import 'core/utils/app_theme.dart';
import 'features/auth/presentation/manager/cubit/auth_cubit.dart';
import 'features/home/presentation/manager/cubit/posts_cubit.dart';
import 'features/chatbot/presentation/manager/cubit/chatbot_cubit.dart';
import 'features/notification/presentation/manager/cubit/notification_cubit.dart';
import 'features/chat/presentation/manager/cubit/conversations_cubit.dart';
import 'features/splash/presentation/views/splash_view.dart';
import 'web_portfolio/portfolio_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('app_theme_mode') ?? 'light';
  final isDark = savedTheme == 'dark';
  AppColors.isDark = isDark;

  if (!kIsWeb) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
    );
  }

  runApp(ConnectHubApp(prefs: prefs));
}

class ConnectHubApp extends StatelessWidget {
  final SharedPreferences prefs;
  const ConnectHubApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(prefs),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          final isDark = themeMode == ThemeMode.dark;
          AppColors.isDark = isDark;
          final currentTheme =
              isDark ? AppTheme.darkTheme : AppTheme.lightTheme;

          return ThemeProvider(
            initTheme: currentTheme,
            duration: const Duration(milliseconds: 600),
            builder: (context, theme) {
              if (kIsWeb) {
                return MaterialApp(
                  title: 'ConnectHub | Portfolio',
                  debugShowCheckedModeBanner: false,
                  theme: theme,
                  onGenerateRoute: PortfolioRouter.onGenerateRoute,
                  initialRoute: PortfolioRouter.rootRoute,
                  builder: (context, child) => ThemeSwitchingArea(
                    child: child ?? const SizedBox.shrink(),
                  ),
                );
              }

              return MultiBlocProvider(
                providers: [
                  BlocProvider(create: (_) => AuthCubit()),
                  BlocProvider(create: (_) => PostsCubit()),
                  BlocProvider(create: (_) => ChatbotCubit()),
                  BlocProvider(create: (_) => NotificationCubit()),
                  BlocProvider(create: (_) => ConversationsCubit()),
                ],
                child: MaterialApp(
                  title: 'ConnectHub',
                  debugShowCheckedModeBanner: false,
                  theme: theme,
                  home: const SplashView(),
                  builder: (context, child) => ThemeSwitchingArea(
                    child: child ?? const SizedBox.shrink(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
