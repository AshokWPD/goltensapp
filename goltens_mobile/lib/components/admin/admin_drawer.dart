import 'package:flutter/material.dart';
import 'package:goltens_mobile/components/admin/dashboard.dart';
import 'package:goltens_mobile/components/admin/edit_profile.dart';
import 'package:goltens_mobile/components/admin/master_list.dart';
import 'package:goltens_mobile/components/admin/groups.dart';
import 'package:goltens_mobile/components/admin/messages.dart';
import 'package:goltens_mobile/components/admin/other_files.dart';
import 'package:goltens_mobile/components/admin/pending_requests.dart';
import 'package:goltens_mobile/components/admin/risk_assessments.dart';
import 'package:goltens_mobile/components/admin/sub_admins.dart';
import 'package:goltens_mobile/components/admin/user_orientation.dart';
import 'package:goltens_mobile/components/admin/users.dart';
import 'package:goltens_mobile/components/admin/users_and_subadmins.dart';
import 'package:goltens_mobile/pages/auth/auth_page.dart';
import 'package:goltens_mobile/provider/global_state.dart';
import 'package:goltens_core/services/auth.dart';
import 'package:provider/provider.dart';

class AdminDrawer extends StatefulWidget {
  final int currentIndex;

  const AdminDrawer({
    super.key,
    required this.currentIndex,
  });

  @override
  State<AdminDrawer> createState() => _AdminDrawerState();
}

