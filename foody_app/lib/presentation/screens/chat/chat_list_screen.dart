import 'package:flutter/material.dart';
import 'package:foody_app/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:foody_app/providers/chat_list_provider.dart';
import 'package:foody_app/data/models/chat_dialogue_model.dart';
import 'chat_conversation_screen.dart';

// TODO: delete unnecesary colors
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showNewChatDialog() {
    final contactNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'New Chat',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        content: TextField(
          controller: contactNameController,
          decoration: InputDecoration(
            hintText: 'Enter contact name',
            hintStyle: GoogleFonts.poppins(color: AppTheme.textSecondaryColor.withValues(alpha: 0.5)),
            filled: true,
            fillColor: AppTheme.backgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppTheme.secondaryColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppTheme.secondaryColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          style: GoogleFonts.poppins(color: AppTheme.textPrimaryColor),
          autofocus: true,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(
                      color: AppTheme.textSecondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final name = contactNameController.text.trim();
                    if (name.isNotEmpty) {
                      context.read<ChatListProvider>().createNewDialogue(name);
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Create'),
                )
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: Text(
          'Chats',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // TODO: Make search works
              setState(() {
                _searchQuery = '';
                _searchController.clear();
              });
            },
          ),
          Consumer<ChatListProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: Icon(
                  provider.isConnected ? Icons.cloud_done : Icons.cloud_off,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (!provider.isConnected) {
                    provider.reconnect();
                  }
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              _showOptionsMenu();
            },
          ),
        ],
      ),
      body: Consumer<ChatListProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.accentColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => provider.reconnect(),
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      'Retry',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    // TODO: Get rid of it
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final dialogues = provider.dialogues;
          final filteredDialogues = _searchQuery.isEmpty
              ? dialogues
              : dialogues.where((d) =>
          d.contactName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              d.lastMessage.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();

          if (dialogues.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: AppTheme.secondaryColor,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No conversations yet',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to start a new chat',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppTheme.primaryColor,
            backgroundColor: AppTheme.cardColor,
            onRefresh: () async {
              provider.refreshDialogues();
              await Future.delayed(const Duration(seconds: 1));
            },
            child: Column(
              children: [
                // Search bar (if needed)
                if (_searchQuery.isNotEmpty || _searchController.text.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: AppTheme.backgroundColor,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search chats...',
                        hintStyle: GoogleFonts.poppins(
                          color: AppTheme.textSecondaryColor.withValues(alpha: 0.5),
                        ),
                        prefixIcon: Icon(Icons.search, color: AppTheme.accentColor),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear, color: AppTheme.textSecondaryColor),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppTheme.cardColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      style: GoogleFonts.poppins(color: AppTheme.textPrimaryColor),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),

                // Chat list
                Expanded(
                  child: filteredDialogues.isEmpty
                      ? Center(
                    child: Text(
                      'No chats found',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  )
                      : ListView.separated(
                    itemCount: filteredDialogues.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      thickness: 1,
                      color: AppTheme.secondaryColor,
                      indent: 72,
                    ),
                    itemBuilder: (context, index) {
                      return _buildDialogueItem(
                        filteredDialogues[index],
                        provider,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewChatDialog,
        backgroundColor: AppTheme.primaryColor,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildDialogueItem(ChatDialogue dialogue, ChatListProvider provider) {
    return InkWell(
      onTap: () {
        // Mark as read when opening chat
        provider.markDialogueAsRead(dialogue.id);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatConversationScreen(
              contactName: dialogue.contactName,
              isOnline: dialogue.isOnline,
              dialogueId: dialogue.id,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        color: AppTheme.cardColor,
        child: Row(
          children: [
            // Avatar with gradient
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.accentColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: dialogue.avatarUrl != null
                      ? ClipOval(
                    child: Image.network(
                      dialogue.avatarUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Center(
                    child: Text(
                      dialogue.contactName[0].toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (dialogue.isOnline)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981), // Green
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.cardColor, width: 2.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          dialogue.contactName,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: dialogue.unreadCount > 0
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: AppTheme.textPrimaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTimestamp(dialogue.timestamp),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: dialogue.unreadCount > 0
                              ? AppTheme.primaryColor
                              : AppTheme.textSecondaryColor.withValues(alpha: 0.7),
                          fontWeight: dialogue.unreadCount > 0
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Last message and unread count
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dialogue.lastMessage,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: dialogue.unreadCount > 0
                                ? AppTheme.textPrimaryColor.withValues(alpha: 0.8)
                                : AppTheme.textSecondaryColor.withValues(alpha: 0.6),
                            fontWeight: dialogue.unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (dialogue.unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppTheme.primaryColor, AppTheme.accentColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            dialogue.unreadCount > 99
                                ? '99+'
                                : dialogue.unreadCount.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.refresh, color: AppTheme.primaryColor),
              title: Text(
                'Refresh',
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                context.read<ChatListProvider>().refreshDialogues();
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: AppTheme.primaryColor),
              title: Text(
                'Settings',
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Settings will be added in future versions :D"),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}