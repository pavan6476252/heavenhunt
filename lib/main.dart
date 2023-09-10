import 'package:heavenhunt/color_schemes.g.dart';
import 'package:heavenhunt/screens/components/search_page.dart';
import 'package:heavenhunt/screens/post_services_scr.dart';
import 'package:heavenhunt/models/user_model.dart';
import 'package:heavenhunt/screens/Home.dart';
import 'package:heavenhunt/screens/add_room.dart';
import 'package:heavenhunt/screens/edit_profile.dart';
import 'package:heavenhunt/screens/neew_user.dart';
import 'package:heavenhunt/utils/Loading.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/src/providers/phone_auth_provider.dart'
    as phone_auth;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseUIAuth.configureProviders([phone_auth.PhoneAuthProvider()]);
  if (!kIsWeb) {
    const Settings(persistenceEnabled: true);
  } else {
    await FirebaseFirestore.instance.enablePersistence();
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  bool userExists = false;

  @override
  void initState() {
    super.initState();
    _checkUserExistence();
  }

  Future<void> _checkUserExistence() async {
    final exists = await UserProfile.checkUserAuth();

    setState(() {
      userExists = exists;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      
      navigatorKey: navigatorKey, // Set the navigatorKey
      theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      // initialRoute: userExists ? '/home' : '/user-data',
      initialRoute: '/',
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (context) {
            switch (settings.name) {
              case '/':
                return const Splash();

              case '/login':
                return SignInScreen(
                  providers: <AuthProvider>[phone_auth.PhoneAuthProvider()],
                  actions: [
                    AuthStateChangeAction<SignedIn>((context, state) {
                      if (state.user != null) {
                        checkUserExistence(context);
                      }
                    }),
                  ],
                );
              case '/user-data':
                return const UserDataScreen();
              case '/home':
                return const HomeScreen();
              case '/edit-profile':
                return const EditProfileScreen();
              case '/post-food-services':
                return PostServiceScreen();
              case '/add-room':
                return AddRoomPage();
              case '/filter-screen':
                return FilterScreen();
              default:
                return const LoadingAnimation();
            }
          },
        );
      },
    );
  }

  void checkUserExistence(BuildContext context) async {
    if (await UserProfile.checkUserAuth()) {
      navigatorKey.currentState?.pushReplacementNamed('/home');
    } else {
      navigatorKey.currentState?.pushReplacementNamed('/login');
    }
  }
}

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool userExists = false;

  @override
  void initState() {
    super.initState();
    _checkUserExistence();
  }

  Future<void> _checkUserExistence() async {
    final exists = await UserProfile.checkUserAuth();

    if (exists)
      Navigator.pushReplacementNamed(context, '/home');
    else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
