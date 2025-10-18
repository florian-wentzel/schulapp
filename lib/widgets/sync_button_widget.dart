import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/google_drive/online_sync_state.dart';
import 'package:schulapp/code_behind/mergable.dart';
import 'package:schulapp/code_behind/online_sync_manager.dart';
import 'package:schulapp/code_behind/utils.dart';

class SyncButtonWidget extends StatefulWidget {
  const SyncButtonWidget({super.key});

  @override
  State<SyncButtonWidget> createState() => _SyncButtonWidgetState();
}

class _SyncButtonWidgetState extends State<SyncButtonWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotationAnimation;

  OnlineSyncStateEnum? _lastSyncState;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(begin: 1, end: 0).animate(_controller);
    _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final syncManager = OnlineSyncManager();
    return StreamBuilder(
      stream: syncManager.stateStream,
      initialData: syncManager.currentState,
      builder: (context, snapshot) {
        final onlineSyncState = snapshot.data;

        if (!snapshot.hasData || onlineSyncState == null) {
          return SizedBox.shrink();
        }

        if (onlineSyncState.state != _lastSyncState) {
          _lastSyncState = onlineSyncState.state;
          if (onlineSyncState.state == OnlineSyncStateEnum.syncing &&
              !_controller.isAnimating) {
            _controller.repeat();
          } else if (_controller.isAnimating) {
            _controller.stop();
          }
        }

        Widget icon;
        void Function()? onPressed;
        String tooltip = "";

        if (onlineSyncState.isIdle) {
          icon = Icon(Icons.cloud_sync);
          tooltip = "Click to start sync";
          onPressed = () {
            syncManager.createOnlineBackup();
          };
        } else if (onlineSyncState.isSyncing) {
          icon = RotationTransition(
            turns: _rotationAnimation,
            child: Icon(Icons.sync_rounded),
          );
          tooltip =
              "Syncing (${onlineSyncState.progress?.toStringAsFixed(1)}%)";
        } else if (onlineSyncState.isSyncedSucessful) {
          icon = Icon(
            Icons.cloud_done,
            color: Colors.green,
          );
          tooltip = "Sync was Successful";
          onPressed = () {
            syncManager.createOnlineBackup();
          };
        } else if (onlineSyncState.isWaitingForUserInput) {
          icon = Icon(
            Icons.warning_amber_rounded, //help_outline
            color: Colors.orange,
          );
          tooltip = "User input required";
          onPressed = () async {
            //TODO: besseres UI
            final decision = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("Merge Error"),
                content: Text(onlineSyncState.errorMsg ?? "Unknown error"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(MergeErrorSolution.keepLocal);
                    },
                    child: Text("Behalte Lokal"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(MergeErrorSolution.keepBoth);
                    },
                    child: Text("Behalte Beide"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(MergeErrorSolution.keepRemote);
                    },
                    child: Text("Behalte Remote"),
                  ),
                ],
              ),
            );

            if (decision == null) {
              if (context.mounted) {
                Utils.showInfo(
                  context,
                  msg:
                      "Sync kann erst weitergehen, wenn du eine Auswahl triffst!",
                  type: InfoType.warning,
                  duration: Duration(seconds: 5),
                );
              }
              return;
            }

            final completer = onlineSyncState.userInputCompleter;
            if (completer != null && !completer.isCompleted) {
              completer.complete(decision);
            }
          };
        } else {
          //muss error sein
          icon = Icon(
            Icons.sync_problem,
            color: Colors.red,
          );
          tooltip =
              "There was an Error while Syncing: ${onlineSyncState.errorMsg}";
          onPressed = () {
            syncManager.createOnlineBackup();
          };
        }

        return IconButton(
          onPressed: onPressed,
          tooltip: tooltip,
          icon: icon,
        );
      },
    );
  }
}
