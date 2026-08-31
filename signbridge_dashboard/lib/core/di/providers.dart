import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signbridge_dashboard/core/models/activity_log_entry.dart';
import 'package:signbridge_dashboard/core/models/bridge_message.dart';
import 'package:signbridge_dashboard/services/activity_log_service.dart';
import 'package:signbridge_dashboard/services/mock/mock_activity_log_service.dart';
import 'package:signbridge_dashboard/services/mock/mock_office_kit_client_service.dart';
import 'package:signbridge_dashboard/services/office_kit_client_service.dart';
import 'package:signbridge_dashboard/services/real/hive_activity_log_service.dart';
import 'package:signbridge_dashboard/services/real/real_office_kit_client_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Feature flag — automatically active on web or when explicitly set.
// ─────────────────────────────────────────────────────────────────────────────
const bool useMockServices = kIsWeb;

// ─────────────────────────────────────────────────────────────────────────────
// Service Providers
// ─────────────────────────────────────────────────────────────────────────────

final Provider<ActivityLogService> activityLogServiceProvider =
    Provider<ActivityLogService>((Ref ref) {
  if (useMockServices) return MockActivityLogService();
  return HiveActivityLogService();
});

final Provider<OfficeKitClientService> clientServiceProvider =
    Provider<OfficeKitClientService>((Ref ref) {
  if (useMockServices) {
    final MockOfficeKitClientService mock = MockOfficeKitClientService();
    mock.startMock();
    ref.onDispose(mock.dispose);
    return mock;
  }
  final ActivityLogService logService = ref.watch(activityLogServiceProvider);
  final RealOfficeKitClientService service = RealOfficeKitClientService(logService);
  ref.onDispose(service.dispose);
  return service;
});

// ─────────────────────────────────────────────────────────────────────────────
// Derived state providers
// ─────────────────────────────────────────────────────────────────────────────

/// Stream of all incoming bridge messages for the dashboard panels.
final StreamProvider<BridgeMessage> incomingMessageStreamProvider =
    StreamProvider<BridgeMessage>((Ref ref) {
  final OfficeKitClientService service = ref.watch(clientServiceProvider);
  return service.incomingMessageStream;
});

/// Stream of client connection state for the status badge.
final StreamProvider<ClientConnectionState> clientConnectionStateProvider =
    StreamProvider<ClientConnectionState>((Ref ref) {
  final OfficeKitClientService service = ref.watch(clientServiceProvider);
  return service.connectionStateStream;
});

/// Stream of activity log entries for the Logs panel.
final StreamProvider<ActivityLogEntry> activityLogStreamProvider =
    StreamProvider<ActivityLogEntry>((Ref ref) {
  final ActivityLogService service = ref.watch(activityLogServiceProvider);
  return service.logStream;
});
