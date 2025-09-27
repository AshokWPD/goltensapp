import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';

class chatBox extends StatelessWidget {
  bool isSend;
  bool? isread;
  String message;
  String time;
  String? replay;
  String? replayTime;
  chatBox(
      {super.key,
      required this.isSend,
      this.isread,
      required this.message,
      required this.time,
      this.replay,
      this.replayTime});

  @override
  Widget build(BuildContext context) {
    return isSend
        ? ChatBubble(
            clipper: ChatBubbleClipper1(type: BubbleType.sendBubble),
            alignment: Alignment.topRight,
            margin: const EdgeInsets.only(top: 20),
            backGroundColor: Colors.blue,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "$message ",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        time,
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        width: 2.8,
                      ),
                      isread ?? false
                          ? const Icon(
                              Icons.done_all,
                              color: Colors.black,
                            )
                          : const Icon(
                              Icons.done,
                              color: Colors.black,
                            ),
                    ],
                  ),
                  if (replay != null && replay != '')
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: Colors.grey.shade100),
                      child: Text(
                        replay ?? "",
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w500),
                      ),
                    ),
                  if (replayTime != null && replayTime != '')
                    const SizedBox(
                      height: 1,
                    ),
                  if (replayTime != null && replayTime != '')
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: Colors.grey.shade100),
                      child: Text(
                        replayTime ?? "",
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w500),
                      ),
                    ),
                ],
              ),
            ),
          )
        : ChatBubble(
            clipper: ChatBubbleClipper1(type: BubbleType.receiverBubble),
            backGroundColor: const Color(0xffE7E7ED),
            margin: const EdgeInsets.only(top: 20),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: const TextStyle(color: Colors.black),
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.w500),
                  ),
                  if (replay != null && replay != '')
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: Colors.blue),
                      child: Text(
                        replay ?? "",
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ),
                  if (replayTime != null && replayTime != '')
                    const SizedBox(
                      height: 1,
                    ),
                  if (replayTime != null && replayTime != '')
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: Colors.grey.shade100),
                      child: Text(
                        replayTime ?? "",
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w500),
                      ),
                    ),
                ],
              ),
            ),
          );
  }
}
