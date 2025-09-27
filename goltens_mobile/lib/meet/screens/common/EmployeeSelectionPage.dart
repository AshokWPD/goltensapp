import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goltens_core/services/meeting.dart';
import 'package:goltens_core/theme/theme.dart';
import 'package:goltens_mobile/meet/screens/common/OfflineExit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:goltens_core/constants/constants.dart';
import 'package:goltens_core/models/admin.dart';
import 'package:goltens_core/services/admin.dart';
import 'package:goltens_mobile/components/search_bar_delegate.dart';
import 'package:intl/intl.dart';

class EmpSelectionPage extends StatefulWidget {
  final String invitelink;
  final bool isSchedule;
  final String channelname;
  final bool isoffline;
  final bool isscheduled;
  final String location;
  final String Dep;
  final String DateTime;
  final String CreaterName;
  final String meetId;

  const EmpSelectionPage(
      {super.key,
      required this.invitelink,
      required this.isSchedule,
      required this.channelname,
      required this.isoffline,
      required this.isscheduled,
      required this.location,
      required this.Dep,
      required this.DateTime,
      required this.CreaterName,
      required this.meetId});

  @override
  State<EmpSelectionPage> createState() => _EmpSelectionPageState();
}

class _EmpSelectionPageState extends State<EmpSelectionPage> {
  int currentPage = 1;
  int totalPages = 1;
  int limit = 1000000;
  bool isLoading = false;
  bool isError = false;
  String? search;
  List<GetUsersResponseData> users = [];
  List<int> selectedUsers = [];
  CroppedFile? avatarPicture;
  bool isAllSelected = false;
  final ApiService apiService = ApiService();
  String? selectedDepartment;

  List<GetUsersResponseData> allUsers = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fetchUsers();
    });
  }

  Future<void> startSearch() async {
    var searchQuery = await showSearch(
      context: context,
      delegate: SearchBarDelegate(),
      query: search,
    );

    if (searchQuery != null) {
      setState(() {
        search = searchQuery;
        currentPage = 1;
      });

      fetchUsers();
    }
  }

  Future<void> fetchUsers() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      var res = await AdminService.getUserswithsubAdmins(
        page: currentPage,
        limit: limit,
        search: search,
      );

      List<GetUsersResponseData> filteredUsers = res.data;
      if (selectedDepartment != null) {
        filteredUsers = filteredUsers
            .where((user) => user.department == selectedDepartment)
            .toList();
      }

      setState(() {
        users = filteredUsers;
        isError = false;
        isLoading = false;
        totalPages = res.totalPages;
      });
    } catch (err) {
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

//   Future<void> fetchUsers() async {
//     if (isLoading) return;
//
//     setState(() {
//       isLoading = true;
//     });
//
//     try {
//       var res = await AdminService.getUsersAndSubAdmins(
//         page: currentPage,
//         limit: limit,
//         search: search,
//       );
//
//       List<GetUsersResponseData> filteredUsers = res.data;
//       if (selectedDepartment != null) {
//         filteredUsers = filteredUsers
//             .where((user) => user.department == selectedDepartment)
//             .toList();
//       }
//
//       var res1 = await AdminService.getUsers(
//         page: currentPage,
//         limit: limit,
//         search: search,
//       );
//
//       List<GetUsersResponseData> filteredUsers1 = res1.data;
//       if (selectedDepartment != null) {
//         filteredUsers1 = filteredUsers1
//             .where((user) => user.department == selectedDepartment)
//             .toList();
//       }
//
//       setState(() {
//         users = filteredUsers + filteredUsers1;
//         isError = false;
//         isLoading = false;
//         totalPages = res.totalPages;
//       });
//
// //      await  fetchUsersget(filteredUsers);
//     } catch (err) {
//       setState(() {
//         isError = true;
//         isLoading = false;
//       });
//     }
//   }

  void nextPage() {
    if (currentPage < totalPages) {
      setState(() => currentPage++);
      fetchUsers();
    }
  }

  void prevPage() {
    if (currentPage > 1) {
      setState(() => currentPage--);
      fetchUsers();
    }
  }

  Future<CroppedFile?> chooseAvatar() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null && mounted) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        maxHeight: 500,
        maxWidth: 500,
        // cropStyle: CropStyle.circle,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Avatar',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
            hideBottomControls: true,
          ),
          IOSUiSettings(
            title: 'Crop Avatar',
          ),
            WebUiSettings(
  context: context,
  presentStyle: WebPresentStyle.dialog,
  size: CropperSize(width: 520, height: 520),
  zoomable: true,
  movable: true,
  rotatable: true,
  scalable: true,
  zoomOnTouch: true,
  zoomOnWheel: true,
  wheelZoomRatio: 0.1,
  cropBoxMovable: true,
  cropBoxResizable: true,
  // add additional params to approximate previous behavior
)
          // WebUiSettings(
          //   context: context,
          //   presentStyle: CropperPresentStyle.dialog,
          //   boundary: const CroppieBoundary(
          //     width: 520,
          //     height: 520,
          //   ),
          //   viewPort: const CroppieViewPort(
          //     width: 480,
          //     height: 480,
          //     type: 'circle',
          //   ),
          //   enableExif: true,
          //   enableZoom: true,
          //   showZoomer: true,
          // ),
        ],
      );

      if (croppedFile != null) {
        return croppedFile;
      }
    }

    return null;
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (users.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'No Users Available',
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ),
      );
    }
