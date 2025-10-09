import 'dart:async';
import 'dart:convert' show utf8, base64Url, jsonDecode, jsonEncode;
import 'dart:io' as io;
import 'dart:math';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';
import 'package:path/path.dart' as path;
import 'package:schulapp/code_behind/google_auth_data.dart';
import 'package:schulapp/code_behind/google_drive/online_sync_state.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/code_behind/school_file.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/code_behind/todo_event.dart';
import 'package:schulapp/code_behind/version_manager.dart';

//damit man global sehen kann was der letzte Sync war
//Die klassen speichern dann einzeln selber wann sie zuletzt bearbeitet worden
//sind, somit weiß man was hochzuladen ist und was nicht..
class OnlineSyncManager {
  static const infoJsonFileName = "info.json";
  static const lastSyncTimeKey = "lastSyncTime";
  static const infoLastUpdatedKey = "infoLastUpdated";
  static const syncingKey = "syncing";
  static const appVersionKey = "appVersion";

  static const maxSyncTime = 5; //Minutes

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
    _lastSyncTime =
        TimetableManager().settings.getVar(Settings.lastSyncTimeKey);
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

  DateTime? _lastSyncTime;
  DateTime? get lastSyncTime => _lastSyncTime;

  drive.DriveApi? _driveClient;
  GoogleUserData? _currUserData;

  String? get currentUserName => _currUserData?.name;
  String? get currentUserEmail => _currUserData?.email;

  Future<bool> signIn() async {
    final user = await _googleSignIn.signIn();
    return user != null;
  }

  Future<void> signOut() => _googleSignIn.signOut();

