// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:googleapis_auth/auth_io.dart';

const String _firestoreBase =
    'https://firestore.googleapis.com/v1/projects/connecthub-57eb5/databases/(default)/documents';
const String _serviceAccountPath = 'tool/service-account.json';

Future<void> main(List<String> args) async {
  print('====================================================');
  print('   ConnectHub - Clear Firestore Demo Data           ');
  print('====================================================\n');

  final token = await _resolveAccessToken(args);
  if (token == null) {
    _printAuthHelp();
    exit(1);
  }

  print('[Auth] Successfully authenticated with Google/Firebase OAuth2.\n');
  final cleaner = _DemoCleaner(token);
  await cleaner.run();
}

void _printAuthHelp() {
  print('''
[ERROR] Could not authenticate with Firebase.

Please use ANY of the following options:

Option 1 (Recommended): Place your Firebase service account JSON key at:
   $_serviceAccountPath
   (Firebase Console -> Project Settings -> Service Accounts -> Generate new private key)

Option 2: Pass an access token directly:
   dart run tool/clear_demo_data.dart --token=<ACCESS_TOKEN>

Option 3: Set an environment variable:
   \$env:FIREBASE_TOKEN="<ACCESS_TOKEN>"   # PowerShell
   export FIREBASE_TOKEN="<ACCESS_TOKEN>"  # Bash
''');
}

Future<String?> _resolveAccessToken(List<String> args) async {
  // 1. Command-line argument: --token=XXX or -t XXX
  for (int i = 0; i < args.length; i++) {
    if (args[i].startsWith('--token=')) {
      return args[i].substring('--token='.length).trim();
    }
    if (args[i] == '-t' && i + 1 < args.length) {
      return args[i + 1].trim();
    }
  }

  // 2. Environment variable
  final envToken = Platform.environment['FIREBASE_TOKEN'] ??
      Platform.environment['GOOGLE_OAUTH_TOKEN'];
  if (envToken != null && envToken.isNotEmpty) {
    return envToken.trim();
  }

  // 3. Pure Dart Service account authentication (zero external dependencies)
  final saFile = File(_serviceAccountPath);
  if (await saFile.exists()) {
    try {
      final jsonStr = await saFile.readAsString();
      final credentials = ServiceAccountCredentials.fromJson(jsonDecode(jsonStr));
      final authClient = await clientViaServiceAccount(
        credentials,
        const ['https://www.googleapis.com/auth/datastore'],
      );
      final token = authClient.credentials.accessToken.data;
      authClient.close();
      return token;
    } catch (e) {
      print('[Auth] Service account authentication error: $e');
    }
  }

  return null;
}

class _DemoCleaner {
  final String token;
  final HttpClient _client = HttpClient();

  _DemoCleaner(this.token);

  Future<void> run() async {
    final sw = Stopwatch()..start();
    print('Starting cleanup of demo data (isDemo == true)...\n');

    final collections = [
      'users',
      'posts',
      'conversations',
      'public_portfolios',
    ];

    int totalDeleted = 0;

    for (final col in collections) {
      stdout.write('Scanning $col... ');
      final docPaths = await _queryDemoDocs(col);
      print('found ${docPaths.length} demo records.');

      for (int i = 0; i < docPaths.length; i++) {
        final docPath = docPaths[i];
        await _deleteDoc(docPath);
        totalDeleted++;
        stdout.write('\r  -> Deleting $col: ${i + 1} / ${docPaths.length}');
      }
      if (docPaths.isNotEmpty) print('');
    }

    sw.stop();
    print('\n====================================================');
    print('   Cleanup Completed Successfully!                  ');
    print('   Total demo documents removed: $totalDeleted      ');
    print('   Time elapsed: ${sw.elapsed.inSeconds}s           ');
    print('====================================================\n');
  }

  Future<List<String>> _queryDemoDocs(String collection) async {
    final url = '$_firestoreBase:runQuery';
    final payload = {
      'structuredQuery': {
        'from': [{'collectionId': collection}],
        'where': {
          'fieldFilter': {
            'field': {'fieldPath': 'isDemo'},
            'op': 'EQUAL',
            'value': {'booleanValue': true},
          },
        },
        'limit': 2000,
      },
    };

    try {
      final res = await _post(url, payload);
      if (res is List) {
        final docPaths = <String>[];
        for (final item in res) {
          if (item is Map && item['document'] != null) {
            final name = item['document']['name'] as String?;
            if (name != null) {
              final idx = name.indexOf('/documents/');
              if (idx != -1) {
                docPaths.add(name.substring(idx + '/documents/'.length));
              }
            }
          }
        }
        return docPaths;
      }
    } catch (e) {
      print('  [Warning] Query $collection failed: $e');
    }
    return [];
  }

  Future<void> _deleteDoc(String docPath) async {
    final url = '$_firestoreBase/$docPath';
    try {
      final req = await _client.deleteUrl(Uri.parse(url));
      req.headers.set('Authorization', 'Bearer $token');
      final res = await req.close();
      await res.drain();
    } catch (_) {}
  }

  Future<dynamic> _post(String url, Map<String, dynamic> body) async {
    final req = await _client.postUrl(Uri.parse(url));
    req.headers.set('Authorization', 'Bearer $token');
    final bytes = utf8.encode(jsonEncode(body));
    req.headers.contentType = ContentType.json;
    req.headers.set(HttpHeaders.contentLengthHeader, bytes.length);
    req.add(bytes);
    final res = await req.close();
    final resBody = await utf8.decodeStream(res);
    return jsonDecode(resBody);
  }
}
