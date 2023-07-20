import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({Key? key}) : super(key: key);

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messageController = TextEditingController();

  late String _userName = '';
  late String _userImageUrl = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userData.data() != null) {
          if (userData.data()!.containsKey('profilePicture')) {
            setState(() {
              _userImageUrl = userData['profilePicture'];
            });
          }

          if (userData.data()!.containsKey('username')) {
            setState(() {
              _userName = userData['username'];
            });
          }
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatroom'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error retrieving messages');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final List<QueryDocumentSnapshot<Map<String, dynamic>>>
                    documents = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final message = documents[index].data();
                    final bool isCurrentUser = message['userId'] ==
                        FirebaseAuth.instance.currentUser?.uid;

                    return FutureBuilder<
                        DocumentSnapshot<Map<String, dynamic>>>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(message['userId'])
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(); // Placeholder widget while loading user data
                        }

                        final userData = snapshot.data!.data();
                        final String profilePictureUrl =
                            userData?['profilePicture'] ?? '';
                        final String username = userData?['username'] ?? '';

                        return ListTile(
                          title: Column(
                            crossAxisAlignment: isCurrentUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: isCurrentUser
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  if (!isCurrentUser)
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundImage:
                                          profilePictureUrl.isNotEmpty
                                              ? NetworkImage(profilePictureUrl)
                                              : null,
                                    ),
                                  const SizedBox(width: 8),
                                  Text(
                                    username,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color:
                                      isCurrentUser ? Colors.blue : Colors.grey,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.all(8),
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  message['message'],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String message = messageController.text.trim();
                    if (message.isNotEmpty) {
                      messageController.clear();

                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          await FirebaseFirestore.instance
                              .collection('messages')
                              .add({
                            'userId': user.uid,
                            'message': message,
                            'timestamp': DateTime.now(),
                          });
                        }
                      } catch (e) {
                        print('Error saving message: $e');
                      }
                    }
                  },
                  child: const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
