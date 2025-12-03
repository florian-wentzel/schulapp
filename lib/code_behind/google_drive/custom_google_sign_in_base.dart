import 'dart:async';
import 'dart:convert' show utf8, base64Url, jsonDecode;

import 'package:flutter/foundation.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart'
    as gsinall;
import 'package:google_sign_in/google_sign_in.dart' as gsin;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:schulapp/code_behind/google_auth_data.dart';

/// eine Basis-Klasse für Google Sign-In, die plattformübergreifend funktioniert
/// (für Desktop, Web google_sign_in_all_platforms, für Mobile google_sign_in)
/// Sie muss nur driveApi und currUser bereitstellen
abstract class CustomGoogleSignInBase {
  drive.DriveApi? get driveApi;
  GoogleUserData? get currUser;

  /// Alles Initialisieren und silent Sign-In versuchen
  Future<void> init();

  /// Versucht den User anzumelden, gibt true zurück wenn erfolgreich
  Future<bool> signIn();
  Future<void> signOut();

  // Future<drive.DriveApi?> _getDriveApi();
  // GoogleUserData? _getCurrUser();
}

class CustomGoogleSignInDesktop implements CustomGoogleSignInBase {
  GoogleUserData? _currUser;
  drive.DriveApi? _driveApi;

  @override
  GoogleUserData? get currUser => _currUser;

  @override
  drive.DriveApi? get driveApi => _driveApi;

  final gsinall.GoogleSignIn _googleSignIn = gsinall.GoogleSignIn(
    params: gsinall.GoogleSignInParams(
      // retrieveAccessToken: () async {
      //   return null;
      // },
      // saveAccessToken: (String token) async {
      //   print("TODO Save Accesstoken: $token");
      // },
      clientId: GoogleAuthData.serverClientId,
      clientSecret: GoogleAuthData.serverClientSecret,
      scopes: [
        drive.DriveApi.driveAppdataScope,
        "email",
        "profile",
      ],
    ),
  );

  @override
  Future<void> init() async {
    _googleSignIn.authenticationState
        .listen(_handleAuthenticationEvent)
        .onError(_handleAuthenticationError);
    _googleSignIn.silentSignIn();
  }

  @override
  Future<bool> signIn() async {
    final user = await _googleSignIn.signInOnline();
    return user != null;
  }

  @override
  Future<void> signOut() => _googleSignIn.signOut();

  Future<void> _handleAuthenticationEvent(
    gsinall.GoogleSignInCredentials? user,
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
    print("Google Sign-In Error: $e");
  }

  Future<void> _handleAfterLogInInit(
      gsinall.GoogleSignInCredentials user) async {
    _driveApi = await getDriveApi();
    _currUser = getCurrUser(user);

    print("Drive API initialized: $_currUser");
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

  GoogleUserData? getCurrUser(gsinall.GoogleSignInCredentials creds) {
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

// class CustomGoogleSignInMobile extends CustomGoogleSignInBase {}
// final gsin.GoogleSignIn _googleSignInMobile = gsin.GoogleSignIn(
//   scopes: [
//     drive.DriveApi.driveAppdataScope,
//     "email",
//     "profile",
//   ],
//   clientId: GoogleAuthData.serverClientId,
// );

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
