const String usersTable = '''
  CREATE TABLE users (
    uniqueID TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    photo TEXT,
    homeHubID TEXT NOT NULL,
    currentHubID TEXT NOT NULL,
    publicKey TEXT NOT NULL,
    privateKey TEXT NOT NULL,
    deviceID TEXT UNIQUE NOT NULL,
    createdAt TEXT NOT NULL
  )
''';

const String hubsTable = '''
  CREATE TABLE hubs (
    hubID TEXT PRIMARY KEY,
    hubName TEXT NOT NULL,
    location TEXT NOT NULL,
    registeredUsers TEXT DEFAULT '[]',
    pendingBundles TEXT DEFAULT '[]',
    receivedBundles TEXT DEFAULT '[]',
    connectedDataMules TEXT DEFAULT '[]',
    createdAt TEXT NOT NULL
  )
''';

const String messagesTable = '''
  CREATE TABLE messages (
    messageID TEXT PRIMARY KEY,
    senderID TEXT NOT NULL,
    receiverID TEXT NOT NULL,
    timestamp TEXT NOT NULL,
    priority TEXT NOT NULL,
    status TEXT NOT NULL,
    encryptedContent TEXT NOT NULL,
    attachmentHash TEXT,
    FOREIGN KEY (senderID) REFERENCES users(uniqueID),
    FOREIGN KEY (receiverID) REFERENCES users(uniqueID)
  )
''';

const String travelLogsTable = '''
  CREATE TABLE travel_logs (
    travelLogID TEXT PRIMARY KEY,
    userID TEXT NOT NULL,
    destination TEXT NOT NULL,
    departureTime TEXT NOT NULL,
    createdAt TEXT NOT NULL
  )
''';

const String bundlesTable = '''
  CREATE TABLE bundles (
    bundleID TEXT PRIMARY KEY,
    sourceHub TEXT NOT NULL,
    destinationHub TEXT NOT NULL,
    messageIDs TEXT NOT NULL,
    createdAt TEXT NOT NULL,
    checksum TEXT NOT NULL,
    status TEXT NOT NULL,
    sizeBytes INTEGER NOT NULL,
    FOREIGN KEY (sourceHub) REFERENCES hubs(hubID),
    FOREIGN KEY (destinationHub) REFERENCES hubs(hubID)
  )
''';

const String datamulesTable = '''
  CREATE TABLE datamules (
    vehicleID TEXT PRIMARY KEY,
    type TEXT NOT NULL,
    capacity INTEGER NOT NULL,
    currentHub TEXT NOT NULL,
    nextHub TEXT NOT NULL,
    speed REAL NOT NULL,
    status TEXT NOT NULL,
    bundlesCarrying TEXT DEFAULT '[]',
    createdAt TEXT NOT NULL,
    FOREIGN KEY (currentHub) REFERENCES hubs(hubID),
    FOREIGN KEY (nextHub) REFERENCES hubs(hubID)
  )
''';

const String contactsTable = '''
  CREATE TABLE contacts (
    contactID TEXT PRIMARY KEY,
    userID TEXT NOT NULL,
    contactUserID TEXT NOT NULL,
    name TEXT NOT NULL,
    addedAt TEXT NOT NULL,
    FOREIGN KEY (userID) REFERENCES users(uniqueID),
    FOREIGN KEY (contactUserID) REFERENCES users(uniqueID),
    UNIQUE(userID, contactUserID)
  )
''';
