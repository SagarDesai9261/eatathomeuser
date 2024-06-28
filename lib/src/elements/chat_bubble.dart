import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/color.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String sendTime;
  final String senderName;
  String fileMessage;
  String fileName;
  final bool hasFile;

  MessageBubble(
      {
      required this.message,
      required this.isMe,
      required this.sendTime,
      required this.senderName,
      required this.fileMessage,
        required  this.fileName,
      required this.hasFile})
      ;

  @override
  Widget build(BuildContext context) {
    //List<String> parts = fileMessage!.split('/');
    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: !isMe,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
            child: isMe
                ? Text("")
                : Text(
              senderName,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isMe ? Colors.grey[300] : kPrimaryColororange,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: isMe ? Radius.circular(12) : Radius.circular(0),
                  bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
                ),
              ),
              width: 140,
              padding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 16,
              ),
              margin: EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 8,
              ),
              child: hasFile
                  ? GestureDetector(
                      onTap: () {
                        /*Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullScreenImageScreen(
                                imageUrl: fileMessage.toString()),
                          ),
                        );*/
                      },
                      child: Column(
                        children: [
                          // Check if the file is an image (e.g., jpg, png, etc.)
                          if (fileMessage
                                  .toString()
                                  .toLowerCase()
                                  .endsWith('.jpg') ||
                              fileMessage
                                  .toString()
                                  .toLowerCase()
                                  .endsWith('.png') ||
                              fileMessage
                                  .toString()
                                  .toLowerCase()
                                  .endsWith('.jpeg'))
                            Image.network(fileMessage.toString()),
                          // Display a thumbnail of the image

                          // Check if the file is a PDF
                          if (fileMessage
                              .toString()
                              .toLowerCase()
                              .endsWith('.pdf'))
                            Icon(Icons.picture_as_pdf, size: 64),
                          // Display a PDF icon

                          SizedBox(height: 5),
                          // Add some spacing between the thumbnail and the name/download sign
                          Row(

                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                fileName.toString().length > 8
                                    ? '${fileName.toString().substring(0, 8)}...' // Truncate the string after 10 characters
                                    : fileName.toString(),  // Display the name of the file
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(width: 5),
                              // Add some spacing between the name and the download sign
                              GestureDetector(
                                  onTap: () async {
                                    if (fileMessage.toString().toLowerCase().endsWith('.jpg') ||
                                        fileMessage.toString().toLowerCase().endsWith('.png')) {
                                      // Download an image
                                      await launch(fileMessage.toString());
                                    } else if (fileMessage.toString().toLowerCase().endsWith('.pdf')) {
                                      // Download a PDF
                                      await launch(fileMessage.toString());
                                    }
                                  },
                                  child: Icon(Icons.file_download)),
                              // Display a download sign
                            ],
                          ),
                        ],
                      ))
                  : Text(
                      message,
                      style: TextStyle(
                        color: isMe ? Colors.black : Colors.white,
                      ),
                    ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
          child: Text(
            sendTime,
            style: TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }
}

/*class FullScreenImageScreen extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageScreen({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Container(
          color: Colors.black,
          child: Center(
            child: Hero(
              tag: imageUrl,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}*/
