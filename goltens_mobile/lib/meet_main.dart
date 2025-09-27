import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:goltens_mobile/meet/navigator_key.dart';
import 'package:goltens_mobile/pages/CheckList/ChecklistIndex.dart';
import 'package:goltens_mobile/pages/PrivacyPolicy.dart';
import 'package:goltens_mobile/pages/admin/admin_app_choose_page.dart';
import 'package:goltens_mobile/pages/admin/admin_communication_page.dart';
import 'package:goltens_mobile/pages/admin/admin_feedback_page.dart';
import 'package:goltens_mobile/pages/admin/checklist/admin_checklist_page.dart';
import 'package:goltens_mobile/pages/auth/admin_approval_page.dart';
import 'package:goltens_mobile/pages/auth/admin_rejected_page.dart';
import 'package:goltens_mobile/pages/auth/auth_page.dart';
import 'package:goltens_mobile/pages/auth/profile_page.dart';
import 'package:goltens_mobile/pages/auth/reset_password.dart';
import 'package:goltens_mobile/pages/feedback/feedback_page.dart';
import 'package:goltens_mobile/pages/group/group_detail_page.dart';
import 'package:goltens_mobile/pages/group/group_info_page.dart';
import 'package:goltens_mobile/pages/group/home_page.dart';
import 'package:goltens_mobile/pages/group/manage_members_page.dart';
import 'package:goltens_mobile/pages/master-list/master_list_page.dart';
import 'package:goltens_mobile/pages/message/message_detail_page.dart';
import 'package:goltens_mobile/pages/message/read_status_page.dart';
import 'package:goltens_mobile/pages/others/app_choose_page.dart';
import 'package:goltens_mobile/pages/others/file_viewer_page.dart';
import 'package:goltens_mobile/pages/others/user_type_choose_page.dart';
import 'package:goltens_mobile/pages/risk_assessment/risk_assessment_detail.dart';
import 'package:goltens_mobile/pages/splash_screen.dart';

import 'package:responsive_framework/responsive_framework.dart';

import 'meet/constants/colors.dart';
import 'meet/screens/common/Meet-Type_screen.dart';
import 'meet/screens/common/join_screen.dart';

class MeetMain extends StatelessWidget {
  final String meetId;
  const MeetMain({super.key, required this.meetId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(start: 0, end: 450, name: MOBILE),
          const Breakpoint(start: 451, end: 800, name: TABLET),
          const Breakpoint(start: 801, end: 1920, name: DESKTOP),
          const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        ],
      ),
      title: 'Goltens Meet',
      theme: ThemeData.light().copyWith(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xff80d6ff),
          foregroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color(0xff80d6ff),
        ),
        primaryColor: const Color(0xff80d6ff),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xff80d6ff)),
            borderRadius: BorderRadius.circular(20.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xff80d6ff)),
            borderRadius: BorderRadius.circular(20.0),
          ),
          labelStyle: const TextStyle(color: Colors.grey),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: const Color(0xff80d6ff),
          selectionHandleColor: const Color(0xff80d6ff),
          selectionColor: Colors.grey.shade300,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            shape: WidgetStateProperty.all(
              const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
            ),
            backgroundColor: WidgetStateProperty.all(const Color(0xff80d6ff)),
            foregroundColor: WidgetStateProperty.all(Colors.black),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all(const Color(0xff80d6ff)),
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateColor.resolveWith((states) => Colors.white),
          checkColor: WidgetStateColor.resolveWith(
            (states) => const Color(0xff80d6ff),
          ),
        ),
      ),
      home: MeetTypeScreen(meetId: meetId),

      routes: {
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
        '/sub-admin-meeting': (context) => const MeetMain(meetId: ''),
        '/employee-meeting': (context) => const MeetMain(meetId: ''),
        '/admin-meeting': (context) => const MeetMain(meetId: ''),
        '/sub-emp checklist': (context) => const ChecklistIndex(),
        '/admin-checklist': (context) => const AdminChecklist(),
      },
      // navigatorKey: navigatorKey,
    );
  }
}
