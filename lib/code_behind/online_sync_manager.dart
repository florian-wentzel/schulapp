import 'dart:async';

// import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
// import 'package:googleapis/people/v1.dart';
// import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;

// import 'package:googleapis/drive/v3.dart';
import 'package:schulapp/code_behind/google_auth_data.dart';
import 'package:schulapp/code_behind/google_drive/google_auth_client.dart';

class OnlineSyncManager {
  OnlineSyncManager._privateConstructor();

  static final OnlineSyncManager _instance =
      OnlineSyncManager._privateConstructor();

  factory OnlineSyncManager() {
    return _instance;
  }
}

class GoogleAuthManager {
  static const List<String> scopes = <String>[
    drive.DriveApi.driveAppdataScope,
  ];

  GoogleAuthManager._privateConstructor();

  static final GoogleAuthManager _instance =
      GoogleAuthManager._privateConstructor();

  factory GoogleAuthManager() {
    return _instance;
  }

  late Future<void> _signInInitialized;
  GoogleSignInAccount? _currentUser;
  GoogleSignInClientAuthorization? _authorization;

  String? get currentUserEmail => _currentUser?.email;

  Future<void> init() async {
    final GoogleSignIn signIn = GoogleSignIn.instance;

    _signInInitialized = signIn.initialize(
      clientId:
          kDebugMode ? GoogleAuthData.debugClientId : GoogleAuthData.clientId,
      serverClientId: GoogleAuthData.serverClientId,
    );

    signIn.authenticationEvents.listen((GoogleSignInAuthenticationEvent event) {
      switch (event) {
        case GoogleSignInAuthenticationEventSignIn():
          _currentUser = event.user;
        case GoogleSignInAuthenticationEventSignOut():
          _currentUser = null;
          _authorization = null;
      }

      if (_currentUser != null) {
        _checkAuthorization();
      }
    }).onError((Object error) {
      debugPrint(error.toString());
    });

    _signInInitialized.then((void value) {
      signIn.attemptLightweightAuthentication();
    });
  }

  Future<String?> signIn() async {
    try {
      await GoogleSignIn.instance.authenticate(scopeHint: scopes);
      return null;
    } catch (error) {
      debugPrint(error.toString());
      return error.toString();
    }
  }

  // Call disconnect rather than signOut to more fully reset the example app.
  Future<void> signOut() => GoogleSignIn.instance.disconnect();

  Future<void> _checkAuthorization() async {
    _updateAuthorization(
      await _currentUser?.authorizationClient.authorizationForScopes(scopes),
    );
  }

  void _updateAuthorization(GoogleSignInClientAuthorization? authorization) {
    _authorization = authorization;

    if (authorization != null) {
      unawaited(_handleGetContact(authorization));
    }
  }

  Future<void> _handleGetContact(
    GoogleSignInClientAuthorization authorization,
  ) async {
    print("Authorized");
    // // setState(() {
    // //   _contactText = 'Loading contact info...';
    // // });

    // // #docregion CreateAPIClient
    // // Retrieve an [auth.AuthClient] from a GoogleSignInClientAuthorization.
    // final auth.AuthClient client = authorization.authClient(scopes: scopes);

    // // Prepare a People Service authenticated client.
    // final PeopleServiceApi peopleApi = PeopleServiceApi(client);
    // // Retrieve a list of connected contacts' names.
    // final ListConnectionsResponse response = await peopleApi.people.connections
    //     .list('people/me', personFields: 'names');
    // // #enddocregion CreateAPIClient

    // final String? firstNamedContactName = _pickFirstNamedContact(
    //   response.connections,
    // );

    // if (mounted) {
    //   setState(() {
    //     if (firstNamedContactName != null) {
    //       _contactText = 'I see you know $firstNamedContactName!';
    //     } else {
    //       _contactText = 'No contacts to display.';
    //     }
    //   });
    // }
  }

  Future<drive.DriveApi?> getDriveApi() async {
    drive.DriveApi? driveApi;
    try {
      Map<String, String>? headers =
          await _currentUser?.authorizationClient.authorizationHeaders(
        scopes,
      );
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
}
