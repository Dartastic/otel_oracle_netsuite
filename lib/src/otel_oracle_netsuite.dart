// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_oracle_netsuite_suppression.dart';

const _tracerName = 'dartastic_otel_libs_oracle_netsuite';

APITracer _tracer() => OTelAPI.tracerProvider().getTracer(_tracerName);

class OracleNetSuiteResult {
  /// Creates a result.
  const OracleNetSuiteResult({
    this.account,
    this.surface,
    this.recordType,
    this.recordId,
    this.action,
    this.scriptType,
    this.scriptId,
    this.deploymentId,
    this.usagePoints,
    this.governanceRemaining,
    this.subsidiary,
    this.queryReturnedCount,
    this.batchSize,
    this.suiteQlReturned,
    this.fileSizeBytes,
    this.errorCode,
    this.errorMessage,
    this.statusCode,
  });

  /// NetSuite account id (`123456` or `123456_SB1`).
  final String? account;

  /// `rest_record`, `rest_query`, `rest_metadata`, `suite_talk_soap`,
  /// `restlet`, `suiteql`, `suite_analytics_connect`, `bundle`,
  /// `script_deployment`, `file_cabinet`, `scheduled_script`.
  final String? surface;

  /// `salesOrder`, `invoice`, `customer`, `vendor`, `employee`,
  /// `journalEntry`, `creditMemo`, `purchaseOrder`, `inventoryItem`,
  /// `transferOrder`, `cashSale`, `task`, `customrecord_xxx`, ...
  final String? recordType;
  final String? recordId;

  /// `get`, `list`, `create`, `update`, `upsert`, `delete`, `transform`,
  /// `attach`, `detach`, `submit`, `void`, `email`.
  final String? action;

  /// `user_event`, `scheduled`, `map_reduce`, `client`, `suitelet`,
  /// `restlet`, `workflow_action`, `portlet`, `bundle_installation`.
  final String? scriptType;
  final String? scriptId;
  final String? deploymentId;

  /// Governance points consumed by this call (NetSuite's primary billing
  /// dimension for SuiteScript).
  final int? usagePoints;
  final int? governanceRemaining;

  final String? subsidiary;

  /// REST query / SuiteQL row count.
  final int? queryReturnedCount;

  final int? batchSize;

  /// `count` reported in SuiteQL response.
  final int? suiteQlReturned;

  /// File cabinet payload size.
  final int? fileSizeBytes;

  /// `INSUFFICIENT_PERMISSION`, `RCRD_DSNT_EXIST`,
  /// `INVALID_KEY_OR_REF`, `USER_ERROR`, `UNEXPECTED_ERROR`,
  /// `SSS_USAGE_LIMIT_EXCEEDED`, `SSS_INVALID_LOGIN_CREDENTIALS`,
  /// `SSS_REQUEST_LIMIT_EXCEEDED`, `BATCH_INSTANCE_TIMEOUT`.
  final String? errorCode;
  final String? errorMessage;
  final int? statusCode;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class OracleNetSuiteCallResult<T> {
  /// Creates a call result.
  const OracleNetSuiteCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final OracleNetSuiteResult? result;
}

/// Wraps a NetSuite call in a CLIENT span. [operation] is one of
/// `record.get`, `record.create`, `record.update`, `record.upsert`,
/// `record.delete`, `record.transform`, `record.attach`,
/// `record.detach`, `record.list`, `record.submit`,
/// `suiteql.execute`, `suiteAnalytics.query`,
/// `restlet.invoke`, `suiteTalk.search`, `suiteTalk.add`,
/// `suiteTalk.update`, `suiteTalk.delete`, `metadata.describe`,
/// `bundle.install`, `bundle.update`, `script.deploy`,
/// `scheduledScript.start`, `mapReduce.submit`, `mapReduce.status`,
/// `fileCabinet.load`, `fileCabinet.create`, `fileCabinet.delete`,
/// `auth.token`, `auth.tba.sign`.
Future<T> tracedOracleNetSuite<T>({
  required String operation,
  required Future<OracleNetSuiteCallResult<T>> Function() invoke,
}) async {
  if (oracleNetSuiteInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'oracle_netsuite',
    'rpc.method': operation,
    'oracle_netsuite.operation': operation,
  };

  final span = _tracer().startSpan(
    'oracle_netsuite $operation',
    kind: SpanKind.client,
    attributes: OTelAPI.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.account != null) {
        extras.add(OTelAPI.attributeString(
          'oracle_netsuite.account',
          res.account!,
        ));
      }
      if (res.surface != null) {
        extras.add(OTelAPI.attributeString(
          'oracle_netsuite.surface',
          res.surface!,
        ));
      }
      if (res.recordType != null) {
        extras.add(OTelAPI.attributeString(
          'oracle_netsuite.record.type',
          res.recordType!,
        ));
      }
      if (res.recordId != null) {
        extras.add(OTelAPI.attributeString(
          'oracle_netsuite.record.id',
          res.recordId!,
        ));
      }
      if (res.action != null) {
        extras.add(OTelAPI.attributeString(
          'oracle_netsuite.action',
          res.action!,
        ));
      }
      if (res.scriptType != null) {
        extras.add(OTelAPI.attributeString(
          'oracle_netsuite.script.type',
          res.scriptType!,
        ));
      }
      if (res.scriptId != null) {
        extras.add(OTelAPI.attributeString(
          'oracle_netsuite.script.id',
          res.scriptId!,
        ));
      }
      if (res.deploymentId != null) {
        extras.add(OTelAPI.attributeString(
          'oracle_netsuite.deployment.id',
          res.deploymentId!,
        ));
      }
      if (res.usagePoints != null) {
        extras.add(OTelAPI.attributeInt(
          'oracle_netsuite.usage.points',
          res.usagePoints!,
        ));
      }
      if (res.governanceRemaining != null) {
        extras.add(OTelAPI.attributeInt(
          'oracle_netsuite.governance.remaining',
          res.governanceRemaining!,
        ));
      }
      if (res.subsidiary != null) {
        extras.add(OTelAPI.attributeString(
          'oracle_netsuite.subsidiary',
          res.subsidiary!,
        ));
      }
      if (res.queryReturnedCount != null) {
        extras.add(OTelAPI.attributeInt(
          'oracle_netsuite.query.returned_count',
          res.queryReturnedCount!,
        ));
      }
      if (res.batchSize != null) {
        extras.add(OTelAPI.attributeInt(
          'oracle_netsuite.batch.size',
          res.batchSize!,
        ));
      }
      if (res.suiteQlReturned != null) {
        extras.add(OTelAPI.attributeInt(
          'oracle_netsuite.suiteql.returned',
          res.suiteQlReturned!,
        ));
      }
      if (res.fileSizeBytes != null) {
        extras.add(OTelAPI.attributeInt(
          'oracle_netsuite.file.size_bytes',
          res.fileSizeBytes!,
        ));
      }
      if (res.errorCode != null) {
        extras.add(OTelAPI.attributeString(
          'oracle_netsuite.error.code',
          res.errorCode!,
        ));
        span.setStatus(SpanStatusCode.Error, 'NetSuite ${res.errorCode}');
      }
      if (res.errorMessage != null) {
        extras.add(OTelAPI.attributeString(
          'oracle_netsuite.error.message',
          res.errorMessage!,
        ));
      }
      if (res.statusCode != null) {
        extras.add(OTelAPI.attributeInt(
          'http.response.status_code',
          res.statusCode!,
        ));
        if (res.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'NetSuite HTTP ${res.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTelAPI.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTelAPI.attributes([
      OTelAPI.attributeString(
        ErrorAttributes.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
