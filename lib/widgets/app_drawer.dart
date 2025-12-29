import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/chat_provider.dart';
import '../models/chat_model.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, provider, _) {
        return Drawer(
          backgroundColor: const Color(0xFF151520),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(provider),
                
                const Divider(color: Colors.white10, height: 1),
                
                // Mode Selector
                _buildModeSection(context, provider),
                
                const Divider(color: Colors.white10, height: 1),
                
                // New Chat Button
                _buildNewChatButton(context, provider),
                
                // Chat History
                Expanded(
                  child: _buildChatHistory(context, provider),
                ),
                
                const Divider(color: Colors.white10, height: 1),
                
                // Settings Footer
                _buildSettingsFooter(provider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ChatProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Eva Mobile',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'v3.0 Premium',
                style: GoogleFonts.poppins(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeSection(BuildContext context, ChatProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'AI MODU',
              style: GoogleFonts.poppins(
                color: Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
          _buildModeItem(context, provider, 'eva', 'Eva', 'Akıllı Asistan', Icons.smart_toy_rounded, const Color(0xFF6366F1)),
          _buildModeItem(context, provider, 'chaos', 'Dr. Chaos', 'Sansürsüz Mod', Icons.science_rounded, const Color(0xFFEF4444)),
          _buildModeItem(context, provider, 'god', 'God Mode', 'Sınırsız Bilgi', Icons.all_inclusive_rounded, const Color(0xFFF59E0B)),
          _buildModeItem(context, provider, 'luna', 'Luna', 'Romantik Mod', Icons.favorite_rounded, const Color(0xFFEC4899)),
        ],
      ),
    );
  }

  Widget _buildModeItem(BuildContext context, ChatProvider provider, String mode, String title, String subtitle, IconData icon, Color color) {
    final isActive = provider.currentMode == mode;
    
    return GestureDetector(
      onTap: () {
        provider.changeMode(mode);
        // Navigator.pop(context); // Drawer'ı kapatma, kullanıcı isterse kapatsın
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: isActive 
              ? LinearGradient(colors: [color, color.withOpacity(0.8)])
              : null,
          color: isActive ? null : Colors.transparent,
          boxShadow: isActive ? [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isActive ? Colors.white24 : color.withOpacity(0.15),
              ),
              child: Icon(icon, color: isActive ? Colors.white : color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: isActive ? Colors.white70 : Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? Colors.white : Colors.transparent,
                border: Border.all(
                  color: isActive ? Colors.white : Colors.white24,
                  width: 2,
                ),
              ),
              child: isActive 
                  ? Icon(Icons.check_rounded, color: color, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewChatButton(BuildContext context, ChatProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            provider.createNewChat();
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: [provider.getModeColor(), provider.getModeColorLight()],
              ),
              boxShadow: [
                BoxShadow(
                  color: provider.getModeColor().withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_circle_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Text(
                  'Yeni Sohbet',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatHistory(BuildContext context, ChatProvider provider) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
          child: Text(
            'SOHBET GEÇMİŞİ',
            style: GoogleFonts.poppins(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        
        // Bugün
        if (provider.getTodayChats().isNotEmpty) ...[
          _buildHistoryGroup('Bugün', provider.getTodayChats(), context, provider),
        ],
        
        // Dün
        if (provider.getYesterdayChats().isNotEmpty) ...[
          _buildHistoryGroup('Dün', provider.getYesterdayChats(), context, provider),
        ],
        
        // Bu Hafta
        if (provider.getThisWeekChats().isNotEmpty) ...[
          _buildHistoryGroup('Bu Hafta', provider.getThisWeekChats(), context, provider),
        ],
        
        // Daha Eski
        if (provider.getOlderChats().isNotEmpty) ...[
          _buildHistoryGroup('Daha Eski', provider.getOlderChats(), context, provider),
        ],
        
        if (provider.chatHistory.isEmpty)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Henüz sohbet yok',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.3),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildHistoryGroup(String title, List<ChatSession> chats, BuildContext context, ChatProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 12, bottom: 8),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.3),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ...chats.map((chat) => _buildHistoryItem(context, provider, chat)),
      ],
    );
  }

  Widget _buildHistoryItem(BuildContext context, ChatProvider provider, ChatSession chat) {
    final isActive = provider.currentChat?.id == chat.id;
    
    return Dismissible(
      key: Key(chat.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.red),
      ),
      onDismissed: (_) => provider.deleteChat(chat.id),
      child: GestureDetector(
        onTap: () {
          provider.selectChat(chat);
          Navigator.pop(context);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isActive ? Colors.white.withOpacity(0.08) : Colors.transparent,
            border: isActive ? Border.all(color: Colors.white12) : null,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white.withOpacity(0.06),
                ),
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Colors.white38,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat.title,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                        fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _formatTime(chat.updatedAt),
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsFooter(ChatProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Dark Mode Toggle
          _buildSettingItem(
            icon: Icons.dark_mode_rounded,
            iconColor: const Color(0xFF6366F1),
            title: 'Karanlık Tema',
            trailing: _buildToggle(provider.isDarkMode, provider.toggleDarkMode),
          ),
          
          const SizedBox(height: 8),
          
          // Voice Response Toggle
          _buildSettingItem(
            icon: Icons.volume_up_rounded,
            iconColor: const Color(0xFF22C55E),
            title: 'Sesli Yanıt',
            trailing: _buildToggle(provider.voiceResponseEnabled, provider.toggleVoiceResponse),
          ),
          
          const SizedBox(height: 12),
          
          // Backend Status
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: provider.isConnected 
                  ? const Color(0xFF22C55E).withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              border: Border.all(
                color: provider.isConnected 
                    ? const Color(0xFF22C55E).withOpacity(0.3)
                    : Colors.red.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: provider.isConnected ? const Color(0xFF22C55E) : Colors.red,
                    boxShadow: [
                      BoxShadow(
                        color: provider.isConnected 
                            ? const Color(0xFF22C55E).withOpacity(0.5)
                            : Colors.red.withOpacity(0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  provider.isConnected ? 'Backend Bağlı • ngrok' : 'Bağlantı Yok',
                  style: GoogleFonts.poppins(
                    color: provider.isConnected ? const Color(0xFF22C55E) : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: iconColor.withOpacity(0.15),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.8),
                fontSize: 13,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildToggle(bool value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 26,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          color: value ? const Color(0xFF6366F1) : Colors.white.withOpacity(0.15),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 1) return 'Şimdi';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dakika önce';
    if (diff.inHours < 24) return '${diff.inHours} saat önce';
    if (diff.inDays < 7) return '${diff.inDays} gün önce';
    
    return '${time.day}/${time.month}/${time.year}';
  }
}
