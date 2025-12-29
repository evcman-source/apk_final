import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../services/chat_provider.dart';
import '../models/chat_model.dart';

class ChatBubble extends StatelessWidget {
  final Message message;
  
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, provider, _) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!message.isUser) ...[
                _buildAvatar(provider),
                const SizedBox(width: 12),
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment: message.isUser 
                      ? CrossAxisAlignment.end 
                      : CrossAxisAlignment.start,
                  children: [
                    // Image Preview
                    if (message.imagePath != null) _buildImagePreview(),
                    
                    // File Preview
                    if (message.filePath != null && message.type == MessageType.file)
                      _buildFilePreview(provider),
                    
                    // Text Bubble
                    if (message.content.isNotEmpty) _buildTextBubble(context, provider),
                    
                    // Timestamp
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 4, right: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (message.type == MessageType.voice && message.isUser)
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(
                                Icons.mic_rounded,
                                size: 12,
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                          Text(
                            _formatTime(message.timestamp),
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (message.isUser) ...[
                const SizedBox(width: 12),
                _buildUserAvatar(),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextBubble(BuildContext context, ChatProvider provider) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: message.isUser
            ? LinearGradient(colors: [provider.getModeColor(), provider.getModeColorLight()])
            : null,
        color: message.isUser ? null : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: message.isUser ? const Radius.circular(20) : const Radius.circular(6),
          bottomRight: message.isUser ? const Radius.circular(6) : const Radius.circular(20),
        ),
        border: message.isUser ? null : Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: message.isUser ? [
          BoxShadow(
            color: provider.getModeColor().withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: Text(
        message.content,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.white,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      constraints: const BoxConstraints(maxWidth: 250, maxHeight: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(message.imagePath!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white.withOpacity(0.1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.broken_image_rounded, color: Colors.white38, size: 40),
                const SizedBox(height: 8),
                Text(
                  'Resim yüklenemedi',
                  style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilePreview(ChatProvider provider) {
    final fileName = message.content.replaceAll('📎 ', '');
    final extension = fileName.split('.').last.toUpperCase();
    
    Color fileColor;
    IconData fileIcon;
    
    switch (extension.toLowerCase()) {
      case 'pdf':
        fileColor = Colors.red;
        fileIcon = Icons.picture_as_pdf_rounded;
        break;
      case 'doc':
      case 'docx':
        fileColor = Colors.blue;
        fileIcon = Icons.description_rounded;
        break;
      case 'txt':
      case 'md':
        fileColor = Colors.grey;
        fileIcon = Icons.article_rounded;
        break;
      case 'json':
        fileColor = Colors.orange;
        fileIcon = Icons.code_rounded;
        break;
      case 'csv':
        fileColor = Colors.green;
        fileIcon = Icons.table_chart_rounded;
        break;
      default:
        fileColor = Colors.purple;
        fileIcon = Icons.insert_drive_file_rounded;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: fileColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(fileIcon, color: fileColor, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fileName,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              Text(
                extension,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: fileColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(ChatProvider provider) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [provider.getModeColor(), provider.getModeColorLight()],
        ),
        boxShadow: [
          BoxShadow(
            color: provider.getModeColor().withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(provider.getModeIcon(), color: Colors.white, size: 20),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(0.1),
      ),
      child: const Icon(Icons.person_rounded, color: Colors.white54, size: 20),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
