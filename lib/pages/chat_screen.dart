import 'package:chat_bot/providers/message_provider.dart';
import 'package:chat_bot/services/gemini_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController textEditingController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MessageProvider>(context);
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade800,
        title: const Text("GemTalk"),
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              Expanded(
                  child: SizedBox(
                width: w,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: provider.getMessage().isEmpty
                      ? Center(
                          child: Text(
                          "What can i help with?",
                          style: TextStyle(
                              fontSize: 25,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold),
                        ))
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: provider.getMessage().length,
                          itemBuilder: (context, index) {
                            DateTime now = provider.getMessage()[index].time;
                            String formattedTime =
                                DateFormat('hh:mm a').format(now);
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 8),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 5),
                              child: Row(
                                mainAxisAlignment:
                                    provider.getMessage()[index].user == "user"
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        provider.getMessage()[index].user ==
                                                "user"
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        provider.getMessage()[index].user ==
                                                "user"
                                            ? "User"
                                            : "AI",
                                        style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14, horizontal: 14),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topRight:
                                                  const Radius.circular(10),
                                              bottomLeft:
                                                  const Radius.circular(10),
                                              topLeft: Radius.circular(provider
                                                          .getMessage()[index]
                                                          .user ==
                                                      "user"
                                                  ? 0
                                                  : 10),
                                              bottomRight: Radius.circular(
                                                  provider
                                                              .getMessage()[
                                                                  index]
                                                              .user ==
                                                          "user"
                                                      ? 10
                                                      : 0),
                                            ),
                                            color: provider
                                                        .getMessage()[index]
                                                        .user ==
                                                    "user"
                                                ? Colors.grey.shade800
                                                : Colors.grey.shade900
                                                    .withOpacity(0.8)),
                                        constraints:
                                            BoxConstraints(maxWidth: w * 2 / 3),
                                        child: Text(provider
                                            .getMessage()[index]
                                            .message),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(formattedTime),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                ),
              )),
              if (provider.isLoading)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Lottie.asset("assets/typing.json", height: 40),
                    ],
                  ),
                ),
              SizedBox(
                height: 80,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                        child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.circular(10)),
                      child: TextField(
                        controller: textEditingController,
                        decoration: const InputDecoration(
                            hintText: 'Enter a Message',
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none)),
                      ),
                    )),
                    const SizedBox(
                      width: 10,
                    ),
                    CircleAvatar(
                      maxRadius: 23.0,
                      backgroundColor: Colors.grey.shade900,
                      child: IconButton(
                        onPressed: () async {
                          final userMessage = textEditingController.text.trim();
                          if (userMessage.isNotEmpty) {
                            provider.storeMessage(ChatMessage(
                                message: userMessage,
                                user: "user",
                                time: DateTime.now()));

                            textEditingController.clear();
                            _scrollToBottom();

                            final geminiService = GeminiService();
                            final aiResponse =
                                await geminiService.generateMessage(
                              userMessage,
                              provider,
                            );
                            if (aiResponse != null) {
                              provider.storeMessage(ChatMessage(
                                message: aiResponse,
                                user: "AI",
                                time: DateTime.now(),
                              ));
                              _scrollToBottom();
                            }
                          }
                        },
                        icon: const Icon(Icons.send),
                        iconSize: 30,
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
