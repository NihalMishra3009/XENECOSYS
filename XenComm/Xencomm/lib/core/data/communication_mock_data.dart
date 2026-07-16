class MockPendingMessage {
  final String name;
  final String userID;
  final String preview;
  final String time;
  final int unreadCount;

  const MockPendingMessage({
    required this.name,
    required this.userID,
    required this.preview,
    required this.time,
    required this.unreadCount,
  });
}

class MockEmergencyAlert {
  final String type;
  final String location;
  final String time;
  final String severity;

  const MockEmergencyAlert({
    required this.type,
    required this.location,
    required this.time,
    required this.severity,
  });
}

class MockTravelHistoryEntry {
  final String destination;
  final String departureTime;
  final String savedAt;

  const MockTravelHistoryEntry({
    required this.destination,
    required this.departureTime,
    required this.savedAt,
  });
}

class MockMessageHistoryEntry {
  final String route;
  final String priority;
  final String status;
  final String time;

  const MockMessageHistoryEntry({
    required this.route,
    required this.priority,
    required this.status,
    required this.time,
  });
}

const contactSeeds = <(String, String)>[
  ('Aarav Sharma', 'HX-12345678'),
  ('Nisha Verma', 'HX-87654321'),
  ('Ishaan Khan', 'HX-24681357'),
  ('Meera Iyer', 'HX-13572468'),
  ('Rohan Patel', 'HX-99887766'),
];

const pendingMessagesMock = <MockPendingMessage>[
  MockPendingMessage(
    name: 'Aarav Sharma',
    userID: 'HX-12345678',
    preview: 'Queued message: Need help near station.',
    time: '2 min ago',
    unreadCount: 2,
  ),
  MockPendingMessage(
    name: 'Nisha Verma',
    userID: 'HX-87654321',
    preview: 'Queued message: Meeting point changed to Sector 18 gate.',
    time: '8 min ago',
    unreadCount: 1,
  ),
  MockPendingMessage(
    name: 'Ishaan Khan',
    userID: 'HX-24681357',
    preview: 'Queued message: Medical assistance requested at block B.',
    time: '14 min ago',
    unreadCount: 3,
  ),
];

const emergencyAlertsMock = <MockEmergencyAlert>[
  MockEmergencyAlert(type: 'Medical', location: 'Sector 18', time: '2 min ago', severity: 'High'),
  MockEmergencyAlert(type: 'General', location: 'Belapur Station', time: '11 min ago', severity: 'Medium'),
  MockEmergencyAlert(type: 'Government', location: 'CBD Belapur', time: '25 min ago', severity: 'Low'),
  MockEmergencyAlert(type: 'Medical', location: 'Vashi Bridge', time: '41 min ago', severity: 'High'),
];

const travelHistoryMock = <MockTravelHistoryEntry>[
  MockTravelHistoryEntry(destination: 'Navi Mumbai Station', departureTime: '08:15 AM', savedAt: 'Today 07:40 AM'),
  MockTravelHistoryEntry(destination: 'Belapur Sector 18', departureTime: '10:30 AM', savedAt: 'Today 09:55 AM'),
  MockTravelHistoryEntry(destination: 'Vashi Bridge', departureTime: '01:05 PM', savedAt: 'Today 12:28 PM'),
];

const messageHistoryMock = <MockMessageHistoryEntry>[
  MockMessageHistoryEntry(route: 'Aarav Sharma -> Hub', priority: 'Medical', status: 'Queued', time: '2 min ago'),
  MockMessageHistoryEntry(route: 'Nisha Verma -> Hub', priority: 'Emergency', status: 'Sent', time: '8 min ago'),
  MockMessageHistoryEntry(route: 'Ishaan Khan -> Hub', priority: 'Normal', status: 'Delivered', time: '14 min ago'),
];