  Future<OnlineSyncState>? _createOnlineBackupFuture;
  bool get isCreatingOnlineBackup => _createOnlineBackupFuture != null;

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
          $fields: 'files(id, name, modifiedTime, parents, mimeType)');

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

  Future<drive.File?> uploadDriveFileFromBytes({
    required String name,
    required Uint8List data,
    required String? id,
    required String parentId,
  }) async {
    final driveApi = _driveClient;

    if (driveApi == null) return null;

    drive.File fileMetadata = drive.File();
    fileMetadata.name = name;
    fileMetadata.parents = [parentId];

    late drive.File response;
    final stream = Stream.value(data);
    if (id != null) {
      /// [driveFileId] not null means we want to update existing file
      response = await driveApi.files.update(
        fileMetadata,
        id,
        uploadMedia: drive.Media(stream, data.length),
      );
    } else {
      /// [driveFileId] is null means we want to create new file
      response = await driveApi.files.create(
        fileMetadata,
        uploadMedia: drive.Media(stream, data.length),
      );
    }

    return response;
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

  Future<Uint8List?> downloadDriveFileAsBytes({
    required String driveFileId,
  }) async {
    try {
      final client = _driveClient;

      if (client == null) return null;

      drive.Media media = await client.files.get(
        driveFileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      List<int> dataStore = [];

      await media.stream.forEach((element) {
        dataStore.addAll(element);
      });

      return Uint8List.fromList(dataStore);
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

  GoogleUserData? getCurrUser(GoogleSignInCredentials creds) {
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
    _currUserData = getCurrUser(user);

    print("Drive API initialized: $_currUserData");
  }

  static const _folderMimeType = "application/vnd.google-apps.folder";

  Future<OnlineSyncState> _createOnlineBackupFutureImpl() async {
    _setStreamState(
      OnlineSyncState(
        state: OnlineSyncStateEnum.syncing,
        progress: 1,
      ),
    );

    final driveFiles = await getAllDriveFiles();

    if (driveFiles == null) {
      throw Exception("Could not get files from Google Drive");
    }

    SchoolDirectory driveFilesDir = SchoolDirectory("appDataFolder");

    _listToFileTree(
      driveFiles,
      driveFilesDir,
    );

    final infoFile = driveFilesDir.getChildByName(infoJsonFileName);

    if (infoFile == null && driveFiles.isNotEmpty) {
      print(
          "info.json file not found in Drive files, but other files are present. This should not happen.");
    }

    if (infoFile is! SchoolFile?) {
      throw "info.json file is not a SchoolFile";
    }

    String? existingInfoFileId; //hier weitermachen
    DateTime? driveLastSyncTime;
    DateTime? infoLastUpdatedTime;
    String? lastSyncVersion;
    bool isSyncing = false;

    //wenn hier ein ein Fehler passiert, vielleicht von gestern ausgehen
    if (infoFile != null) {
      final Map<String, dynamic> infoJson = await infoFile.getContentAsJson();

      final lastSyncTimeString = infoJson[lastSyncTimeKey] as String?;
      if (lastSyncTimeString != null) {
        driveLastSyncTime = DateTime.tryParse(lastSyncTimeString);
        // if (_lastSyncTime != null) {
        //   TimetableManager()
        //       .settings
        //       .setVar(Settings.lastSyncTimeKey, _lastSyncTime);
        // }
      }

      final appVersion = infoJson[appVersionKey] as String?;
      if (appVersion != null) {
        lastSyncVersion = appVersion;
      }

      final infoLastUpdatedString = infoJson[infoLastUpdatedKey] as String?;
      if (infoLastUpdatedString != null) {
        infoLastUpdatedTime = DateTime.tryParse(infoLastUpdatedString);
      }

      final syncing = infoJson[syncingKey] as bool?;
      if (syncing != null) {
        isSyncing = syncing;
      }
    }

    if (isSyncing && infoLastUpdatedTime != null) {
      final difference = DateTime.now().difference(infoLastUpdatedTime);
      if (difference.inMinutes < maxSyncTime) {
        //Wenn der letzte Sync weniger als maxSyncTime Minuten her ist, dann abbrechen
        throw "Last sync was ${difference.inMinutes} min ago, wait at least $maxSyncTime minutes, another sync might be running...";
      }
    }

    await _updateInfoJson(
      lastSyncTime: driveLastSyncTime ?? DateTime.now(),
      syncing: true,
      appVersion: lastSyncVersion,
    );

    debugPrint(
      "driveLastSyncTime: $driveLastSyncTime | lastSyncVersion: $lastSyncVersion",
    );

    _setStreamState(
      OnlineSyncState(
        state: OnlineSyncStateEnum.syncing,
        progress: 10,
      ),
    );

    final allLocalFiles = SaveManager().getAllSchoolFiles();

    /// Wir zählen dirs nicht mit
    int countFilesAndDirs(List<SchoolFileBase> files, int currCount) {
      for (var file in files) {
        if (file is SchoolFile) {
          currCount++;
          continue;
        }
        if (file is SchoolDirectory) {
          // currCount++; //weil wir dirs mitzählen
          currCount += countFilesAndDirs(file.children, 0);
          continue;
        }
      }
      return currCount;
    }

    int localFilesCount = countFilesAndDirs(allLocalFiles, 0);
    int remoteFilesCount = countFilesAndDirs(driveFilesDir.children, 0);

    int totalFilesCount = max(localFilesCount, remoteFilesCount);
    int processedFilesCount = 0;

    print(
      "Local files count: $localFilesCount | Remote files count: $remoteFilesCount | Total files count: $totalFilesCount",
    );

    void updateProgress() {
      processedFilesCount++;
      double progress =
          10 + (processedFilesCount / totalFilesCount) * 90; // 10 to 100
      _setStreamState(
        OnlineSyncState(
          state: OnlineSyncStateEnum.syncing,
          progress: progress.toInt(),
        ),
      );
    }

    /// wenn meine Ändrungen neuer sind als die auf dem server
    /// dann zuerst durch die lokalen datein gehen und alles hochladen was neuer ist
    /// dann durch die datein auf dem server gehen und alles runterladen was neuer ist
    ///
    /// Jetzt gehe ich davon aus, dass lokale immer neuer sind als die auf dem servers
    /// zum testen..

    // Future<void> mergeDirs(
    //   SchoolDirectory localDir,
    //   SchoolDirectory remoteDir,
    //   Future<(SchoolFile?, bool upload)> Function(
    //     SchoolFile localChild,
    //     SchoolFile remoteChild,
    //   )? mergeFilesCB,
    // ) async {
    //   for (var localChild in localDir.children) {
    //     final remoteChild = remoteDir.getChildByName(localChild.name);

    //     if (localChild is SchoolDirectory) {
    //       if (remoteChild == null) {
    //         //Upload local directory
    //         continue;
    //       }
    //       if (remoteChild is! SchoolDirectory) {
    //         throw "Remote is not a Dir ${remoteChild.name}";
    //       }
    //       await mergeDirs(localChild, remoteChild);
    //       continue;
    //     }
    //     if (localChild is SchoolFile) {
    //       if (remoteChild == null) {
    //         //upload local file
    //         updateProgress();
    //         continue;
    //       }
    //       if (remoteChild is! SchoolFile) {
    //         throw "Remote is not a File ${remoteChild.name}";
    //       }

    //       final (SchoolFile?, bool upload)? response = await mergeFilesCB?.call(
    //         localChild,
    //         remoteChild,
    //       );

    //       final mergedFile = response?.$1;
    //       final uploadFile = response?.$2;

    //       /// Serverfile is newer -> file not upload
    //       /// Localfile is newer -> file and upload
    //       /// Files need to be merged -> file and upload
    //       /// Error while merging -> null
    //       updateProgress();
    //       continue;
    //     }

    //     assert(false, "Something went wrong, localChild is on File nor Dir");
    //   }
    // }

    // mergeDirs(
    //   SchoolDirectory("appDataFolder", children: allLocalFiles),
    //   driveFilesDir,
    // );

    Map<String, Future<bool> Function(SchoolFileBase, SchoolFileBase)>
        dirOrFileNameToWhatToDoWithFile = {
      SaveManager.todoEventSaveDirName: (
        SchoolFileBase localParent,
        SchoolFileBase remoteParent,
      ) async {
        if (localParent is! SchoolDirectory) {
          throw "local is not SchoolDir";
        }
        if (remoteParent is! SchoolDirectory) {
          throw "remote is not SchoolDir";
        }

        final localChildren = localParent.children;
        final remoteChildren = remoteParent.children;

        if (localChildren.length > 1) {
          throw "Local TodoEvent has more than one child: $localChildren";
        }
        if (remoteChildren.length > 1) {
          throw "Remote TodoEvent has more than one child: $remoteChildren";
        }

        final localFile = localChildren.firstOrNull;
        final remoteFile = remoteChildren.firstOrNull;

        if (localFile == null) {
          throw "Local todoevent file isnt there!";
        }
        if (localFile is! SchoolFile) {
          throw "local todoevent file is not a file?!";
        }
        if (remoteFile is! SchoolFile?) {
          throw "remote todoevent file is not a file?!";
        }

        final remoteMap = await remoteFile?.getContentAsJson();
        List<TodoEvent>? remoteTodos = remoteMap == null
            ? null
            : SaveManager().todoEventsFromJson(
                remoteMap,
              );

        //Weil die create Content funktion die gleichen daten nimmt, wäre es unnötig das hier dann zu parsen..
        List<TodoEvent> localTodos = TimetableManager().todoEvents;

        if (remoteTodos == null || remoteTodos.isEmpty) {
          //upload
          final parentId = remoteParent.driveId;
          if (parentId == null) throw "parentId not set";
          await uploadDriveFileFromBytes(
            name: localFile.name,
            data: await localFile.content,
            id: remoteFile?.driveId,
            parentId: parentId,
          );
          return true;
        }

        //hier fängt das eigentliche mergen an

        List<TodoEvent> mergedTodos = [];

        for (var localTodo in localTodos) {
          final remoteTodo = remoteTodos.cast<TodoEvent?>().firstWhere(
                (todoEvent) => todoEvent?.uid == localTodo.uid,
              );

          if (remoteTodo == null) {
            /// Wenn server das Todo nicht hat, dann einfach lokale Version hochladen
            mergedTodos.add(localTodo);
            continue;
          }

          final mergedTodo = localTodo.merge(remoteTodo);
          mergedTodos.add(mergedTodo);
        }

        //upload merged
        return true;
      },
    };

    for (var localFile in allLocalFiles) {
      final remoteFile = driveFilesDir.getChildByName(localFile.name);

      if (localFile is SchoolDirectory) {
        if (remoteFile == null) {
          await _addFolderContentToDrive(
            [localFile],
            "appDataFolder",
            updateProgress,
          );
          continue;
        }

        if (remoteFile is! SchoolDirectory) {
          throw "Remote is not a Dir ${remoteFile.name}";
        }

        final result =
            await dirOrFileNameToWhatToDoWithFile[localFile.name]?.call(
          localFile,
          remoteFile,
        );

        if (result == null) {
          // Print error in red
          print(
              '\x1B[31mERROR: No handler for directory ${localFile.name}\x1B[0m');
          continue;
        }
        if (!result) {
          throw "Merging of ${localFile.name} failed";
        }
        continue;
      }
      if (localFile is SchoolFile) {
        if (remoteFile == null) {
          await _addFolderContentToDrive(
            [localFile],
            "appDataFolder",
            updateProgress,
          );
          continue;
        }
        if (remoteFile is! SchoolFile) {
          throw "Remote is not a File ${remoteFile.name}";
        }

        //TODO vergleichen ob remoteFile neuer ist als localFile
        //wenn ja, dann runterladen
        //wenn nein, dann hochladen
        //wenn gleich, dann nix tun

        // await _addFolderContentToDrive([localFile], "appDataFolder");
        updateProgress();
        continue;
      }
    }

    await _updateInfoJson(
      lastSyncTime: DateTime.now(),
      syncing: false,
    );

    while (processedFilesCount < totalFilesCount) {
      updateProgress();
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }

    /// Upload
    // await addFolderContentToDrive(allFiles, "appDataFolder");

    return OnlineSyncState(
      state: OnlineSyncStateEnum.syncedSucessful,
    );

    // alles was nicht schon onineist wird hochgeladen
    // alles was schon online ist und sich nicht geändert hat wird übersprungen
    // alles was schon online ist und sich geändert hat wird überschrieben?

    // for (int i = 0; i < 10; i++) {
    //   _setStreamState(
    //     OnlineSyncState(
    //         state: OnlineSyncStateEnum.syncing, progress: i / 10),
    //   );
    //   await Future<void>.delayed(const Duration(seconds: 2));
    // }

    // return OnlineSyncState(
    //   state: OnlineSyncStateEnum.syncedSucessful,
    //   progress: 100,
    // );
  }

  Future<drive.File> _updateInfoJson({
    required DateTime lastSyncTime,
    required bool syncing,
    required String? existingFileId,
    String? appVersion,
  }) async {
    Map<String, dynamic> infoJson = {
      infoLastUpdatedKey: DateTime.now().toUtc().toIso8601String(),
      syncingKey: syncing,
      lastSyncTimeKey: lastSyncTime.toUtc().toIso8601String(),
      appVersionKey: appVersion ??
          await VersionManager().getVersionWithBuildnumberString(),
      // TODO: könnte man noch hinzufügen..
      // "user": {
      //   "name": _currUserData?.name,
      //   "email": _currUserData?.email,
      //   "id": _currUserData?.sub,
      // },
    };

    final response = await uploadDriveFileFromBytes(
      name: infoJsonFileName,
      data: utf8.encode(jsonEncode(infoJson)),
      id: existingFileId,
      parentId: "appDataFolder",
    );

    if (response == null) {
      throw "info.json konnte nicht angepasst werden";
    }

    return response;
  }

  Future<void> _addFolderContentToDrive(
    List<SchoolFileBase> files,
    String parentId,
    void Function() updateProgress,
  ) async {
    for (var dir in files) {
      if (dir is! SchoolDirectory) {
        continue;
      }

      final createdFolder = await createDriveFolder(
        dir.name,
        parentId: parentId,
      );

      final id = createdFolder?.id;

      if (createdFolder == null || id == null) {
        throw "'${dir.name}' konnte nicht erstellt werden!";
      }

      await _addFolderContentToDrive(
        dir.children,
        id,
        updateProgress,
      );
    }

    for (var file in files) {
      if (file is! SchoolFile) {
        continue;
      }

      final uploadedFile = await uploadDriveFileFromBytes(
        name: file.name,
        data: await file.content,
        id: file.driveId,
        parentId: parentId,
      );

      if (uploadedFile == null) {
        throw "File '${file.name}' could not be uploaded!";
      }

      updateProgress();
    }
  }

  Future<OnlineSyncState> createOnlineBackup() async {
    final alreadyRunningFuture = _createOnlineBackupFuture;
    if (alreadyRunningFuture != null) {
      return alreadyRunningFuture;
    }

    _setStreamState(
      OnlineSyncState(
        state: OnlineSyncStateEnum.syncing,
        progress: 0,
      ),
    );

    // upload version.json with info about backup and who uploaded it
    // vielleicht nicht als .zip speichern damit man einzelne datein hochladen kann?

    _createOnlineBackupFuture = _createOnlineBackupFutureImpl();

    //TODO überprüfen ob then auch freigegeben wird
    _createOnlineBackupFuture?.then(
      (state) {
        _createOnlineBackupFuture = null;
        _setStreamState(
          state,
        );
      },
      onError: (e) {
        _createOnlineBackupFuture = null;
        _setStreamState(
          OnlineSyncState(
            state: OnlineSyncStateEnum.errorWhileSync,
            errorMsg: e.toString(),
          ),
        );
      },
    );

    return _createOnlineBackupFuture ??
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

  void _listToFileTree(
    Map<String, drive.File> files,
    SchoolDirectory driveFilesDir,
  ) {
    Map<String, SchoolFileBase> lookUpMap = {};

    /// Zuerst nur Folder
    /// vielleicht noch sortieren?
    for (var entry in files.entries) {
      if (entry.value.mimeType != _folderMimeType) {
        continue;
      }
      final name = entry.value.name;
      // final modifiedTime = entry.value.modifiedTime;
      if (name == null) throw "DriveFolder has no name!";

      final id = entry.value.id;
      if (id == null) throw "DriveFolder has no id: $name";

      final parentId = entry.value.parents?.first;
      if (parentId == null) {
        throw "DriveFolder has no parentId: $name";
      }

      final folder = SchoolDirectory(
        name,
        driveId: id,
      );

      // currParent.addChild(folder);
      lookUpMap[id] = folder;
    }

    /// Anschließend die Datein hinzufügen und auch die parents der Ordner setzen
    for (var entry in files.entries) {
      if (entry.value.mimeType == _folderMimeType) {
        final parentId = entry.value.parents?.first;
        final parent = lookUpMap[parentId] ?? driveFilesDir;
        print(
            "Folder | ${entry.value.name} | ${entry.value.modifiedTime} | parent: $parent");

        if (parent is! SchoolDirectory) {
          throw "Parent is not a directory: $parentId | $parent";
        }
        final folder = lookUpMap[entry.key];
        if (folder == null) {
          throw "Folder not found in lookup map: ${entry.value.name}";
        }
        parent.addChild(folder);
        continue;
      }
      final name = entry.value.name;
      final modifiedTime = entry.value.modifiedTime;

      if (name == null) {
        throw "DriveFile has no name: $name";
      }
      if (modifiedTime == null) {
        throw "DriveFile has no modifiedTime: $name";
      }

      final file = SchoolFile(
        name,
        contentGenerator: () async {
          final id = entry.value.id;
          if (id == null) {
            throw "DriveFile has no id: $name";
          }

          final bytes = await downloadDriveFileAsBytes(driveFileId: id);

          if (bytes == null) {
            throw "Could not download file as bytes: $name";
          }

          return bytes;
          // final file = await downloadDriveFile(
          //   driveFile: entry.value,
          //   targetLocalPath:
          //       path.join(io.Directory.systemTemp.path, entry.value.name!),
          // );
          // if (file == null) {
          //   throw "Could not download file: ${entry.value.name}";
          // }
          // return file.readAsBytes();
        },
        modifiedTime: modifiedTime,
      );
      final parentId = entry.value.parents?.first;
      if (parentId == null) {
        throw "DriveFile has no parentId: $name";
      }
      final parent = lookUpMap[parentId] ?? driveFilesDir;
      // if (parent == null) {
      //   throw "DriveFile parent not found in lookup map: $parentId | $name";
      // }
      if (parent is! SchoolDirectory) {
        throw "DriveFile parent is not a directory: $parentId | $parent | $name";
      }
      parent.addChild(file);
      print(
          "File | ${entry.value.name} | ${entry.value.modifiedTime} | parent: $parent");
    }
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

/// kann man vielleicht gebrauchen
// enum MergeFileContainerState {
//   downloadedRemoteSuccessful,
//   uploadedLocalSuccessful,
//   merged
// }

// class MergeFileContainer {
//   SchoolFile mergedFile;
//   MergeFileContainerState state;

//   MergeFileContainer({
//     required this.mergedFile,
//     required this.state,
//   });
// }

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
