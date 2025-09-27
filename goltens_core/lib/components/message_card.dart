import 'package:flutter/material.dart';
import 'package:goltens_core/constants/constants.dart';

class MessageCard extends StatefulWidget {
  final String messageId;
  final String title;
  final String content;
  final bool showFullContent;
  final String? imageUrl;
  final String createdByName;
  final String createdByAvatar;
  final String time;
  final bool? isUnread;
  final List<dynamic> files;
  final VoidCallback onTap;
  final bool showPadding;

  const MessageCard({
    super.key,
    required this.messageId,
    required this.title,
    required this.content,
    required this.showFullContent,
    required this.imageUrl,
    required this.isUnread,
    required this.files,
    required this.createdByName,
    required this.createdByAvatar,
    required this.time,
    required this.onTap,
    this.showPadding = true,
  });

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: widget.showPadding ? 10.0 : 0,
        horizontal: widget.showPadding ? 10.0 : 0,
      ),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(15.0),
          onTap: widget.onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.files.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0),
                      ),
                      child: widget.imageUrl != null
                          ? Image.network(
                              '$apiUrl/$groupData/${widget.imageUrl}',
                              fit: BoxFit.fitHeight,
                              height: 250,
                              width: double.infinity,
                              scale: 5,
                              errorBuilder: (
                                context,
                                obj,
                                stacktrace,
                              ) {
                                return Container();
                              },
                            )
                          : SizedBox(
                              height: 160,
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.file_copy_rounded,
                                    size: 48.0,
                                    color: Colors.black54,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    '${widget.files.length} File(s)',
                                    style: const TextStyle(fontSize: 18.0),
                                  )
                                ],
                              ),
                            ),
                    )
                  : Container(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 200,
                      child: Text(
                        '${widget.title} - ${widget.messageId}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    widget.isUnread == true
                        ? Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                '',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        : Container()
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 6.0,
                  horizontal: 16.0,
                ),
                child: Text(
                  widget.content,
                  style: const TextStyle(fontSize: 16.0),
                  maxLines: widget.showFullContent ? null : 2,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
                child: Row(
                  children: [
                    Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(60),
                      child: CircleAvatar(
                        child: widget.createdByAvatar.isNotEmpty == true
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  100.0,
                                ),
                                child: Image.network(
                                  '$apiUrl/$avatar/${widget.createdByAvatar}',
                                  fit: BoxFit.contain,
                                  height: 500,
                                  width: 500,
                                  errorBuilder: (
                                    context,
                                    obj,
                                    stacktrace,
                                  ) {
                                    return Container();
                                  },
                                ),
                              )
                            : Text(widget.createdByName[0]),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.createdByName,
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      widget.time,
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