class _AdminDrawerState extends State<AdminDrawer> {
  void setDrawerSelectedIndex(int index) {
    var selectedIndex = widget.currentIndex;
    if (selectedIndex == index) return;

    Navigator.pop(context);

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CommunicationDashboard(),
          ),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PendingRequests(),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Users(),
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SubAdmins(),
          ),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const UsersAndSubAdmins(),
          ),
        );
        break;
      case 5:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Groups(),
          ),
        );
        break;
      case 6:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Messages(),
          ),
        );
        break;
      case 7:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MasterList(),
          ),
        );
        break;
      case 8:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RiskAssessments(),
          ),
        );
        break;
      case 9:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const OtherFiles(),
          ),
        );
        break;
      case 10:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const UserOrientation(),
          ),
        );
        break;
      case 11:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EditProfile(),
          ),
        );
        break;
      default:
    }
  }

  void logout() {
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Are you sure you want to logout ?"),
          actions: [
            TextButton(
              child: const Text("CANCEL"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("OK"),
              onPressed: () async {
                await AuthService.logout();

                // ignore: use_build_context_synchronously
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return const AuthPage();
                  }),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var selectedItemIndex = widget.currentIndex;
    var user = context.read<GlobalState>().user?.data;

    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Goltens Admin Panel',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? '---',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    user?.email ?? '---',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              selectedColor: const Color(0xff80d6ff),
              leading: const Icon(Icons.dashboard_sharp),
              title: const Text('Dashboard'),
              onTap: () => setDrawerSelectedIndex(0),
              selected: selectedItemIndex == 0,
            ),
            ListTile(
              selectedColor: const Color(0xff80d6ff),
              leading: const Icon(Icons.done_all),
              title: const Text('Pending Requests'),
              onTap: () => setDrawerSelectedIndex(1),
              selected: selectedItemIndex == 1,
            ),
            ListTile(
              leading: const Icon(Icons.account_circle_rounded),
              title: const Text('Users'),
              onTap: () => setDrawerSelectedIndex(2),
              selected: selectedItemIndex == 2,
              selectedColor: const Color(0xff80d6ff),
            ),
            ListTile(
              leading: const Icon(Icons.manage_accounts),
              title: const Text('SubAdmins'),
              onTap: () => setDrawerSelectedIndex(3),
              selected: selectedItemIndex == 3,
              selectedColor: const Color(0xff80d6ff),
            ),
            ListTile(
              leading: const Icon(Icons.manage_accounts),
              title: const Text('Users & SubAdmins'),
              onTap: () => setDrawerSelectedIndex(4),
              selected: selectedItemIndex == 4,
              selectedColor: const Color(0xff80d6ff),
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Groups'),
              onTap: () => setDrawerSelectedIndex(5),
              selected: selectedItemIndex == 5,
              selectedColor: const Color(0xff80d6ff),
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Messages'),
              onTap: () => setDrawerSelectedIndex(6),
              selected: selectedItemIndex == 6,
              selectedColor: const Color(0xff80d6ff),
            ),
            ListTile(
              leading: const Icon(Icons.file_copy),
              title: const Text('Master List'),
              onTap: () => setDrawerSelectedIndex(7),
              selected: selectedItemIndex == 7,
              selectedColor: const Color(0xff80d6ff),
            ),
            ListTile(
              leading: const Icon(Icons.list_alt_sharp),
              title: const Text('Risk Assessment'),
              onTap: () => setDrawerSelectedIndex(8),
              selected: selectedItemIndex == 8,
              selectedColor: const Color(0xff80d6ff),
            ),
            ListTile(
              leading: const Icon(Icons.list_alt_sharp),
              title: const Text('Company Informations'),
              onTap: () => setDrawerSelectedIndex(9),
              selected: selectedItemIndex == 9,
              selectedColor: const Color(0xff80d6ff),
            ),
            ListTile(
              leading: const Icon(Icons.list_alt_sharp),
              title: const Text('HR Documents'),
              onTap: () => setDrawerSelectedIndex(10),
              selected: selectedItemIndex == 10,
              selectedColor: const Color(0xff80d6ff),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profile'),
              onTap: () => setDrawerSelectedIndex(11),
              selected: selectedItemIndex == 11,
              selectedColor: const Color(0xff80d6ff),
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz_outlined),
              title: const Text('Go To Feedback'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/admin-feedback',
                  ModalRoute.withName('/admin-choose-app'),
                );
              },
              selectedColor: const Color(0xff80d6ff),
            ),
            ListTile(
              leading: const Icon(Icons.fact_check_outlined),
              title: const Text('Go To Checklist'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/admin-checklist',
                  ModalRoute.withName('/admin-choose-app'),
                );
              },
              selectedColor: const Color(0xff80d6ff),
            ),
            ListTile(
              leading: const Icon(Icons.video_call),
              title: const Text('Go To ToolBox Meeting'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/admin-meeting',
                  ModalRoute.withName('/admin-choose-app'),
                );
              },
              selectedColor: const Color(0xff80d6ff),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: logout,
              selectedColor: const Color(0xff80d6ff),
            ),
          ],
        ),
      ),
    );
  }
}















// import 'package:flutter/material.dart';
// import 'package:goltens_mobile/components/admin/dashboard.dart';
// import 'package:goltens_mobile/components/admin/edit_profile.dart';
// import 'package:goltens_mobile/components/admin/master_list.dart';
// import 'package:goltens_mobile/components/admin/groups.dart';
// import 'package:goltens_mobile/components/admin/messages.dart';
// import 'package:goltens_mobile/components/admin/other_files.dart';
// import 'package:goltens_mobile/components/admin/pending_requests.dart';
// import 'package:goltens_mobile/components/admin/risk_assessments.dart';
// import 'package:goltens_mobile/components/admin/sub_admins.dart';
// import 'package:goltens_mobile/components/admin/user_orientation.dart';
// import 'package:goltens_mobile/components/admin/users.dart';
// import 'package:goltens_mobile/components/admin/users_and_subadmins.dart';
// import 'package:goltens_mobile/components/ptpMessage/ptpmessagepage.dart';
// import 'package:goltens_mobile/pages/auth/auth_page.dart';
// import 'package:goltens_mobile/provider/global_state.dart';
// import 'package:goltens_core/services/auth.dart';
// import 'package:provider/provider.dart';

