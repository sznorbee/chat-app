import 'package:chat_app/screens/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (ctx, chatSnapshots) {
          if (chatSnapshots.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
            return const Center(
                child: Text('No messages yet! Start sending some!'));
          }

          if (chatSnapshots.hasError) {
            return const Center(child: Text('Something went wrong ... !'));
          }

          final chatDocs = chatSnapshots.data!.docs;
          return ListView.builder(
              padding: const EdgeInsets.only(
                  top: 15, bottom: 40, left: 15, right: 15),
              reverse: true,
              itemCount: chatDocs.length,
              itemBuilder: (ctx, index) {
                final chatMessage = chatDocs[index].data();
                final nextMessage = index + 1 < chatDocs.length
                    ? chatDocs[index + 1].data()
                    : null;
                final currentMessageUserId = chatMessage['userId'];
                final nextMessageUserId =
                    nextMessage != null ? nextMessage['userId'] : null;
                final nextUserIsSame =
                    currentMessageUserId == nextMessageUserId;

                return nextUserIsSame
                    ? MessageBubble.next(
                        message: chatMessage['text'],
                        isMe: chatMessage['userId'] == authenticatedUser.uid,
                      )
                    : MessageBubble.first(
                        userImage: chatMessage['userImage'],
                        username: chatMessage['userName'],
                        message: chatMessage['text'],
                        isMe: chatMessage['userId'] == authenticatedUser.uid,
                      );
              });
        });
  }
}
