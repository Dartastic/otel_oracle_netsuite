// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_oracle_netsuite/otel_oracle_netsuite.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_oracle_netsuite-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('record.create records type + usage points', () async {
    await tracedOracleNetSuite<String>(
      operation: 'record.create',
      invoke: () async => const OracleNetSuiteCallResult(
        value: 'ok',
        result: OracleNetSuiteResult(
          account: '123456_SB1',
          surface: 'rest_record',
          recordType: 'salesOrder',
          action: 'create',
          usagePoints: 12,
          governanceRemaining: 988,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('oracle_netsuite record.create')!);
    expect(a['oracle_netsuite.record.type'], 'salesOrder');
    expect(a['oracle_netsuite.usage.points'], 12);
  });

  test('suiteql.execute records returned count', () async {
    await tracedOracleNetSuite<String>(
      operation: 'suiteql.execute',
      invoke: () async => const OracleNetSuiteCallResult(
        value: 'ok',
        result: OracleNetSuiteResult(
          surface: 'suiteql',
          suiteQlReturned: 250,
          usagePoints: 10,
        ),
      ),
    );
    final a = attrsOf(
      spans.findSpanByName('oracle_netsuite suiteql.execute')!,
    );
    expect(a['oracle_netsuite.suiteql.returned'], 250);
  });

  test('governance error sets span error', () async {
    await tracedOracleNetSuite<String>(
      operation: 'record.create',
      invoke: () async => const OracleNetSuiteCallResult(
        value: 'ok',
        result: OracleNetSuiteResult(
          errorCode: 'SSS_USAGE_LIMIT_EXCEEDED',
          statusCode: 429,
        ),
      ),
    );
    expect(
      spans.findSpanByName('oracle_netsuite record.create')!.status,
      SpanStatusCode.Error,
    );
  });

  test('suppression skips spans', () async {
    await runWithoutOracleNetSuiteInstrumentationAsync(() async {
      await tracedOracleNetSuite<String>(
        operation: 'auth.token',
        invoke: () async => const OracleNetSuiteCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('oracle_netsuite '), isEmpty);
  });
}
