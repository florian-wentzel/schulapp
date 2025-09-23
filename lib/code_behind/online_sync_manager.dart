// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert' show json;
import 'dart:io' as io;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:schulapp/code_behind/google_auth_data.dart';
import 'package:schulapp/code_behind/google_drive/google_auth_client.dart';

const List<String> scopes = <String>[
  drive.DriveApi.driveAppdataScope,
];

class OnlineSyncManager {
  static final OnlineSyncManager _instance = OnlineSyncManager._internal();

  factory OnlineSyncManager() {
    return _instance;
  }

  OnlineSyncManager._internal() {
    final GoogleSignIn signIn = GoogleSignIn.instance;

    _initFuture = signIn.initialize(
      clientId: GoogleAuthData.clientId,
      serverClientId: GoogleAuthData.serverClientId,
    );

    _initFuture.then(
      (_) {
        signIn.authenticationEvents
            .listen(_handleAuthenticationEvent)
            .onError(_handleAuthenticationError);
      },
    );
  }

  late Future<void> _initFuture;
  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false; // has granted permissions?
  String _contactText = '';
  String _errorMessage = '';
  String _serverAuthCode = '';
  drive.DriveApi? _driveClient;

  String? get currentUserEmail => _currentUser?.email;

  Future<bool> signIn() async {
    final GoogleSignIn signIn = GoogleSignIn.instance;

    await _initFuture;

    return (await signIn.attemptLightweightAuthentication()) != null;
  }

  Future<void> signOut() => GoogleSignIn.instance.disconnect();

  Future<void> _handleAuthenticationEvent(
    GoogleSignInAuthenticationEvent event,
  ) async {
    final GoogleSignInAccount? user = switch (event) {
      GoogleSignInAuthenticationEventSignIn() => event.user,
      GoogleSignInAuthenticationEventSignOut() => null,
    };

    // Check for existing authorization.
    GoogleSignInClientAuthorization? authorization =
        await user?.authorizationClient.authorizationForScopes(scopes);

    if (authorization == null && user != null) {
      authorization = await user.authorizationClient.authorizeScopes(scopes);
    }

    // setState(() {
    _currentUser = user;
    _isAuthorized = authorization != null;
    _errorMessage = '';
    // });

    // If the user has already granted access to the required scopes, call the
    // REST API.
    if (user != null && authorization != null) {
      unawaited(_handleInitDrive(user));
    }
  }

  Future<void> _handleAuthenticationError(Object e) async {
    _currentUser = null;
    _isAuthorized = false;
    _errorMessage = e is GoogleSignInException
        ? _errorMessageFromSignInException(e)
        : 'Unknown error: $e';
  }

  Future<drive.DriveApi?> getDriveApi(GoogleSignInAccount googleUser) async {
    drive.DriveApi? driveApi;
    try {
      Map<String, String>? headers =
          await googleUser.authorizationClient.authorizationHeaders(scopes);

      if (headers == null) {
        return null;
      }

      GoogleAuthClient client = GoogleAuthClient(headers);
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

  Future<List<drive.File>?> getAllDriveFiles() async {
    try {
      final client = _driveClient;
      if (client == null) return null;

      drive.FileList fileList = await client.files.list(
          spaces: 'appDataFolder', $fields: 'files(id, name, modifiedTime)');

      List<drive.File>? files = fileList.files;

      return files;
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

  Future<void> _handleInitDrive(GoogleSignInAccount user) async {
    _driveClient = await getDriveApi(user);

    print("Drive API initialized: $_driveClient");
  }

  String _errorMessageFromSignInException(GoogleSignInException e) {
    // In practice, an application should likely have specific handling for most
    // or all of the, but for simplicity this just handles cancel, and reports
    // the rest as generic errors.
    return switch (e.code) {
      GoogleSignInExceptionCode.canceled => 'Sign in canceled',
      _ => 'GoogleSignInException ${e.code}: ${e.description}',
    };
  }
}
