import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/data/communication_mock_data.dart';

class DashboardCardsSection extends StatefulWidget {
  static const Color _accent = Color(0xFFEAF4FB);
  static const Color _muted = Color(0xFF9AB0C3);
  static const Color _border = Color(0xFF243A4F);
  static const Color _shadow = Color(0x44112635);

  final String connectedHubId;
  final int pendingMessagesCount;
  final int contactsCount;
  final int emergencyAlertsCount;
  final VoidCallback onConnectedHubTap;
  final VoidCallback onPendingMessagesTap;
  final VoidCallback onContactsTap;
  final VoidCallback onEmergencyAlertsTap;
  final String selectedRecipient;
  final VoidCallback onSendTap;

  const DashboardCardsSection({
    super.key,
    required this.connectedHubId,
    required this.pendingMessagesCount,
    required this.contactsCount,
    required this.emergencyAlertsCount,
    required this.onConnectedHubTap,
    required this.onPendingMessagesTap,
    required this.onContactsTap,
    required this.onEmergencyAlertsTap,
    required this.selectedRecipient,
    required this.onSendTap,
  });

  @override
  State<DashboardCardsSection> createState() => _DashboardCardsSectionState();
}

class _DashboardCardsSectionState extends State<DashboardCardsSection> {
  late String _selectedRecipient = widget.selectedRecipient;
  final TextEditingController _messageController = TextEditingController();

  @override
  void didUpdateWidget(covariant DashboardCardsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedRecipient != widget.selectedRecipient && widget.selectedRecipient.isNotEmpty) {
      _selectedRecipient = widget.selectedRecipient;
    }
  }

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
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.08,
          children: [
            _metricCard(
              context,
              icon: Icons.hub_outlined,
              title: AppConstants.connectedHub,
              value: widget.connectedHubId,
              onTap: widget.onConnectedHubTap,
            ),
            _metricCard(
              context,
              icon: Icons.mail_outline,
              title: AppConstants.pendingMessages,
              value: '${widget.pendingMessagesCount}',
              onTap: widget.onPendingMessagesTap,
            ),
            _metricCard(
              context,
              icon: Icons.contacts_outlined,
              title: AppConstants.contactsTitle,
              value: '${widget.contactsCount}',
              onTap: widget.onContactsTap,
            ),
            _metricCard(
              context,
              icon: Icons.warning_amber_outlined,
              title: AppConstants.emergencyAlerts,
              value: '${widget.emergencyAlertsCount}',
              onTap: widget.onEmergencyAlertsTap,
            ),
          ],
        ),
        const SizedBox(height: 18),
        _quickMessageCard(context),
      ],
    );
  }

  Widget _metricCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.10),
                    const Color(0xFF163049).withValues(alpha: 0.46),
                  ],
                ),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: DashboardCardsSection._border.withValues(alpha: 0.95)),
                boxShadow: const [
                  BoxShadow(color: DashboardCardsSection._shadow, blurRadius: 18, offset: Offset(0, 8)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 3,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF5FA8D3).withValues(alpha: 0.08),
                          const Color(0xFF7DC8E8).withValues(alpha: 0.85),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const Spacer(flex: 1),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A2A3C), Color(0xFF27405C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(color: Color(0x33112635), blurRadius: 10, offset: Offset(0, 4)),
                        ],
                      ),
                      child: Icon(icon, color: DashboardCardsSection._accent, size: 18),
                    ),
                  ),
                  const Spacer(flex: 2),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: DashboardCardsSection._muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          height: 1.08,
                          letterSpacing: 0.15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: DashboardCardsSection._accent,
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _quickMessageCard(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.10),
                const Color(0xFF163049).withValues(alpha: 0.46),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: DashboardCardsSection._border.withValues(alpha: 0.95)),
            boxShadow: const [
              BoxShadow(color: DashboardCardsSection._shadow, blurRadius: 16, offset: Offset(0, 6)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Send Message',
                style: TextStyle(
                  color: DashboardCardsSection._muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => _pickContact(context),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF101B28), Color(0xFF132131)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: DashboardCardsSection._border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedRecipient,
                          style: const TextStyle(
                            color: DashboardCardsSection._accent,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF8EA5B8), size: 22),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 9),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF101B28), Color(0xFF132131)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: DashboardCardsSection._border),
                ),
                child: TextField(
                  controller: _messageController,
                  minLines: 2,
                  maxLines: 4,
                  style: const TextStyle(
                    color: DashboardCardsSection._accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Type message...',
                    hintStyle: TextStyle(
                      color: Color(0xFFB2C2D0),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 9),
              SizedBox(
                height: 46,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFEAF4FB),
                    foregroundColor: const Color(0xFF08111B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    widget.onSendTap();
                    if (_messageController.text.trim().isEmpty) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Queued for $_selectedRecipient'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    _messageController.clear();
                  },
                  child: const Text(
                    'Send',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickContact(BuildContext context) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: const Color(0xFF0E1722),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          const Text(
            'Choose contact',
            style: TextStyle(color: DashboardCardsSection._accent, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...contactSeeds.map(
            (contact) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(contact.$1, style: const TextStyle(color: DashboardCardsSection._accent)),
              subtitle: Text(contact.$2, style: const TextStyle(color: DashboardCardsSection._muted)),
              onTap: () => Navigator.pop(context, contact.$1),
            ),
          ),
        ],
      ),
    );

    if (choice != null && mounted) {
      setState(() => _selectedRecipient = choice);
    }
  }
}
