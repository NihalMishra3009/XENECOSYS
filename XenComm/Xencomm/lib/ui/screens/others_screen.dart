import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/communication_mock_data.dart';
import '../../providers/app_providers.dart';
import '../../services/database/database_service.dart';

class OthersScreen extends ConsumerStatefulWidget {
  const OthersScreen({super.key});

  @override
  ConsumerState<OthersScreen> createState() => _OthersScreenState();
}

class _OthersScreenState extends ConsumerState<OthersScreen> {
  final _db = DatabaseService();
  final _destinationController = TextEditingController();
  final _departureController = TextEditingController();

  List<_TravelHistoryItem> _savedTravelLogs = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSavedLogs());
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _departureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final travelLogs = [
      ...travelHistoryMock.map(
        (entry) => _TravelHistoryItem(
          destination: entry.destination,
          departureTime: entry.departureTime,
          savedAt: entry.savedAt,
        ),
      ),
      ..._savedTravelLogs,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Others',
          style: TextStyle(
            color: Color(0xFFEAF4FB),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Save your next move and review local history',
          style: TextStyle(
            color: Color(0xFFA2B6C8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        _panel(
          title: 'Travel Details',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _destinationController,
                style: const TextStyle(color: Color(0xFFEAF4FB)),
                decoration: _inputDecoration(
                  hintText: 'Enter destination',
                  icon: Icons.place_outlined,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _departureController,
                style: const TextStyle(color: Color(0xFFEAF4FB)),
                decoration: _inputDecoration(
                  hintText: 'Enter departure time',
                  icon: Icons.schedule_outlined,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFEAF4FB),
                    foregroundColor: const Color(0xFF08111B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _saveTravelLog,
                  child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _sectionTitle('Travel History'),
        const SizedBox(height: 10),
        if (travelLogs.isEmpty)
          _emptyState('No travel history yet')
        else
          ...travelLogs.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _HistoryCard(
                child: Row(
                  children: [
                    _iconBubble(Icons.directions_walk_outlined, const Color(0xFF7DC8E8)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.destination,
                            style: const TextStyle(
                              color: Color(0xFFEAF4FB),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Departure: ${entry.departureTime}',
                            style: const TextStyle(
                              color: Color(0xFFA2B6C8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Saved: ${entry.savedAt}',
                            style: const TextStyle(
                              color: Color(0xFF8CA3B6),
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
          ),
        const SizedBox(height: 10),
        _sectionTitle('Message History'),
        const SizedBox(height: 10),
        if (messageHistoryMock.isEmpty)
          _emptyState('No message history yet')
        else
          ...messageHistoryMock.map(
            (message) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _HistoryCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _iconBubble(Icons.mark_email_read_outlined, const Color(0xFF7FD3C5)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  message.route,
                                  style: const TextStyle(
                                    color: Color(0xFFEAF4FB),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              _StatusChip(status: message.status),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Priority: ${message.priority}',
                            style: const TextStyle(
                              color: Color(0xFFA2B6C8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            message.time,
                            style: const TextStyle(
                              color: Color(0xFF8CA3B6),
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
          ),
        const SizedBox(height: 72),
      ],
    );
  }

  Future<void> _loadSavedLogs() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final rows = await _db.query(
      'travel_logs',
      where: 'userID = ?',
      whereArgs: [user.uniqueID],
    );

    if (!mounted) return;
    setState(() {
      _savedTravelLogs = rows
          .map(
            (row) => _TravelHistoryItem(
              destination: row['destination'] as String? ?? '',
              departureTime: row['departureTime'] as String? ?? '',
              savedAt: _formatDate(row['createdAt'] as String?),
            ),
          )
          .where((entry) => entry.destination.isNotEmpty && entry.departureTime.isNotEmpty)
          .toList()
        ..sort((a, b) => b.savedAt.compareTo(a.savedAt));
    });
  }

  Future<void> _saveTravelLog() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final destination = _destinationController.text.trim();
    final departure = _departureController.text.trim();
    if (destination.isEmpty || departure.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both destination and departure time')),
      );
      return;
    }

    final now = DateTime.now();
    await _db.insert(
      'travel_logs',
      {
        'travelLogID': 'TRV-${now.microsecondsSinceEpoch}',
        'userID': user.uniqueID,
        'destination': destination,
        'departureTime': departure,
        'createdAt': now.toIso8601String(),
      },
    );

    _destinationController.clear();
    _departureController.clear();
    await _loadSavedLogs();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Travel details saved locally'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _panel({required String title, required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0x1AFFFFFF), Color(0x75163049)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF243A4F).withValues(alpha: 0.95)),
            boxShadow: const [
              BoxShadow(color: Color(0x44112635), blurRadius: 16, offset: Offset(0, 6)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Color(0xFFEAF4FB), fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF90A7BC), fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFF7DC8E8)),
      filled: true,
      fillColor: const Color(0xFF101B28),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF243A4F)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF243A4F)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF7DC8E8)),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFFEAF4FB),
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _emptyState(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF101B28).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF243A4F)),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFF8CA3B6), fontSize: 12),
      ),
    );
  }

  Widget _iconBubble(IconData icon, Color color) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  String _formatDate(String? iso) {
    final time = iso == null ? DateTime.now() : DateTime.tryParse(iso) ?? DateTime.now();
    final h = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final m = time.minute.toString().padLeft(2, '0');
    final ampm = time.hour >= 12 ? 'PM' : 'AM';
    return '${time.day}/${time.month}/${time.year} $h:$m $ampm';
  }
}

class _HistoryCard extends StatelessWidget {
  final Widget child;

  const _HistoryCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0x1AFFFFFF), Color(0x75163049)],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFF243A4F).withValues(alpha: 0.95)),
            boxShadow: const [
              BoxShadow(color: Color(0x44112635), blurRadius: 16, offset: Offset(0, 6)),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'Delivered' => const Color(0xFF7FD3C5),
      'Sent' => const Color(0xFF7DC8E8),
      'Queued' => const Color(0xFFF3B86B),
      _ => const Color(0xFFF75E5E),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _TravelHistoryItem {
  final String destination;
  final String departureTime;
  final String savedAt;

  const _TravelHistoryItem({
    required this.destination,
    required this.departureTime,
    required this.savedAt,
  });
}