// class AdminDrawer extends StatefulWidget {
//   final int currentIndex;

//   const AdminDrawer({
//     super.key,
//     required this.currentIndex,
//   });

//   @override
//   State<AdminDrawer> createState() => _AdminDrawerState();
// }

// class _AdminDrawerState extends State<AdminDrawer> {
//   void setDrawerSelectedIndex(int index) {
//     var selectedIndex = widget.currentIndex;
//     if (selectedIndex == index) return;

//     Navigator.pop(context);

//     switch (index) {
//       case 0:
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const CommunicationDashboard(),
//           ),
//         );
//         break;
//       case 1:
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const PendingRequests(),
//           ),
//         );
//         break;
//       case 2:
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const Users(),
//           ),
//         );
//         break;
//       case 3:
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const SubAdmins(),
//           ),
//         );
//         break;
//       case 4:
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const UsersAndSubAdmins(),
//           ),
//         );
//         break;
//       case 5:
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const Groups(),
//           ),
//         );
//         break;
//       case 6:
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const Messages(),
//           ),
//         );
//         break;
//       case 7:
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) =>  ptpMessagePage(toID: '23',),
//           ),
//         );
//         break;
//         case 8:
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const MasterList(),
//           ),
//         );
//         break;
//       case 9:
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const RiskAssessments(),
//           ),
//         );
//         break;
//       case 10:
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const OtherFiles(),
//           ),
//         );
//         break;
//       case 11:
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const UserOrientation(),
//           ),
//         );
//         break;
//       case 12:
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const EditProfile(),
//           ),
//         );
//         break;
//       default:
//     }
//   }

//   void logout() {
//     Navigator.pop(context);

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text("Are you sure you want to logout ?"),
//           actions: [
//             TextButton(
//               child: const Text("CANCEL"),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//             TextButton(
//               child: const Text("OK"),
//               onPressed: () async {
//                 await AuthService.logout();

