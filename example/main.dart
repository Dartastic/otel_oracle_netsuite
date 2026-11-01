// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_oracle_netsuite/otel_oracle_netsuite.dart';

/// Traces NetSuite calls with OpenTelemetry.
///
/// `otel_oracle_netsuite` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each NetSuite call in
/// [tracedOracleNetSuite]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'oracle-netsuite-example');

  // Wraps a NetSuite call in a CLIENT span.
  final oracleNetSuiteId = await tracedOracleNetSuite<String>(
    operation: 'record.create',
    invoke: () async {
      // Make the NetSuite call here, then report what it returned.
      const id = 'oracle_netsuite_8f3a2c';
      return const OracleNetSuiteCallResult(
          value: id,
          result: OracleNetSuiteResult(
              account: '123456',
              surface: 'rest_record',
              recordType: 'salesOrder',
              recordId: 'record_8f3a2c',
              action: 'get',
              scriptType: 'user_event',
              scriptId: 'script_8f3a2c',
              deploymentId: 'deployment_8f3a2c',
              usagePoints: 1,
              governanceRemaining: 1,
              subsidiary: 'example',
              queryReturnedCount: 3,
              batchSize: 512,
              suiteQlReturned: 1,
              fileSizeBytes: 512,
              errorCode: 'INSUFFICIENT_PERMISSION',
              errorMessage: 'example',
              statusCode: 201));
    },
  );
  OTelLog.info('tracedOracleNetSuite record.create returned $oracleNetSuiteId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutOracleNetSuiteInstrumentationAsync.
  await runWithoutOracleNetSuiteInstrumentationAsync(
    () => tracedOracleNetSuite<String>(
      operation: 'record.create',
      invoke: () async {
        const id = 'oracle_netsuite_8f3a2c';
        return const OracleNetSuiteCallResult(
            value: id,
            result: OracleNetSuiteResult(
                account: '123456',
                surface: 'rest_record',
                recordType: 'salesOrder',
                recordId: 'record_8f3a2c',
                action: 'get',
                scriptType: 'user_event',
                scriptId: 'script_8f3a2c',
                deploymentId: 'deployment_8f3a2c',
                usagePoints: 1,
                governanceRemaining: 1,
                subsidiary: 'example',
                queryReturnedCount: 3,
                batchSize: 512,
                suiteQlReturned: 1,
                fileSizeBytes: 512,
                errorCode: 'INSUFFICIENT_PERMISSION',
                errorMessage: 'example',
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
