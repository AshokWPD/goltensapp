import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:goltens_mobile/utils/functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Use the new function that actually tests internet
      if (await hasRealInternetConnection()) {
        if (mounted) {
          FlutterNativeSplash.remove();
          authNavigate(context);
        }
      } else {
        FlutterNativeSplash.remove();

        final snackBar = SnackBar(
          content: const Text('No Internet Connection'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (r) => false,
              );
            },
          ),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: null);
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_native_splash/flutter_native_splash.dart';
// import 'package:goltens_mobile/utils/functions.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   // Future<void> _checkNotificationRoute() async {
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   String? route = prefs.getString('notification_route');

//   //   if (route != null && route.isNotEmpty) {
//   //     prefs
//   //         .remove('notification_route'); // Clear the saved route after using it
//   //     Navigator.pushReplacementNamed(context, route);
//   //   } else {
//   //     SharedPreferences prefs = await SharedPreferences.getInstance();
//   //     prefs.remove('notification_route');

//   //   }
//   // }

//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       if (await hasInternetConnection()) {
//         if (mounted) {
//           FlutterNativeSplash.remove();
//           authNavigate(context);
//           //_checkNotificationRoute();
//         }
//       } else {
//         FlutterNativeSplash.remove();

//         final snackBar = SnackBar(
//           content: const Text('No Internet Connection'),
//           action: SnackBarAction(
//             label: 'Retry',
//             onPressed: () {
//               Navigator.pushNamedAndRemoveUntil(
//                 context,
//                 '/',
//                 (r) => false,
//               );
//             },
//           ),
//         );

//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(snackBar);
//         }
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(body: null);
//   }
// }
