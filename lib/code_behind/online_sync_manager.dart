import 'dart:async';
import 'dart:convert' show utf8, base64Url, jsonDecode;
import 'dart:io' as io;
import 'dart:isolate';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';
import 'package:path/path.dart' as path;
import 'package:schulapp/code_behind/google_auth_data.dart';
import 'package:schulapp/code_behind/google_drive/online_sync_state.dart';

class OnlineSyncManager {
  static final OnlineSyncManager _instance = OnlineSyncManager._internal();

  factory OnlineSyncManager() {
    return _instance;
  }

  OnlineSyncManager._internal() {
    _googleSignIn.authenticationState
        .listen(_handleAuthenticationEvent)
        .onError(_handleAuthenticationError);
    _googleSignIn.silentSignIn();
    _setStreamState(_currentState);
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    params: const GoogleSignInParams(
      clientId: GoogleAuthData.serverClientId,
      clientSecret: GoogleAuthData.serverClientSecret,
      scopes: [
        drive.DriveApi.driveAppdataScope,
        "email",
        "profile",
      ],
    ),
  );

  drive.DriveApi? _driveClient;
  GoogleUserData? _currUserData;

  String? get currentUserName => _currUserData?.name;
  String? get currentUserEmail => _currUserData?.email;

  Future<bool> signIn() async {
    final user = await _googleSignIn.signIn();
    return user != null;
  }

  Future<void> signOut() => _googleSignIn.signOut();

  StreamSubscription<dynamic>? _onlineBackupSubscription;
  bool get isCreatingOnlineBackup => _onlineBackupSubscription != null;

  /// Stream shit
  final StreamController<OnlineSyncState> _stateController =
      StreamController<OnlineSyncState>.broadcast();

  // replace with BehaviorSubject?
  Stream<OnlineSyncState> get stateStream => _stateController.stream;
  OnlineSyncState _currentState = OnlineSyncState(
    state: OnlineSyncStateEnum.idle,
  );
  OnlineSyncState get currentState => _currentState;

  void _setStreamState(OnlineSyncState state) {
    _currentState = state;
    _stateController.add(state);
  }

  Future<void> _handleAuthenticationEvent(
    GoogleSignInCredentials? user,
  ) async {
    final loggedin = user != null;

    if (loggedin) {
      unawaited(_handleAfterLogInInit(user));
    }
  }

  Future<void> _handleAuthenticationError(Object e) async {
    // _isAuthorized = false;
    // _errorMessage = e is GoogleSignInException
    //     ? _errorMessageFromSignInException(e)
    //     : 'Unknown error: $e';
  }

  Future<drive.DriveApi?> getDriveApi() async {
    drive.DriveApi? driveApi;
    try {
      final client = await _googleSignIn.authenticatedClient;

      if (client == null) return null;

      driveApi = drive.DriveApi(client);
    } catch (e) {
      debugPrint(e.toString());
    }
    return driveApi;
  }

