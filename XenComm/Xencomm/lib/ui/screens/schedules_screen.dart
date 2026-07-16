import 'dart:ui';

import 'package:flutter/material.dart';

class SchedulesScreen extends StatelessWidget {
  const SchedulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      _TransitSchedule(
        mode: 'Bus',
        route: 'B-214 | Navi Mumbai Loop',
        departure: '08:15 AM',
        eta: '12 min',
        status: 'On time',
      ),
      _TransitSchedule(
        mode: 'Metro',
        route: 'M-03 | Belapur to Vashi',
        departure: '08:32 AM',
        eta: '7 min',
        status: 'Approaching',
      ),
      _TransitSchedule(
        mode: 'Train',
        route: 'Harbour Line | CST bound',
        departure: '08:45 AM',
        eta: '18 min',
        status: 'Delayed 3 min',
      ),
      _TransitSchedule(
        mode: 'Bus',
        route: 'B-118 | Sector 19 Express',
        departure: '09:10 AM',
        eta: '24 min',
        status: 'On time',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Schedules',
          style: TextStyle(
            color: Color(0xFFEAF4FB),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Mock live timings for nearby transit links',
          style: TextStyle(
            color: Color(0xFFA2B6C8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ScheduleCard(item: item),
            )),
        const SizedBox(height: 72),
      ],
    );
  }
}

class _TransitSchedule {
  final String mode;
  final String route;
  final String departure;
  final String eta;
  final String status;

  const _TransitSchedule({
    required this.mode,
    required this.route,
    required this.departure,
    required this.eta,
    required this.status,
  });
}

class _ScheduleCard extends StatelessWidget {
  final _TransitSchedule item;

  const _ScheduleCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final accent = switch (item.mode) {
      'Train' => const Color(0xFF7DC8E8),
      'Metro' => const Color(0xFF9BBAF5),
      _ => const Color(0xFF7FD3C5),
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
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
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF243A4F).withValues(alpha: 0.95)),
            boxShadow: const [
              BoxShadow(color: Color(0x44112635), blurRadius: 16, offset: Offset(0, 6)),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  item.mode == 'Train'
                      ? Icons.train
                      : item.mode == 'Metro'
                          ? Icons.directions_subway
                          : Icons.directions_bus,
                  color: accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.mode,
                          style: const TextStyle(
                            color: Color(0xFFEAF4FB),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        _chip(item.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.route,
                      style: const TextStyle(
                        color: Color(0xFFA2B6C8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _metric(label: 'Departure', value: item.departure),
                        const SizedBox(width: 18),
                        _metric(label: 'ETA', value: item.eta),
                      ],
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

  Widget _metric({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8CA3B6),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFEAF4FB),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF101B28),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF243A4F)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFEAF4FB),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
