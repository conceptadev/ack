/// The independently versioned Standard Schema contract package.
const standardSchemaPackage = 'standard_schema';

/// The publishable ack packages in the melos workspace, in publish order.
const publishableAckPackages = <String>[
  'ack',
  'ack_annotations',
  'ack_generator',
  'ack_firebase_ai',
  'ack_json_schema_builder',
];

/// Every publishable package in dependency order.
const publishablePackages = <String>[
  standardSchemaPackage,
  ...publishableAckPackages,
];