//                 // ignore: use_build_context_synchronously
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(builder: (context) {
//                     return const AuthPage();
//                   }),
//                   (route) => false,
//                 );
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     var selectedItemIndex = widget.currentIndex;
//     var user = context.read<GlobalState>().user?.data;

//     return Drawer(
//       child: SingleChildScrollView(
//         child: Column(
//           children: [
//             DrawerHeader(
//               decoration: BoxDecoration(
//                 color: Theme.of(context).primaryColor,
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   const Text(
//                     'Goltens Admin Panel',
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 24,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     user?.name ?? '---',
//                     style: const TextStyle(
//                       color: Colors.black,
//                       fontSize: 16,
//                     ),
//                   ),
//                   Text(
//                     user?.email ?? '---',
//                     style: const TextStyle(
//                       color: Colors.black,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             ListTile(
//               selectedColor: const Color(0xff80d6ff),
//               leading: const Icon(Icons.dashboard_sharp),
//               title: const Text('Dashboard'),
//               onTap: () => setDrawerSelectedIndex(0),
//               selected: selectedItemIndex == 0,
//             ),
//             ListTile(
//               selectedColor: const Color(0xff80d6ff),
//               leading: const Icon(Icons.done_all),
//               title: const Text('Pending Requests'),
//               onTap: () => setDrawerSelectedIndex(1),
//               selected: selectedItemIndex == 1,
//             ),
//             ListTile(
//               leading: const Icon(Icons.account_circle_rounded),
//               title: const Text('Users'),
//               onTap: () => setDrawerSelectedIndex(2),
//               selected: selectedItemIndex == 2,
//               selectedColor: const Color(0xff80d6ff),
//             ),
//             ListTile(
//               leading: const Icon(Icons.manage_accounts),
//               title: const Text('SubAdmins'),
//               onTap: () => setDrawerSelectedIndex(3),
//               selected: selectedItemIndex == 3,
//               selectedColor: const Color(0xff80d6ff),
//             ),
//             ListTile(
//               leading: const Icon(Icons.manage_accounts),
//               title: const Text('Users & SubAdmins'),
//               onTap: () => setDrawerSelectedIndex(4),
//               selected: selectedItemIndex == 4,
//               selectedColor: const Color(0xff80d6ff),
//             ),
//             ListTile(
//               leading: const Icon(Icons.group),
//               title: const Text('Groups'),
//               onTap: () => setDrawerSelectedIndex(5),
//               selected: selectedItemIndex == 5,
//               selectedColor: const Color(0xff80d6ff),
//             ),
//             ListTile(
//               leading: const Icon(Icons.message),
//               title: const Text('Messages'),
//               onTap: () => setDrawerSelectedIndex(6),
//               selected: selectedItemIndex == 6,
//               selectedColor: const Color(0xff80d6ff),
//             ),
//               ListTile(
//               leading: const Icon(Icons.chat_bubble_rounded),
//               title: const Text('Chat'),
//               onTap: () => setDrawerSelectedIndex(7),
//               selected: selectedItemIndex == 7,
//               selectedColor: const Color(0xff80d6ff),
//             ),
//             ListTile(
//               leading: const Icon(Icons.file_copy),
//               title: const Text('Master List'),
//               onTap: () => setDrawerSelectedIndex(7),
//               selected: selectedItemIndex == 8,
//               selectedColor: const Color(0xff80d6ff),
//             ),
//             ListTile(
//               leading: const Icon(Icons.list_alt_sharp),
//               title: const Text('Risk Assessment'),
//               onTap: () => setDrawerSelectedIndex(8),
//               selected: selectedItemIndex == 9,
//               selectedColor: const Color(0xff80d6ff),
//             ),
//             ListTile(
//               leading: const Icon(Icons.list_alt_sharp),
//               title: const Text('Company Informations'),
//               onTap: () => setDrawerSelectedIndex(9),
//               selected: selectedItemIndex == 10,
//               selectedColor: const Color(0xff80d6ff),
//             ),
//             ListTile(
//               leading: const Icon(Icons.list_alt_sharp),
//               title: const Text('HR Documents'),
//               onTap: () => setDrawerSelectedIndex(10),
//               selected: selectedItemIndex == 11,
//               selectedColor: const Color(0xff80d6ff),
//             ),
//             ListTile(
//               leading: const Icon(Icons.edit),
//               title: const Text('Edit Profile'),
//               onTap: () => setDrawerSelectedIndex(11),
//               selected: selectedItemIndex == 12,
//               selectedColor: const Color(0xff80d6ff),
//             ),
//             ListTile(
//               leading: const Icon(Icons.swap_horiz_outlined),
//               title: const Text('Go To Feedback'),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.pushNamedAndRemoveUntil(
//                   context,
//                   '/admin-feedback',
//                   ModalRoute.withName('/admin-choose-app'),
//                 );
//               },
//               selectedColor: const Color(0xff80d6ff),
//             ),
//             ListTile(
//               leading: const Icon(Icons.fact_check_outlined),
//               title: const Text('Go To Checklist'),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.pushNamedAndRemoveUntil(
//                   context,
//                   '/admin-checklist',
//                   ModalRoute.withName('/admin-choose-app'),
//                 );
//               },
//               selectedColor: const Color(0xff80d6ff),
//             ),
//             ListTile(
//               leading: const Icon(Icons.video_call),
//               title: const Text('Go To ToolBox Meeting'),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.pushNamedAndRemoveUntil(
//                   context,
//                   '/admin-meeting',
//                   ModalRoute.withName('/admin-choose-app'),
//                 );
//               },
//               selectedColor: const Color(0xff80d6ff),
//             ),
//             ListTile(
//               leading: const Icon(Icons.logout),
//               title: const Text('Logout'),
//               onTap: logout,
//               selectedColor: const Color(0xff80d6ff),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
