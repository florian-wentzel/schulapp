import 'dart:async';

import 'package:schulapp/code_behind/mergable.dart';

enum OnlineSyncStateEnum {
  idle,
  syncing,
  errorWhileSync,
  syncedSucessful,
  // if there was an error while merging
  waitingForUserInput,
  // TODO: not signed in
}

class OnlineSyncState {
  final OnlineSyncStateEnum state;

  /// in percent
  final int? progress;
  //Wenn Fehler auftreten oder wenn user input benötigt wird
  final String? errorMsg;
  final Completer<MergeErrorSolution>? userInputCompleter;

  OnlineSyncState({
    required this.state,
    this.progress,
    this.errorMsg,
    this.userInputCompleter,
  });

  bool get isIdle => state == OnlineSyncStateEnum.idle;

  bool get isSyncing => state == OnlineSyncStateEnum.syncing;

  bool get isSyncedSucessful => state == OnlineSyncStateEnum.syncedSucessful;

  bool get isErrorWhileSync => state == OnlineSyncStateEnum.errorWhileSync;

  bool get isWaitingForUserInput =>
      state == OnlineSyncStateEnum.waitingForUserInput;
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
