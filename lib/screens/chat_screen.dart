import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/chat_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  late AnimationController _micAnimationController;

  @override
  void initState() {
    super.initState();
    _micAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _requestPermissions();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _micAnimationController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
    await Permission.storage.request();
    await Permission.camera.request();
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    
    context.read<ChatProvider>().sendMessage(_controller.text.trim());
    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        context.read<ChatProvider>().sendImage(image.path);
        _scrollToBottom();
      }
    } catch (e) {
      _showSnackBar('Resim seçilemedi');
    }
    Navigator.pop(context);
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'pdf', 'json', 'md', 'csv', 'doc', 'docx'],
      );
      
      if (result != null && result.files.single.path != null) {
        context.read<ChatProvider>().sendFile(
          result.files.single.path!,
          result.files.single.name,
        );
        _scrollToBottom();
      }
    } catch (e) {
      _showSnackBar('Dosya seçilemedi');
    }
    Navigator.pop(context);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showAttachmentOptions() {
    final provider = context.read<ChatProvider>();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Kamera',
                  color: provider.getModeColor(),
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                _buildAttachOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Galeri',
                  color: const Color(0xFF8B5CF6),
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
                _buildAttachOption(
                  icon: Icons.insert_drive_file_rounded,
                  label: 'Dosya',
                  color: const Color(0xFFF59E0B),
                  onTap: () => _pickFile(),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0A0A0A),
          drawer: const AppDrawer(),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _getBackgroundColors(provider.currentMode),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  _buildHeader(provider),
                  
                  // Voice Recognition Indicator
                  if (provider.isListening) _buildVoiceIndicator(provider),
                  
                  // Chat Messages
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: provider.messages.length,
                      itemBuilder: (context, index) {
                        return ChatBubble(message: provider.messages[index]);
                      },
                    ),
                  ),
                  
                  // Loading Indicator
                  if (provider.isLoading) _buildLoadingIndicator(provider),
                  
                  // Input Area
                  _buildInputArea(provider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Color> _getBackgroundColors(String mode) {
    switch (mode) {
      case 'eva':
        return [const Color(0xFF1A1A2E), const Color(0xFF16213E), const Color(0xFF0A0A0A)];
      case 'chaos':
        return [const Color(0xFF2A1A1A), const Color(0xFF1F1515), const Color(0xFF0A0A0A)];
      case 'god':
        return [const Color(0xFF2A2415), const Color(0xFF1F1A10), const Color(0xFF0A0A0A)];
      case 'luna':
        return [const Color(0xFF2A1A28), const Color(0xFF1F1520), const Color(0xFF0A0A0A)];
      default:
        return [const Color(0xFF1A1A2E), const Color(0xFF16213E), const Color(0xFF0A0A0A)];
    }
  }

  Widget _buildHeader(ChatProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 20, 16),
      child: Row(
        children: [
          // Menu Button
          Builder(
            builder: (context) => GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white.withOpacity(0.08),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: const Icon(Icons.menu_rounded, color: Colors.white70, size: 24),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [provider.getModeColor(), provider.getModeColorLight()],
              ),
              boxShadow: [
                BoxShadow(
                  color: provider.getModeColor().withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(provider.getModeIcon(), color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.getModeTitle(),
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    foreground: Paint()
                      ..shader = LinearGradient(
                        colors: [provider.getModeColor(), provider.getModeColorLight()],
                      ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        // Bağlantı testi yap
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => AlertDialog(
                            backgroundColor: const Color(0xFF1E1E2E),
                            title: Text('Bağlantı Testi', style: GoogleFonts.poppins(color: Colors.white)),
                            content: FutureBuilder<String>(
                              future: provider.testConnection(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Row(
                                    children: [
                                      const CircularProgressIndicator(),
                                      const SizedBox(width: 16),
                                      Text('Test ediliyor...', style: GoogleFonts.poppins(color: Colors.white70)),
                                    ],
                                  );
                                }
                                return Text(
                                  snapshot.data ?? 'Sonuç alınamadı',
                                  style: GoogleFonts.poppins(color: Colors.white70),
                                );
                              },
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Tamam', style: GoogleFonts.poppins(color: provider.getModeColor())),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: provider.isConnected ? const Color(0xFF22C55E) : Colors.red,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            provider.isConnected ? 'Çevrimiçi' : 'Bağlantı Yok (Dokunun)',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Speaking Indicator
          if (provider.isSpeaking)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: provider.getModeColor().withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.volume_up_rounded, color: provider.getModeColor(), size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Konuşuyor',
                    style: GoogleFonts.poppins(fontSize: 12, color: provider.getModeColor()),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVoiceIndicator(ChatProvider provider) {
    return AnimatedBuilder(
      animation: _micAnimationController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: provider.getModeColor().withOpacity(0.1 + _micAnimationController.value * 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: provider.getModeColor().withOpacity(0.3), width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: provider.getModeColor(),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.mic_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dinleniyor...',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    if (provider.recognizedText.isNotEmpty)
                      Text(
                        provider.recognizedText,
                        style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => provider.stopListening(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.stop_rounded, color: Colors.red, size: 22),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator(ChatProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(provider.getModeColor()),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${provider.getModeTitle()} düşünüyor...',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(ChatProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Colors.white.withOpacity(0.06),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            // Attachment Button
            GestureDetector(
              onTap: _showAttachmentOptions,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.add_rounded, color: Colors.white.withOpacity(0.5), size: 26),
              ),
            ),
            
            // Text Input
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _sendMessage(),
                style: GoogleFonts.poppins(fontSize: 15, color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Mesajınızı yazın...',
                  hintStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.3), fontSize: 15),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
            
            // Voice Button
            GestureDetector(
              onTap: () {
                if (provider.isListening) {
                  provider.stopListening();
                } else {
                  provider.startListening();
                }
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: provider.isListening ? provider.getModeColor() : Colors.transparent,
                ),
                child: Icon(
                  provider.isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                  color: provider.isListening ? Colors.white : Colors.white.withOpacity(0.5),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 8),
            
            // Send Button
            GestureDetector(
              onTap: provider.isLoading ? null : _sendMessage,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: provider.isLoading
                        ? [Colors.grey.shade700, Colors.grey.shade600]
                        : [provider.getModeColor(), provider.getModeColorLight()],
                  ),
                  boxShadow: provider.isLoading ? null : [
                    BoxShadow(
                      color: provider.getModeColor().withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  provider.isLoading ? Icons.hourglass_empty_rounded : Icons.send_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
