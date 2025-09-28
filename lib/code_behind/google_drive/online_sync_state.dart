enum OnlineSyncStateEnum {
  idle,
  syncing,
  errorWhileSync,
  syncedSucessful,
}

class OnlineSyncState {
  final OnlineSyncStateEnum state;

  /// in percent
  final double? progress;
  final String? errorMsg;

  OnlineSyncState({
    required this.state,
    this.progress,
    this.errorMsg,
  });

  bool get isIdle => state == OnlineSyncStateEnum.idle;

  bool get isSyncing => state == OnlineSyncStateEnum.syncing;

  bool get isSyncedSucessful => state == OnlineSyncStateEnum.syncedSucessful;

  bool get isErrorWhileSync => state == OnlineSyncStateEnum.errorWhileSync;
}

/*
IconData getIconForState(OnlineSyncState state) {
  switch (state) {
    case OnlineSyncState.notSynced:
      return Icons.cloud_off;
    case OnlineSyncState.syncing:
      return Icons.sync;
    case OnlineSyncState.synced:
      return Icons.cloud_done;
    case OnlineSyncState.error:
      return Icons.error;
  }
}
 */
