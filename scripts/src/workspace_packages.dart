/// The publishable packages in the melos workspace, in publish order.
///
/// They share a single version and are released together from `v*` tags. The
/// `standard_schema` contract package lives in its own repository
/// (conceptadev/standard-schema-dart) and is consumed from pub.dev.
const publishablePackages = <String>[
  'ack',
  'ack_annotations',
  'ack_generator',
  'ack_firebase_ai',
  'ack_json_schema_builder',
];
