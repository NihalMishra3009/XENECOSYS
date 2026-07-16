import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';

class EmergencyBroadcastScreen extends ConsumerWidget {
  const EmergencyBroadcastScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EmergencyBroadcastContent(currentUserName: currentUser?.name, currentUserId: currentUser?.uniqueID),
      ],
    );
  }
}

class EmergencyBroadcastContent extends StatefulWidget {
  final String? currentUserName;
  final String? currentUserId;

  const EmergencyBroadcastContent({super.key, this.currentUserName, this.currentUserId});

  @override
  State<EmergencyBroadcastContent> createState() => _EmergencyBroadcastContentState();
}

class _EmergencyBroadcastContentState extends State<EmergencyBroadcastContent> {
  static const Color _ink = Color(0xFFEAF4FB);
  static const Color _border = Color(0xFF243A4F);
  static const Color _shadow = Color(0x44112635);
  static const Color _surface = Color(0xFF101B28);
  static const LinearGradient _homeGlassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1AFFFFFF),
      Color(0x75163049),
    ],
  );

  final _messageController = TextEditingController();
  String _selectedAlertType = 'Medical';

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _frostCard(
          context,
          title: 'Alert Type',
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.08,
            children: [
              _alertTile('Medical', Icons.local_hospital),
              _alertTile('Food Request', Icons.restaurant),
              _alertTile('Government', Icons.gavel),
              _alertTile('General', Icons.warning),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _frostCard(
          context,
          title: 'Message',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _messageController,
                minLines: 3,
                maxLines: 4,
                style: const TextStyle(color: _ink),
                decoration: InputDecoration(
                  hintText: 'Describe your emergency...',
                  hintStyle: const TextStyle(fontSize: 15, color: Color(0xFF90A7BC)),
                  filled: true,
                  fillColor: _surface,
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: _border, width: 1.2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: _border, width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFF7DC8E8), width: 1.2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEAF4FB),
                    foregroundColor: const Color(0xFF08111B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 6,
                    shadowColor: _shadow,
                  ),
                  onPressed: _handleBroadcast,
                  child: const Text(
                    'BROADCAST EMERGENCY',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _frostCard(BuildContext context, {required String title, required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          decoration: BoxDecoration(
            gradient: _homeGlassGradient,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _border.withValues(alpha: 0.95), width: 1.1),
            boxShadow: const [
              BoxShadow(color: _shadow, blurRadius: 16, offset: Offset(0, 6)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: _ink),
              ),
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _alertTile(String label, IconData icon) {
    final selected = _selectedAlertType == label;
    return InkWell(
      onTap: () => setState(() => _selectedAlertType = label),
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF75E5E), Color(0xFFE73B3B)],
                )
              : _homeGlassGradient,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border.withValues(alpha: 0.95)),
          boxShadow: selected
              ? const [
                  BoxShadow(color: Color(0x26F44336), blurRadius: 16, offset: Offset(0, 6)),
                ]
              : const [
                  BoxShadow(color: Color(0x44112635), blurRadius: 16, offset: Offset(0, 8)),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: selected ? Colors.white : _ink),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? Colors.white : _ink,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleBroadcast() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a message')));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$_selectedAlertType broadcast sent to all hubs')));
    _messageController.clear();
  }
}