// Inside the buildBody method
    return RefreshIndicator(
      onRefresh: fetchUsers,
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          return false;
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: users.map((user) {
                final avatarUrl = user.avatar?.isNotEmpty == true
                    ? '$apiUrl/$avatar/${user.avatar}'
                    : null;

                bool isSelected = selectedUsers.contains(user.id);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      isSelected = !isSelected;
                      if (isSelected) {
                        selectedUsers.add(user.id);
                      } else {
                        selectedUsers.remove(user.id);
                      }
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(15.0),
                      color: isSelected
                          ? Colors.blue.withOpacity(0.3)
                          : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.black,
                          radius: 30,
                          child: avatarUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(100.0),
                                  child: Image.network(
                                    avatarUrl,
                                    fit: BoxFit.cover,
                                    height: 60,
                                    width: 60,
                                    errorBuilder: (
                                      context,
                                      obj,
                                      stacktrace,
                                    ) {
                                      return Container();
                                    },
                                  ),
                                )
                              : Text(user.name[0]),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Department: ${user.department}',
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Employee Number: ${user.employeeNumber}',
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              // Text(
                              //   'Type: ${user.type.name}',
                              //   style: const TextStyle(fontSize: 16),
                              // ),
                            ],
                          ),
                        ),
                        Checkbox(
                          value: isAllSelected || isSelected,
                          onChanged: (value) {
                            if (isAllSelected) {
                              toggleSelectAll(); // Deselect all if "Select All" is active
                            } else {
                              setState(() {
                                isSelected = value!;
                                if (isSelected) {
                                  selectedUsers.add(user.id);
                                } else {
                                  selectedUsers.remove(user.id);
                                }
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  void sendNotifications() async {
    String formattedDate =
        DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now());
    // String formattedDate = DateFormat('hh:mm a dd-MM-yyyy').format(DateTime.now());

    print("================$selectedUsers===================");

    await apiService.sendNotification(
      selectedUsers,
      widget.channelname,
      'Join Now "${widget.isoffline ? "as Offline Meeting" : "as Online Meeting"}"',
      "meeting_join",
      widget.isoffline ? widget.invitelink : widget.meetId,
      widget.isoffline ? widget.invitelink : widget.meetId,
      widget.channelname,
      widget.isoffline ? "Offline Meeting" : "Online Meeting",
      widget.CreaterName,
      widget.isscheduled ? widget.DateTime.toString() : formattedDate,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invite Shared Successfully...'),
        duration: Duration(seconds: 2),
      ),
    );
    if (widget.isoffline) {
      // Get.to(SAOfflineExitAttend(meetingId: widget.invitelink,
      //   isscheduled: widget.isscheduled,
      //   CreaterName:widget.CreaterName,
      //   DateTime: widget.DateTime,));
      // Get.to(SAOfflineExitAttend(meetingId: inviteLinkController.text.trim(),));
      Navigator.pop(context);
    } else {
      Navigator.pop(context);

      // !widget.isSchedule
      //     ? await Get.to((AgoraMeet(
      //   channelName:
      //   widget.invitelink,
      // )))
      //     : ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('Meeeting Successfully Scheduled...'),
      //     duration: Duration(seconds: 2),
      //   ),
      // );
    }
  }

  void toggleSelectAll() {
    setState(() {
      if (isAllSelected) {
        selectedUsers.clear();
      } else {
        selectedUsers = users.map((user) => user.id).toList();
      }
      isAllSelected = !isAllSelected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (search?.isNotEmpty == true) {
          setState(() {
            search = null;
            currentPage = 1;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await fetchUsers();
          });
          return false;
        }

        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              search?.isNotEmpty == true
                  ? 'Results for "$search"'
                  : 'Users & Sub Admin',
              style: const TextStyle(color: Colors.black)),
          backgroundColor: primaryColor,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: startSearch,
            ),
            IconButton(
              icon: Icon(isAllSelected
                  ? Icons.check_box
                  : Icons.check_box_outline_blank),
              onPressed: toggleSelectAll,
            ),
            DropdownButton<String>(
              value: selectedDepartment,
              icon: const Icon(
                Icons.filter_alt,
                color: Colors.black,
              ),
              onChanged: filterByDepartment,
              items: departmentList.map((String department) {
                return DropdownMenuItem<String>(
                  value: department,
                  child: Text(
                    department,
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(
              width: 10,
            )
          ],
        ),
        // drawer: const AdminDrawer(currentIndex: 2),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: selectedUsers.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(height: 4.0),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(primaryColor),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                20.0), // Adjust the value as needed
                          ),
                        ),
                      ),
                      onPressed: sendNotifications,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.manage_accounts,
                            color: Colors.black,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Send Meeting Code',
                            style: TextStyle(color: Colors.black),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 4.0),
                  ],
                ),
              )
            : Container(),
        body: buildBody(),
      ),
    );
  }

  void filterByDepartment(String? department) {
    setState(() {
      selectedDepartment = department;
      currentPage = 1; // Reset page when applying a filter
    });
    fetchUsers(); // Fetch users based on the new filter
  }
}
