import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gucy/main_widgets/main_scaffold.dart';
import 'package:gucy/pages/login_signup_page.dart';
import 'package:gucy/providers/posts_provider.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/user_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Future.delayed(const Duration(seconds: 2));

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => PostsProvider()),
      ChangeNotifierProvider(create: (context) => UserProvider()),
    ],
    child: MainApp(),
  ));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    final _router = GoRouter(
      redirect: (context, state) {
        final userProvider = Provider.of<UserProvider>(context);

        if (!userProvider.isAuthenticated) {
          return '/';
        }

        return '/mainScaffold';
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/mainScaffold',
          builder: (context, state) => const MainScaffold(),
        )
      ],
    );
    return MaterialApp.router(
      theme: ThemeData(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      routerConfig: _router,
    );
  }
}
