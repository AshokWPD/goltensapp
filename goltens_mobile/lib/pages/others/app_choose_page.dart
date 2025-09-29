import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:goltens_core/constants/constants.dart';
import 'package:goltens_core/models/auth.dart';
import 'package:goltens_mobile/meet_main.dart';
import 'package:goltens_mobile/pages/others/user_type_choose_page.dart';
import 'package:goltens_mobile/provider/global_state.dart';
import 'package:goltens_core/services/auth.dart';
import 'package:goltens_mobile/utils/functions.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../App_Feedback.dart';

class AppChoosePage extends StatefulWidget {
  const AppChoosePage({super.key});

  @override
  State<AppChoosePage> createState() => _AppChoosePageState();
}

class _AppChoosePageState extends State<AppChoosePage> {
  bool isLoading = true;
  bool isUserAndSubAdmin = false;

  @override
  void initState() {
    super.initState();
    fetchUser();
    requestNotificationPermissions();
  }

  Future<void> fetchUser() async {
    try {
      final userResponse = await AuthService.getMe();

      setState(() {
        isLoading = false;
        isUserAndSubAdmin = userResponse.data.type == UserType.userAndSubAdmin;
      });

      badgeCountReset(userResponse.data.id);
    } catch (e) {
      // Nothing
    }
  }

  Future<void> requestNotificationPermissions() async {
    if (Platform.isAndroid) {
      final PermissionStatus status = await Permission.notification.request();

      if (status.isGranted) {
        // Notification permissions granted
      } else if (status.isDenied) {
        // Permission Denied
      } else if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
    }

    // if (Platform.isIOS) {
    //   FirebaseMessaging.instance.requestPermission();
    // }
  }

  void badgeCountReset(userid) async {
    var request = http.Request(
      'PUT',
      Uri.parse('https://goltens.in/api/v1/notifications/$userid/resetBadge'),
    );

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<bool> showExitDialog() async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Are you sure you want to exit ?"),
              actions: [
                TextButton(
                  child: const Text("CANCEL"),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text("OK"),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    var user = context.read<GlobalState>().user?.data;

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Choose Application')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (isUserAndSubAdmin) {
          return true;
        }

        return showExitDialog();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Choose Application'),
          actions: [
            PopupMenuButton<String>(
              onSelected: (String value) {
                switch (value) {
                  case 'Feedback':
                    // Navigator.pushNamed(context, '/app-feedback');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AppFeedback()),
                    );
                    break;
                  case 'Choose':
                    if (isUserAndSubAdmin) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserTypeChoosePage(),
                        ),
                      );
                    }
                    break;
                  case 'logout':
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text(
                            "Are you sure you want to logout ?",
                          ),
                          actions: [
                            TextButton(
                              child: const Text("CANCEL"),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            TextButton(
                              child: const Text("OK"),
                              onPressed: () async {
                                await AuthService.logout();

                                if (mounted) {
                                  await authNavigate(context);
                                }
                              },
                            ),
                          ],
                        );
                      },
                    );
                    break;
                  case 'exit':
                    if (Platform.isAndroid) {
                      SystemNavigator.pop();
                    } else if (Platform.isIOS) {
                      exit(0);
                    }
                    break;
                  default:
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem(
                    value: 'Feedback',
                    child: ListTile(
                      leading: Icon(Icons.feedback_outlined),
                      title: Text('App Feedback'),
                    ),
                  ),
                  if (isUserAndSubAdmin)
                    const PopupMenuItem(
                      value: 'Choose',
                      child: ListTile(
                        leading: Icon(Icons.person),
                        title: Text('Choose User Type'),
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'exit',
                    child: ListTile(
                      leading: Icon(Icons.exit_to_app),
                      title: Text('Exit'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Logout'),
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Material(
                        elevation: 8,
                        borderRadius: BorderRadius.circular(100.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          radius: 60.0,
                          child: user?.avatar.isNotEmpty == true
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(100.0),
                                  child: Image.network(
                                    '$apiUrl/$avatar/${user?.avatar}',
                                    errorBuilder: (context, obj, stacktrace) {
                                      return Container();
                                    },
                                  ),
                                )
                              : Text(
                                  user?.name[0] ?? '---',
                                  style: const TextStyle(
                                    fontSize: 60.0,
                                    color: Colors.black,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Logged in as ${user?.name}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: GridView.count(
            scrollDirection: Axis.vertical,
            crossAxisCount: 2,
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
            childAspectRatio: 0.9,
            padding: const EdgeInsets.all(12.0),
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 350),
                child: Card(
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/home');
                    },
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.message,
                              size: 48.0,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(height: 14.0),
                            const Text(
                              'Communication',
                              style: TextStyle(fontSize: 18.0),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 350),
                child: Card(
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/feedback');
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.feedback,
                          size: 48.0,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 14.0),
                        const Text(
                          'Feedback',
                          style: TextStyle(fontSize: 18.0),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 350),
                child: Card(
                  child: InkWell(
                    onTap: () {
                      // final user = context.read<GlobalState>().user?.data;

                      // MaterialApp(
                      //   home: GoltensMeet(),
                      //   navigatorKey: navigatorKey,
                      // );
                      //  Navigator.push(context, MaterialPageRoute(builder: (context)=>MeetMain(meetId: '',)));
                      Navigator.pushNamed(context, '/sub-admin-meeting');
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.video_call,
                          size: 48.0,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 14.0),
                        const Text(
                          'Toolbox Meeting',
                          style: TextStyle(fontSize: 18.0),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 350),
                child: Card(
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/sub-emp checklist');
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fact_check_outlined,
                          size: 48.0,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 14.0),
                        const Text(
                          'Checklist',
                          style: TextStyle(fontSize: 18.0),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
