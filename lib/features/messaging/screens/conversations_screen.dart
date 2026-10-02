import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../models/messaging_provider.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessagingProvider>().fetchConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MessagingProvider>();
    final conversations = provider.conversations;
    final isLoading = provider.status == MessagingStatus.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: isLoading && conversations.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : conversations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No conversations yet.'),
                      if (provider.errorMessage != null)
                        Text('Error: ${provider.errorMessage}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<MessagingProvider>().fetchConversations(),
                        child: const Text('Refresh'),
                      )
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final convo = conversations[index];
                    final targetUser = convo.targetUser;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: targetUser.profilePhotoUrl != null
                            ? CachedNetworkImageProvider(targetUser.profilePhotoUrl!)
                            : null,
                        child: targetUser.profilePhotoUrl == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(targetUser.name ?? 'Unknown'),
                      subtitle: Text(
                        convo.lastMessage ?? 'Say hi!',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: convo.unreadCount > 0
                          ? CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.red,
                              child: Text(
                                convo.unreadCount.toString(),
                                style: const TextStyle(fontSize: 12, color: Colors.white),
                              ),
                            )
                          : null,
                      onTap: () {
                        context.push('/chat/${convo.id}', extra: targetUser);
                      },
                    );
                  },
                ),
    );
  }
}