  Future<drive.File?> getDriveFile(String filename) async {
    try {
      final client = _driveClient;
      if (client == null) return null;

      drive.FileList fileList = await client.files.list(
          spaces: 'appDataFolder', $fields: 'files(id, name, modifiedTime)');

      List<drive.File>? files = fileList.files;

      drive.File? driveFile =
          files?.firstWhere((element) => element.name == filename);
      return driveFile;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<Map<String, drive.File>?> getAllDriveFiles() async {
    try {
      final client = _driveClient;
      if (client == null) return null;

      drive.FileList fileList = await client.files.list(
          spaces: 'appDataFolder',
          $fields: 'files(id, name, modifiedTime, parents, createdTime, size)');

      List<drive.File>? files = fileList.files;

      if (files == null) return null;

      Map<String, drive.File> fileMap = {};

      for (int i = 0; i < files.length; i++) {
        final id = files[i].id;
        if (id != null) {
          fileMap[id] = files[i];
        } else {
          debugPrint("File without ID found: ${files[i]}");
        }
      }

      return fileMap;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<drive.File?> uploadDriveFile({
    required io.File file,
    String? driveFileId,
    drive.DriveApi? driveApi,
  }) async {
    driveApi ??= _driveClient;

    if (driveApi == null) return null;

    try {
      drive.File fileMetadata = drive.File();
      fileMetadata.name = path.basename(file.absolute.path);

      late drive.File response;
      if (driveFileId != null) {
        /// [driveFileId] not null means we want to update existing file
        response = await driveApi.files.update(
          fileMetadata,
          driveFileId,
          uploadMedia: drive.Media(file.openRead(), file.lengthSync()),
        );
      } else {
        /// [driveFileId] is null means we want to create new file
        fileMetadata.parents = ['appDataFolder'];
        response = await driveApi.files.create(
          fileMetadata,
          uploadMedia: drive.Media(file.openRead(), file.lengthSync()),
        );
      }
      return response;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<io.File?> downloadDriveFile({
    required drive.File driveFile,
    required String targetLocalPath,
  }) async {
    try {
      final client = _driveClient;

      if (client == null) return null;

      drive.Media media = await client.files.get(driveFile.id!,
          downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;

      List<int> dataStore = [];

      await media.stream.forEach((element) {
        dataStore.addAll(element);
      });

      io.File file = io.File(targetLocalPath);
      file.writeAsBytesSync(dataStore);

      return file;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<GoogleUserData?> getCurrUser(GoogleSignInCredentials creds) async {
    final parts = creds.idToken?.split('.');

    if (parts == null || parts.length != 3) {
      return null;
    }

    final payload = utf8.decode(
      base64Url.decode(
        base64Url.normalize(parts[1]),
      ),
    );

    final Map<String, dynamic> claims = jsonDecode(payload);

    final email = claims['email'];
    final name = claims['name'];
    final picture = claims['picture'];
    final sub = claims['sub']; // user’s unique Google ID

    if (email == null || name == null || picture == null || sub == null) {
      return null;
    }

    return GoogleUserData(
      email: email,
      name: name,
      picture: picture,
      sub: sub,
    );
  }

  Future<void> _handleAfterLogInInit(GoogleSignInCredentials user) async {
    _driveClient = await getDriveApi();
    _currUserData = await getCurrUser(user);

    print("Drive API initialized: $_currUserData");
  }

  // upload version.json with info about backup and who uploaded it
  // vielleicht nicht als .zip speichern damit man einzelne datein hochladen kann?
  Future<OnlineSyncState?> createOnlineBackup() async {
    final alreadyRunningSub = _onlineBackupSubscription;
    if (alreadyRunningSub != null) {
      return alreadyRunningSub.asFuture();
    }

    _setStreamState(
      OnlineSyncState(
        state: OnlineSyncStateEnum.syncing,
        progress: 0,
      ),
    );

    void task(SendPort port) async {
      try {
        for (int i = 0; i < 10; i++) {
          port.send(
            OnlineSyncState(
                state: OnlineSyncStateEnum.syncing, progress: i / 10),
          );
          if (i == 7) throw "Test";
          await Future<void>.delayed(const Duration(seconds: 2));
        }
        port.send(
          OnlineSyncState(
            state: OnlineSyncStateEnum.syncedSucessful,
            progress: 100,
          ),
        );
      } catch (e) {
        port.send(
          OnlineSyncState(
            state: OnlineSyncStateEnum.errorWhileSync,
            errorMsg: e.toString(),
          ),
        );
      }
    }

    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn(
      task,
      receivePort.sendPort,
      debugName: kDebugMode ? "createOnlineBackup" : null,
    );

    void kill() {
      isolate.kill(priority: Isolate.immediate);
      _onlineBackupSubscription?.cancel();
      receivePort.close();
      _onlineBackupSubscription = null;
    }

    _onlineBackupSubscription = receivePort.listen(
      (state) {
        assert(state is OnlineSyncState);
        if (state is OnlineSyncState) {
          _setStreamState(state);
          if (!state.isSyncing) {
            kill();
          }
        }
      },
      onError: (e) {
        _setStreamState(
          OnlineSyncState(
            state: OnlineSyncStateEnum.errorWhileSync,
            errorMsg: e.toString(),
          ),
        );
        kill();
      },
      onDone: () {
        kill();
      },
    );

    return _onlineBackupSubscription?.asFuture() ??
        Future.value(
          OnlineSyncState(
            state: OnlineSyncStateEnum.idle,
          ),
        );
  }

  Future<drive.File?> createDriveFolder(
    String name, {
    drive.DriveApi? driveApi,
    String? parentId,
  }) async {
    driveApi ??= _driveClient;

    if (driveApi == null) return null;

    final folder = drive.File()
      ..name = name
      ..mimeType = 'application/vnd.google-apps.folder';

    folder.parents = [parentId ?? 'appDataFolder'];

    final created = await driveApi.files.create(folder);
    return created;
  }

  // vielleicht kann man das später noch hinzufügn
  // String _errorMessageFromSignInException(GoogleSignInException e) {
  //   // In practice, an application should likely have specific handling for most
  //   // or all of the, but for simplicity this just handles cancel, and reports
  //   // the rest as generic errors.
  //   return switch (e.code) {
  //     GoogleSignInExceptionCode.canceled => 'Sign in canceled',
  //     _ => 'GoogleSignInException ${e.code}: ${e.description}',
  //   };
  // }
}

/// Custom class for saving user data from Googl login
class GoogleUserData {
  GoogleUserData({
    required this.email,
    required this.name,
    required this.picture,
    required this.sub,
  });

  final String email;
  final String name;
  final String picture;
  final String sub;

  @override
  String toString() {
    return 'GoogleUserData{email: $email, name: $name, picture: $picture, sub: $sub}';
  }
}
