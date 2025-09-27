import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goltens_core/theme/theme.dart';
import 'package:goltens_core/utils/functions.dart';
import 'package:goltens_mobile/components/ptpMessage/chatNotifier.dart';
import 'package:goltens_mobile/components/ptpMessage/chatbox.dart';
import 'package:goltens_mobile/components/ptpMessage/ptpmessageServer.dart';
import 'package:goltens_mobile/provider/global_state.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ptpMessagePage extends ConsumerWidget {
  final String toID;
  ptpMessagePage({super.key, required this.toID});

  final TextEditingController _message = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    PtpMessageService chatServer = PtpMessageService();
    var user = context.read<GlobalState>().user?.data;

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    final chatProviderNotifier = ref.read(chatProvider.notifier);
    final chatState = ref.watch(chatProvider);

    // Start polling when the page is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatProviderNotifier.startPolling("2");
    });
    return Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: height * 0.8,
                child: chatState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    // :
                    //  chatState.error != null
                    //     ? Center(child: Text('Error: ${chatState.error}'))
                    : chatState.messages.isEmpty
                        ? const Center(child: Text('No messages available.'))
                        : ListView.builder(
                            reverse: true,
                            itemCount: chatState.messages.length,
                            itemBuilder: (context, index) {
                              final message = chatState.messages[index];
                              return chatBox(
                                isSend: message.fromID == user!.id.toString(),
                                message: message.message,
                                time: formatDateTime(
                                    message.createdAt!, "hh:mm a"),
                                isread: message.isRead,
                                replay: message.replay,
                              );
                            },
                          ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _message,
                  decoration: InputDecoration(
                      hintText: "Type a Message",
                      hintStyle: const TextStyle(color: Colors.grey),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // SizedBox(width: 5,),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: CircleAvatar(
                              backgroundColor: primaryColor,
                              child: Center(
                                child: IconButton(
                                  icon: const Icon(Icons.attach_file),
                                  color: Colors.black,
                                  onPressed: ()async {
                                  
                                   await chatServer.createPtpMessage(
                                        user!.id.toString(),
                                        toID,
                                        _message.text);
                                          _message.clear();

                                  },
                                ),
                              ),
                            ),
                          ),
                           Padding(
                            padding: EdgeInsets.all(5.0),
                            child: CircleAvatar(
                              backgroundColor: primaryColor,
                              child: Center(
                                child: IconButton(
                                  
                                  color: Colors.black,  onPressed: ()async {
                                  
                                   await chatServer.createPtpMessage(
                                        user!.id.toString(),
                                        toID,
                                        _message.text);
                                          _message.clear();

                                  }, icon: Icon(Icons.send,),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
                ),
              )
            ],
          ),
        ));
  }
}

 



  //  Column(
    //   children: [
    //     chatBox(isSend: true, message: 'message send by me', time: '11:15 AM', isread: false,replay: "ljbjsh sdhjjb gv hg hg vhgcv gfvgfc nbvg  dv dfv dfv dfv dfv  dfvdfvdfv dfv dfvdf df dfvhf",replayTime: "11:23 PM",),
    //     chatBox(isSend: false, message: 'message send by friend', time: '10:50 PM', isread: null,replay: "hdfbjhb dfjhvb hg vhg vj hvh gvj hv",),
    //   ],
    // ),
  // @override
  // Widget build(BuildContext context, WidgetRef ref) {
  //   final chatProviderNotifier = ref.read(chatProvider.notifier);
  //   final chatState = ref.watch(chatProvider);

  //   // Start polling when the page is built
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     chatProviderNotifier.startPolling(userId);
  //   });
  //   return Scaffold(appBar: AppBar(),
  //   body: Column(
  //     children: [
  //       chatBox(isSend: true, message: 'message send by me', time: '11:15 AM', isread: false,replay: "ljbjsh sdhjjb gv hg hg vhgcv gfvgfc nbvg  dv dfv dfv dfv dfv  dfvdfvdfv dfv dfvdf df dfvhf",replayTime: "11:23 PM",),
  //       chatBox(isSend: false, message: 'message send by friend', time: '10:50 PM', isread: null,replay: "hdfbjhb dfjhvb hg vhg vj hvh gvj hv",),
  //     ],
  //   ),);
  // }
