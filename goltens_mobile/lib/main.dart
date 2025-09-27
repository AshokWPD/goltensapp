import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:goltens_core/models/auth.dart';
import 'package:goltens_mobile/components/admin/messages.dart';
import 'package:goltens_mobile/pages/feedback/feedback_assigned_page.dart';
import 'package:goltens_mobile/pages/feedback/feedback_list_page.dart';
import 'package:goltens_mobile/pages/master-list/master_list_page.dart';
import 'package:goltens_mobile/pages/others/user_type_choose_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:goltens_core/theme/theme.dart';
import 'package:goltens_mobile/pages/admin/admin_app_choose_page.dart';
import 'package:goltens_mobile/pages/admin/admin_communication_page.dart';
import 'package:goltens_mobile/pages/admin/admin_feedback_page.dart';
import 'package:goltens_mobile/pages/risk_assessment/risk_assessment_detail.dart';
import 'package:goltens_mobile/pages/feedback/feedback_page.dart';
import 'package:goltens_mobile/pages/others/app_choose_page.dart';
import 'package:goltens_mobile/pages/group/group_info_page.dart';
import 'package:goltens_mobile/pages/group/manage_members_page.dart';
import 'package:goltens_mobile/pages/auth/profile_page.dart';
import 'package:goltens_mobile/pages/auth/reset_password.dart';
import 'package:goltens_mobile/provider/global_state.dart';
import 'package:goltens_mobile/pages/auth/admin_approval_page.dart';
import 'package:goltens_mobile/pages/auth/admin_rejected_page.dart';
import 'package:goltens_mobile/pages/auth/auth_page.dart';
import 'package:goltens_mobile/pages/group/group_detail_page.dart';
import 'package:goltens_mobile/pages/group/home_page.dart';
import 'package:goltens_mobile/pages/message/message_detail_page.dart';
import 'package:goltens_mobile/pages/message/read_status_page.dart';
import 'package:goltens_mobile/pages/splash_screen.dart';
import 'package:goltens_mobile/pages/others/file_viewer_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'meet_main.dart';
import 'pages/App_Feedback.dart';
import 'pages/PrivacyPolicy.dart';
import 'pages/admin/checklist/admin_checklist_page.dart';
import 'pages/CheckList/ChecklistIndex.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart' as provider; // Alias for Provider
import 'package:http/http.dart' as http; // ADD THIS IMPORT

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// ADD INTERNET TEST FUNCTION HERE
void testInternetConnectivity() async {
  print('=== INTERNET CONNECTIVITY TEST ===');

  final testUrls = [
    'https://api.onesignal.com',
    'https://google.com',
    'https://goltens.in',
    'http://10.0.2.2', // For local developmentith your actual backend
  ];

  for (var url in testUrls) {
    try {
      final stopwatch = Stopwatch()..start();
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      stopwatch.stop();

      print(
        '✅ $url - Status: ${response.statusCode} - Time: ${stopwatch.elapsedMilliseconds}ms',
      );
    } catch (e) {
      print('❌ $url - Error: $e');
    }
  }

  print('=== TEST COMPLETE ===');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp();

  await FlutterDownloader.initialize(debug: !kReleaseMode, ignoreSsl: true);

  testInternetConnectivity();

  runApp(
    ProviderScope(
      child: provider.MultiProvider(
        providers: [
          provider.ChangeNotifierProvider(create: (context) => GlobalState()),
        ],
        child: const App(), // Your existing App widget
      ),
    ),
  );
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  OSNotification? OSnotification;

  void notificationHandler(BuildContext context, OSNotification event) async {
    String? route = event.additionalData?['route'] ?? "";

    var user = navigatorKey.currentContext?.read<GlobalState>().user?.data;

    switch (route) {
      case 'home':
        Navigator.pushNamed(navigatorKey.currentState!.context, '/home');
        break;
      case 'risk-assessment':
        Navigator.pushNamed(navigatorKey.currentState!.context, '/home');
        break;
      case 'other-files':
        Navigator.pushNamed(navigatorKey.currentState!.context, '/home');
        break;
      case 'user-orientation':
        Navigator.pushNamed(navigatorKey.currentState!.context, '/home');
        break;
      case 'messages':
        if (user?.type == UserType.admin) {
          Navigator.push(
            navigatorKey.currentState!.context,
            MaterialPageRoute(builder: (context) => const Messages()),
          );
        } else {
          Navigator.pushNamed(navigatorKey.currentState!.context, '/home');
        }
        break;
      case 'admin-feedback':
        Navigator.pushNamed(
          navigatorKey.currentState!.context,
          '/admin-feedback',
        );
        break;
      case 'feedbacks':
        Navigator.push(
          navigatorKey.currentState!.context,
          MaterialPageRoute(builder: (context) => const FeedbackListPage()),
        );
        break;
      case 'assigned-feedbacks':
        Navigator.push(
          navigatorKey.currentState!.context,
          MaterialPageRoute(builder: (context) => const FeedbackAssignedPage()),
        );
        break;
      case 'meeting_join':
        Navigator.push(
          navigatorKey.currentState!.context,
          MaterialPageRoute(
            builder: (context) =>
                MeetMain(meetId: "${event.additionalData?['code']}"),
          ),
        );
        break;

      default:
        Navigator.pushNamed(navigatorKey.currentState!.context, '/home');
        break;
    }
  }

  @override
  void initState() {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize("7ea4ff4f-c154-4fd2-8cf6-d8ca1103f390");
    OneSignal.Notifications.requestPermission(true).then((accepted) {
      print("Accepted Permission:$accepted");
    });
    OneSignal.Notifications.addClickListener((event) {
      setState(() {
        OSnotification = event.notification;
      });
      notificationHandler(context, event.notification);
    });

    Timer(const Duration(seconds: 2), () {
      if (OSnotification != null) {
        notificationHandler(context, OSnotification!);
        if (mounted) {
          setState(() {
            OSnotification = null;
          });
        }
      }
    });

    // OneSignal.User.pushSubscription.id;// OneSignal.User.pushSubscription.id;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Goltens App',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: customTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/auth': (context) => const AuthPage(),
        '/privacy-policy': (context) => const PrivacyPolicyPage(),
        '/choose-app': (context) => const AppChoosePage(),
        '/choose-user-type': (context) => const UserTypeChoosePage(),
        '/home': (context) => const HomePage(),
        '/assessment-detail': (context) => const AssessmentDetailPage(),
        '/feedback': (context) => const FeedbackPage(),
        '/master-list': (context) => const MasterListPage(),
        '/group-detail': (context) => const GroupDetailPage(),
        '/message-detail': (context) => const MessageDetailPage(),
        '/admin-approval': (context) => const AdminApprovalPage(),
        '/feedback_listPage': (context) => const FeedbackListPage(),

        '/admin-rejected': (context) => const AdminRejectedPage(),
        '/read-status': (context) => const ReadStatusPage(),
        '/manage-members': (context) => const ManageMembersPage(),
        '/reset-password': (context) => const ResetPasswordPage(),
        '/profile': (context) => const ProfilePage(),
        '/file-viewer': (context) => const FileViewerPage(),
        '/group-info': (context) => const GroupInfoPage(),
        '/admin-choose-app': (context) => const AdminAppChoosePage(),
        '/admin-communication': (context) => const AdminCommunicationPage(),
        '/admin-feedback': (context) => const AdminFeedbackPage(),
        '/feedback-assign': (context) => const FeedbackAssignedPage(),

        '/sub-admin-meeting': (context) => const MeetMain(meetId: ''),
        '/employee-meeting': (context) => const MeetMain(meetId: ''),
        '/admin-meeting': (context) => const MeetMain(meetId: ''),
        '/sub-emp checklist': (context) => const ChecklistIndex(),
        '/admin-checklist': (context) => const AdminChecklist(),
        // '/app-feedback': (context) =>  AppFeedback(),
      },
    );
  }
}
