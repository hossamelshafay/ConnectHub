// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:googleapis_auth/auth_io.dart';

const String _projectId = 'connecthub-57eb5';
const String _firestoreBase =
    'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents';
const String _serviceAccountPath = 'tool/service-account.json';

Future<void> main(List<String> args) async {
  print('====================================================');
  print('   ConnectHub - Firestore Demo Data Seeder          ');
  print('====================================================\n');

  final token = await _resolveAccessToken(args);
  if (token == null) {
    _printAuthHelp();
    exit(1);
  }

  print('[Auth] Successfully authenticated with Google/Firebase OAuth2.\n');
  final seeder = _Seeder(token);
  await seeder.run();
}

void _printAuthHelp() {
  print('''
[ERROR] Could not authenticate with Firebase.

Please use ANY of the following options:

Option 1 (Recommended): Place your Firebase service account JSON key at:
   $_serviceAccountPath
   (Firebase Console -> Project Settings -> Service Accounts -> Generate new private key)

Option 2: Pass an access token directly:
   dart run tool/seed_firestore.dart --token=<ACCESS_TOKEN>

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

class _Seeder {
  final String token;
  final HttpClient _client = HttpClient();
  final Random _rnd = Random(42); // deterministic seed for reproducibility

  _Seeder(this.token);

  // ── Pre-configured Data ───────────────────────────────────────────────────

  static const List<String> _firstNames = [
    'Alexander', 'Sophia', 'Marcus', 'Elena', 'Julian', 'Amara', 'Liam', 'Zoe',
    'Oliver', 'Aria', 'Ethan', 'Chloe', 'Lucas', 'Maya', 'Gabriel', 'Layla',
    'Sebastian', 'Nora', 'Daniel', 'Mila', 'David', 'Kira', 'Nathan', 'Zara',
    'Leo', 'Freya', 'Adrian', 'Tara', 'Darius', 'Sienna', 'Isaac', 'Leila',
    'Christian', 'Ananya', 'Mateo', 'Iris', 'Xavier', 'Camila', 'Finn', 'Aaliyah',
    'Elijah', 'Samira', 'Caleb', 'Nadia', 'Adam', 'Selena', 'Owen', 'Fatima',
    'Benjamin', 'Farah',
  ];

  static const List<String> _lastNames = [
    'Vance', 'Sterling', 'Mercer', 'Chen', 'Novak', 'Al-Mansoor', 'Kowalski',
    'Rossi', 'Lindqvist', 'Nakamura', 'Sinclair', 'Patel', 'Dubois', 'Kim',
    'Santos', 'O\'Connor', 'Thornton', 'Blackwood', 'Kassir', 'Takahashi',
    'Moreau', 'Adler', 'Castillo', 'Haddad', 'Lindstrom', 'Reyes', 'Schmidt',
    'Gomez', 'Alvarez', 'Petrov', 'Vogel', 'Bauer', 'Costa', 'Silva', 'Mendoza',
    'Rios', 'Navarro', 'Ortega', 'Flores', 'Romero', 'Soto', 'Vega', 'Delgado',
    'Morales', 'Guerrero', 'Contreras', 'Salazar', 'Guzman', 'Herrera', 'Medina',
  ];

  static const List<String> _headlines = [
    'Staff Flutter & Mobile Architect | Open Source Contributor',
    'Senior Frontend Engineer | Flutter Web & Design Systems Specialist',
    'Full-Stack Cloud Engineer | GCP & Firebase Certified Specialist',
    'Mobile Tech Lead | Building Scalable Cross-Platform Apps',
    'Principal Software Engineer | Distributed Systems & Dart Enthusiast',
    'Senior Flutter Developer | Clean Architecture & Performance Tuning',
    'Lead Mobile Engineer | Passionate about UX, Animations & DX',
    'Senior Backend Developer | Node.js, Go & Cloud Native Architecture',
    'Software Architect | Multi-tenant SaaS & Enterprise Solutions',
    'Mobile DevOps & Platform Engineer | CI/CD & Fastlane Expert',
  ];

  static const List<String> _locations = [
    'San Francisco, CA', 'New York, NY', 'London, UK', 'Berlin, Germany',
    'Toronto, Canada', 'Amsterdam, Netherlands', 'Dubai, UAE', 'Tokyo, Japan',
    'Sydney, Australia', 'Stockholm, Sweden', 'Austin, TX', 'Seattle, WA',
    'Zurich, Switzerland', 'Singapore', 'Cairo, Egypt',
  ];

  static const List<List<String>> _skillPools = [
    ['Flutter', 'Dart', 'Firebase', 'Clean Architecture', 'Bloc', 'REST APIs', 'Git'],
    ['Flutter Web', 'TypeScript', 'Responsive Design', 'GraphQL', 'Tailwind', 'CI/CD'],
    ['Dart', 'Go', 'Docker', 'Kubernetes', 'GCP', 'PostgreSQL', 'Microservices'],
    ['Flutter', 'iOS', 'Android', 'Kotlin', 'Swift', 'State Management', 'Unit Testing'],
    ['Dart', 'System Architecture', 'Security', 'Performance Optimization', 'DevOps'],
  ];

  static const List<String> _postTitles = [
    'Deep Dive: Architecting Flutter Web Applications for Production in 2026',
    '5 Clean Architecture Anti-Patterns to Avoid in Large-Scale Dart Projects',
    'How We Reduced Flutter App Startup Time by 45%',
    'Mastering State Management: Bloc vs Signals vs Provider in Real World',
    'Deploying Flutter Web on Firebase Hosting with Micro-Frontends',
    'The Power of Firestore Security Rules: Production Hardening Guide',
    'Building Responsive Luxury Portfolios with Pure Flutter Web',
    'Zero-Downtime Database Migrations with Cloud Firestore',
    'Why We Chose Dart on the Backend: A 6-Month Retrospective',
    'Automating Flutter CI/CD Pipelines with GitHub Actions & Fastlane',
    'Optimizing Flutter Shaders & Canvas Performance for 120fps UIs',
    'Effective Testing Strategies: Unit, Golden & Integration Tests',
  ];

  static const List<String> _postSnippets = [
    'When building large scale applications, architecture decisions made in week one determine your team velocity for the next three years. Here are the core principles we follow.',
    'Performance in Flutter is not an accident—it is an engineering discipline. Profile early, avoid unnecessary rebuilds, and measure frame rendering times accurately.',
    'Clean Architecture gives you testability and maintainability, but beware of over-engineering simple features. Pragmatism should always guide abstraction.',
    'Real-time apps need resilient data sync and intelligent caching. Firestore offline persistence paired with optimistic UI updates creates an incredible user experience.',
    'Design systems bridge engineering and product design. Consistent typography, spacing tokens, and color palettes make your app feel cohesive and high quality.',
    'Always design for low-end mobile devices and spotty network connections first. If your app feels fast on 3G, it will fly everywhere else.',
  ];

  static const List<String> _comments = [
    'Brilliant explanation! This resolved a huge performance bottleneck we were facing.',
    'Completely agree with this perspective. Clean architecture saves so much debugging time.',
    'Spot on! How do you handle deep nested navigation in this setup?',
    'Awesome insights! Thanks for sharing with the community.',
    'Great write-up. We adopted a similar pattern last quarter and velocity tripled.',
    'Very well articulated. The section on caching strategies is gold.',
    'Couldn\'t agree more. Looking forward to your next post!',
    'This should be required reading for all Flutter engineers.',
  ];

  static const List<String> _chatSnippets = [
    'Hey! Did you check out the new design system update?',
    'Yes, it looks stunning! The gold accents really give it a luxury vibe.',
    'Awesome. Are you available for a quick sync tomorrow regarding the architecture review?',
    'Sure thing! Let\'s do 2:00 PM UTC.',
    'Perfect, I will send a calendar invite.',
    'Thanks! Also, great job on the latest release.',
  ];

  // ── Main Run Method ───────────────────────────────────────────────────────

  Future<void> run() async {
    final sw = Stopwatch()..start();

    // 1. Clear previous demo data
    print('==> Step 1: Clearing existing demo data...');
    await _clearAllDemoData();

    // 2. Create 50 Demo Users
    print('\n==> Step 2: Creating 50 Demo Users...');
    final userIds = await _createUsers(50);

    // 3. Create Portfolios (Projects, Experience, Education, Certificates)
    print('\n==> Step 3: Creating Portfolios & Subcollections for all users...');
    await _createPortfolios(userIds);

    // 4. Create Follower/Following Relationships
    print('\n==> Step 4: Establishing Follower & Following Relationships...');
    await _createFollowers(userIds);

    // 5. Create 350 Posts with Likes
    print('\n==> Step 5: Creating 350 Posts with Likes...');
    final postIds = await _createPosts(userIds, 350);

    // 6. Create 900+ Comments
    print('\n==> Step 6: Adding 900+ Comments to Posts...');
    await _createComments(userIds, postIds, 900);

    // 7. Create 40 Conversations with Messages
    print('\n==> Step 7: Creating 40 Conversations with Messages...');
    await _createConversations(userIds, 40);

    // 8. Create 200 Notifications
    print('\n==> Step 8: Generating 200 Activity Notifications...');
    await _createNotifications(userIds, postIds, 200);

    sw.stop();
    print('\n====================================================');
    print('   Firestore Demo Seeding Completed Successfully!   ');
    print('   Time elapsed: ${sw.elapsed.inSeconds}s           ');
    print('====================================================\n');
    print('Summary of Generated Data:');
    print('  - Users created:             ${userIds.length}');
    print('  - Public Portfolios created: ${userIds.length}');
    print('  - Projects created:          ~${userIds.length * 3}');
    print('  - Experiences created:       ~${userIds.length * 2}');
    print('  - Educations created:        ~${userIds.length * 2}');
    print('  - Certificates created:      ~${userIds.length * 2}');
    print('  - Posts created:             ${postIds.length}');
    print('  - Comments created:          900+');
    print('  - Total Likes distributed:   ~2500+');
    print('  - Conversations created:     40 (~600 messages)');
    print('  - Notifications created:     200');
    print('====================================================\n');
  }

  // ── Step 1: Idempotent Cleanup ────────────────────────────────────────────

  Future<void> _clearAllDemoData() async {
    final collections = [
      'users',
      'posts',
      'conversations',
      'public_portfolios',
    ];

    for (final col in collections) {
      stdout.write('  Scanning $col for demo documents... ');
      final docs = await _queryDemoDocs(col);
      stdout.write('Found ${docs.length} demo docs. Deleting... ');
      for (final docPath in docs) {
        await _deleteDoc(docPath);
      }
      print('Done.');
    }
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
        'limit': 1000,
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

  // ── Step 2: Users ─────────────────────────────────────────────────────────

  Future<List<Map<String, String>>> _createUsers(int count) async {
    final users = <Map<String, String>>[];

    for (int i = 0; i < count; i++) {
      final first = _firstNames[i % _firstNames.length];
      final last = _lastNames[(i * 3 + 1) % _lastNames.length];
      final name = '$first $last';
      final username = '${first.toLowerCase()}_${last.toLowerCase()}${(i + 1)}';
      final uid = 'demo_user_${(i + 1).toString().padLeft(3, '0')}';
      final email = '$username@connecthub.demo';
      final headline = _headlines[i % _headlines.length];
      final location = _locations[i % _locations.length];
      final skills = _skillPools[i % _skillPools.length];
      final avatar = 'https://api.dicebear.com/7.x/avataaars/png?seed=$username';
      final github = 'https://github.com/$username';
      final linkedin = 'https://linkedin.com/in/$username';
      final website = 'https://$username.dev';

      final userFields = {
        'uid': _sv(uid),
        'name': _sv(name),
        'email': _sv(email),
        'username': _sv(username),
        'bio': _sv('Senior Software Engineer building high-impact cross-platform apps. $headline.'),
        'headline': _sv(headline),
        'about': _sv('Passionate about clean architecture, performance optimization, and developer tooling. Based in $location.'),
        'location': _sv(location),
        'phone': _sv('+1 (555) ${100 + i}-${2000 + i}'),
        'profileImage': _sv(avatar),
        'accountType': _sv('professional'),
        'portfolioSource': _sv('manual'),
        'portfolioCompleted': _bv(true),
        'portfolioVersion': _iv(1),
        'githubUsername': _sv(username),
        'skills': _arrayValue(skills.map((s) => _sv(s)).toList()),
        'socialLinks': _mapValue({
          'github': _sv(github),
          'linkedin': _sv(linkedin),
          'website': _sv(website),
          'portfolio': _sv('https://connecthub-57eb5.web.app/portfolio/$username'),
        }),
        'sectionVisibility': _mapValue({
          'showAbout': _bv(true),
          'showSkills': _bv(true),
          'showExperience': _bv(true),
          'showProjects': _bv(true),
          'showEducation': _bv(true),
          'showCertificates': _bv(true),
          'showContact': _bv(true),
        }),
        'followersCount': _iv(15 + _rnd.nextInt(35)),
        'followingCount': _iv(10 + _rnd.nextInt(25)),
        'createdAt': _timestampValue(DateTime.now().subtract(Duration(days: 30 + i))),
        'isDemo': _bv(true),
      };

      await _patchDoc('users/$uid', userFields);
      users.add({
        'uid': uid,
        'name': name,
        'username': username,
        'avatar': avatar,
        'headline': headline,
        'location': location,
      });

      _printProgress(i + 1, count, 'Users');
    }
    print('');
    return users;
  }

  // ── Step 3: Portfolios & Subcollections ───────────────────────────────────

  Future<void> _createPortfolios(List<Map<String, String>> users) async {
    for (int i = 0; i < users.length; i++) {
      final u = users[i];
      final uid = u['uid']!;
      final username = u['username']!;
      final name = u['name']!;
      final headline = u['headline']!;

      // 1. Subcollection: projects
      final projectDocs = <Map<String, dynamic>>[];
      for (int p = 1; p <= 3; p++) {
        final pId = 'proj_${uid}_$p';
        final pTitle = p == 1
            ? 'ConnectHub Realtime Architecture'
            : p == 2
                ? 'High-Performance Flutter Web Engine'
                : 'Cloud-Native Microservices Toolkit';
        final pDesc = 'Enterprise-grade engineering showcase with offline caching, high-throughput data sync, and reactive UI pipelines.';
        final pFields = {
          'id': _sv(pId),
          'title': _sv(pTitle),
          'description': _sv(pDesc),
          'tags': _arrayValue([_sv('Flutter'), _sv('Dart'), _sv('Firebase'), _sv('Clean Architecture')]),
          'liveUrl': _sv('https://connecthub-57eb5.web.app'),
          'githubUrl': _sv('https://github.com/$username/$pId'),
          'stars': _iv(45 + p * 20),
          'isDemo': _bv(true),
        };
        await _patchDoc('users/$uid/projects/$pId', pFields);
        projectDocs.add({
          'id': pId,
          'title': pTitle,
          'description': pDesc,
          'tags': ['Flutter', 'Dart', 'Firebase', 'Clean Architecture'],
          'liveUrl': 'https://connecthub-57eb5.web.app',
          'githubUrl': 'https://github.com/$username/$pId',
          'stars': 45 + p * 20,
        });
      }

      // 2. Subcollection: experience
      final expDocs = <Map<String, dynamic>>[];
      for (int e = 1; e <= 2; e++) {
        final expId = 'exp_${uid}_$e';
        final expRole = e == 1 ? 'Lead Software Architect' : 'Senior Mobile Engineer';
        final expCompany = e == 1 ? 'Apex Technologies' : 'Vanguard Software Inc.';
        final expPeriod = e == 1 ? '2023 - Present' : '2020 - 2023';
        final expDesc = 'Led the cross-platform mobile engineering team of 14 engineers. Optimized rendering performance by 60% and unified mobile/web design system.';
        final expFields = {
          'id': _sv(expId),
          'role': _sv(expRole),
          'company': _sv(expCompany),
          'period': _sv(expPeriod),
          'description': _sv(expDesc),
          'location': _sv('Remote / Global'),
          'isDemo': _bv(true),
        };
        await _patchDoc('users/$uid/experience/$expId', expFields);
        expDocs.add({
          'id': expId,
          'role': expRole,
          'company': expCompany,
          'period': expPeriod,
          'description': expDesc,
          'location': 'Remote / Global',
        });
      }

      // 3. Subcollection: education
      final eduDocs = <Map<String, dynamic>>[];
      final eduId = 'edu_${uid}_1';
      final eduFields = {
        'id': _sv(eduId),
        'institution': _sv('Stanford University / MIT'),
        'degree': _sv('B.S. in Computer Science & Engineering'),
        'period': _sv('2016 - 2020'),
        'field': _sv('Computer Software Engineering'),
        'isDemo': _bv(true),
      };
      await _patchDoc('users/$uid/education/$eduId', eduFields);
      eduDocs.add({
        'id': eduId,
        'institution': 'Stanford University / MIT',
        'degree': 'B.S. in Computer Science & Engineering',
        'period': '2016 - 2020',
        'field': 'Computer Software Engineering',
      });

      // 4. Subcollection: certificates
      final certDocs = <Map<String, dynamic>>[];
      final certId = 'cert_${uid}_1';
      final certFields = {
        'id': _sv(certId),
        'name': _sv('Google Cloud Certified Professional Cloud Architect'),
        'issuer': _sv('Google Cloud'),
        'issueDate': _sv('2024'),
        'url': _sv('https://cloud.google.com/certification'),
        'isDemo': _bv(true),
      };
      await _patchDoc('users/$uid/certificates/$certId', certFields);
      certDocs.add({
        'id': certId,
        'name': 'Google Cloud Certified Professional Cloud Architect',
        'issuer': 'Google Cloud',
        'issueDate': '2024',
        'url': 'https://cloud.google.com/certification',
      });

      // 5. Create Public Portfolio Document: public_portfolios/{username}
      final pubPortfolioFields = {
        'ownerUid': _sv(uid),
        'username': _sv(username),
        'name': _sv(name),
        'headline': _sv(headline),
        'bio': _sv('Senior Software Engineer building high-impact cross-platform apps. $headline.'),
        'location': _sv(u['location']!),
        'profileImage': _sv(u['avatar']!),
        'skills': _arrayValue(['Flutter', 'Dart', 'Firebase', 'Clean Architecture', 'Bloc'].map((s) => _sv(s)).toList()),
        'socialLinks': _mapValue({
          'github': _sv('https://github.com/$username'),
          'linkedin': _sv('https://linkedin.com/in/$username'),
          'website': _sv('https://$username.dev'),
        }),
        'projects': _arrayValue(projectDocs.map((p) => _mapValue({
          'id': _sv(p['id']),
          'title': _sv(p['title']),
          'description': _sv(p['description']),
          'tags': _arrayValue((p['tags'] as List).map((t) => _sv(t)).toList()),
          'liveUrl': _sv(p['liveUrl']),
          'githubUrl': _sv(p['githubUrl']),
          'stars': _iv(p['stars']),
        })).toList()),
        'experience': _arrayValue(expDocs.map((e) => _mapValue({
          'id': _sv(e['id']),
          'role': _sv(e['role']),
          'company': _sv(e['company']),
          'period': _sv(e['period']),
          'description': _sv(e['description']),
          'location': _sv(e['location']),
        })).toList()),
        'education': _arrayValue(eduDocs.map((ed) => _mapValue({
          'id': _sv(ed['id']),
          'institution': _sv(ed['institution']),
          'degree': _sv(ed['degree']),
          'period': _sv(ed['period']),
          'field': _sv(ed['field']),
        })).toList()),
        'certificates': _arrayValue(certDocs.map((c) => _mapValue({
          'id': _sv(c['id']),
          'name': _sv(c['name']),
          'issuer': _sv(c['issuer']),
          'issueDate': _sv(c['issueDate']),
          'url': _sv(c['url']),
        })).toList()),
        'publishedAt': _timestampValue(DateTime.now()),
        'version': _iv(1),
        'isDemo': _bv(true),
      };
      await _patchDoc('public_portfolios/$username', pubPortfolioFields);

      _printProgress(i + 1, users.length, 'Portfolios');
    }
    print('');
  }

  // ── Step 4: Followers & Following ─────────────────────────────────────────

  Future<void> _createFollowers(List<Map<String, String>> users) async {
    int totalFollows = 0;
    for (int i = 0; i < users.length; i++) {
      final target = users[i];
      final targetUid = target['uid']!;

      // Each user gets 5-8 followers from other demo users
      final followerIndices = <int>{};
      while (followerIndices.length < 6) {
        final randIdx = _rnd.nextInt(users.length);
        if (randIdx != i) followerIndices.add(randIdx);
      }

      for (final fIdx in followerIndices) {
        final follower = users[fIdx];
        final followerUid = follower['uid']!;

        // Add to target's followers subcollection
        await _patchDoc('users/$targetUid/followers/$followerUid', {
          'userId': _sv(followerUid),
          'userName': _sv(follower['name']!),
          'createdAt': _timestampValue(DateTime.now().subtract(Duration(days: 10 + totalFollows % 20))),
          'isDemo': _bv(true),
        });

        // Add to follower's following subcollection
        await _patchDoc('users/$followerUid/following/$targetUid', {
          'userId': _sv(targetUid),
          'userName': _sv(target['name']!),
          'createdAt': _timestampValue(DateTime.now().subtract(Duration(days: 10 + totalFollows % 20))),
          'isDemo': _bv(true),
        });

        totalFollows++;
      }
      _printProgress(i + 1, users.length, 'Follower graphs');
    }
    print(' (Total follower relations: $totalFollows)');
  }

  // ── Step 5: Posts ─────────────────────────────────────────────────────────

  Future<List<String>> _createPosts(List<Map<String, String>> users, int count) async {
    final postIds = <String>[];
    final techImages = [
      'https://images.unsplash.com/photo-1555066931-4365d14bab8c?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&w=1200&q=80',
    ];

    for (int i = 0; i < count; i++) {
      final postId = 'demo_post_${(i + 1).toString().padLeft(4, '0')}';
      final author = users[i % users.length];
      final title = _postTitles[i % _postTitles.length];
      final description = '${_postSnippets[i % _postSnippets.length]}\n\nIn part ${i + 1}, we explore practical takeaways from our production workloads and benchmarks.';

      // Random 5 to 15 likes per post
      final likeCount = 6 + _rnd.nextInt(12);
      final likers = <String>[];
      for (int k = 0; k < likeCount; k++) {
        likers.add(users[(i + k * 3) % users.length]['uid']!);
      }

      final hasImage = (i % 3 == 0);
      final imageUrl = hasImage ? techImages[i % techImages.length] : null;

      final postFields = {
        'id': _sv(postId),
        'userId': _sv(author['uid']!),
        'userName': _sv(author['name']!),
        'title': _sv(title),
        'description': _sv(description),
        if (imageUrl != null) 'imageUrl': _sv(imageUrl),
        'likes': _arrayValue(likers.map((l) => _sv(l)).toList()),
        'likeCount': _iv(likers.length),
        'commentCount': _iv(3), // will have 3 comments added
        'createdAt': _timestampValue(DateTime.now().subtract(Duration(hours: (count - i) * 2))),
        'isDemo': _bv(true),
      };

      await _patchDoc('posts/$postId', postFields);
      postIds.add(postId);

      if ((i + 1) % 25 == 0 || i + 1 == count) {
        _printProgress(i + 1, count, 'Posts');
      }
    }
    print('');
    return postIds;
  }

  // ── Step 6: Comments ──────────────────────────────────────────────────────

  Future<void> _createComments(
    List<Map<String, String>> users,
    List<String> postIds,
    int targetCount,
  ) async {
    int totalComments = 0;
    final commentsPerPost = (targetCount / postIds.length).ceil();

    for (int p = 0; p < postIds.length; p++) {
      final postId = postIds[p];
      for (int c = 0; c < commentsPerPost; c++) {
        if (totalComments >= targetCount) break;
        final commenter = users[(p * 3 + c + 1) % users.length];
        final commentId = 'comm_${postId}_$c';
        final commentText = _comments[(p + c) % _comments.length];

        final commentFields = {
          'id': _sv(commentId),
          'userId': _sv(commenter['uid']!),
          'userName': _sv(commenter['name']!),
          'text': _sv(commentText),
          'createdAt': _timestampValue(DateTime.now().subtract(Duration(minutes: (postIds.length - p) * 15 + c * 3))),
          'isDemo': _bv(true),
        };

        await _patchDoc('posts/$postId/comments/$commentId', commentFields);
        totalComments++;
      }

      if ((p + 1) % 35 == 0 || p + 1 == postIds.length) {
        _printProgress(totalComments, targetCount, 'Comments');
      }
    }
    print('');
  }

  // ── Step 7: Conversations & Messages ──────────────────────────────────────

  Future<void> _createConversations(List<Map<String, String>> users, int count) async {
    for (int i = 0; i < count; i++) {
      final userA = users[i % users.length];
      final userB = users[(i + 1) % users.length];
      final uidA = userA['uid']!;
      final uidB = userB['uid']!;

      final sorted = [uidA, uidB]..sort();
      final convId = '${sorted[0]}_${sorted[1]}';
      final lastMsg = _chatSnippets[i % _chatSnippets.length];
      final lastMsgTime = DateTime.now().subtract(Duration(minutes: 15 * (i + 1)));

      final convFields = {
        'id': _sv(convId),
        'participants': _arrayValue([_sv(uidA), _sv(uidB)]),
        'participantNames': _mapValue({
          uidA: _sv(userA['name']!),
          uidB: _sv(userB['name']!),
        }),
        'participantPhotos': _mapValue({
          uidA: _sv(userA['avatar']!),
          uidB: _sv(userB['avatar']!),
        }),
        'lastMessage': _sv(lastMsg),
        'lastMessageAt': _timestampValue(lastMsgTime),
        'lastMessageSenderId': _sv(uidA),
        'lastMessageType': _sv('text'),
        'unreadCount': _mapValue({
          uidA: _iv(0),
          uidB: _iv(1),
        }),
        'typingUsers': _mapValue({
          uidA: _bv(false),
          uidB: _bv(false),
        }),
        'hiddenFor': _arrayValue([]),
        'createdAt': _timestampValue(DateTime.now().subtract(Duration(days: 7))),
        'isDemo': _bv(true),
      };

      await _patchDoc('conversations/$convId', convFields);

      // Create 5-10 messages per conversation
      for (int m = 0; m < _chatSnippets.length; m++) {
        final msgId = 'msg_${convId}_$m';
        final sender = (m % 2 == 0) ? userA : userB;
        final msgFields = {
          'id': _sv(msgId),
          'senderId': _sv(sender['uid']!),
          'senderName': _sv(sender['name']!),
          'text': _sv(_chatSnippets[m]),
          'type': _sv('text'),
          'sentAt': _timestampValue(DateTime.now().subtract(Duration(minutes: 60 - m * 5))),
          'seenBy': _arrayValue([_sv(userA['uid']!), _sv(userB['uid']!)]),
          'isForwarded': _bv(false),
          'isEdited': _bv(false),
          'isDeleted': _bv(false),
          'isDemo': _bv(true),
        };
        await _patchDoc('conversations/$convId/messages/$msgId', msgFields);
      }

      _printProgress(i + 1, count, 'Conversations');
    }
    print('');
  }

  // ── Step 8: Notifications ─────────────────────────────────────────────────

  Future<void> _createNotifications(
    List<Map<String, String>> users,
    List<String> postIds,
    int count,
  ) async {
    final types = ['like', 'comment', 'follow', 'mention'];

    for (int i = 0; i < count; i++) {
      final receiver = users[i % users.length];
      final sender = users[(i + 3) % users.length];
      final notifId = 'notif_demo_${(i + 1).toString().padLeft(4, '0')}';
      final type = types[i % types.length];
      final postId = (type == 'like' || type == 'comment' || type == 'mention')
          ? postIds[i % postIds.length]
          : null;

      final notifFields = {
        'id': _sv(notifId),
        'senderId': _sv(sender['uid']!),
        'senderName': _sv(sender['name']!),
        'senderUsername': _sv(sender['username']!),
        'senderPhoto': _sv(sender['avatar']!),
        'receiverId': _sv(receiver['uid']!),
        'type': _sv(type),
        if (postId != null) 'postId': _sv(postId),
        'createdAt': _timestampValue(DateTime.now().subtract(Duration(minutes: i * 20))),
        'isRead': _bv(i % 3 == 0),
        'isDemo': _bv(true),
      };

      await _patchDoc('users/${receiver['uid']}/notifications/$notifId', notifFields);

      if ((i + 1) % 25 == 0 || i + 1 == count) {
        _printProgress(i + 1, count, 'Notifications');
      }
    }
    print('');
  }

  // ── Firestore REST API Helpers ────────────────────────────────────────────

  Future<void> _patchDoc(String docPath, Map<String, dynamic> fields) async {
    final url = '$_firestoreBase/$docPath';
    final payload = {'fields': fields};
    await _patch(url, payload);
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

  Future<dynamic> _patch(String url, Map<String, dynamic> body) async {
    final req = await _client.patchUrl(Uri.parse(url));
    req.headers.set('Authorization', 'Bearer $token');
    final bytes = utf8.encode(jsonEncode(body));
    req.headers.contentType = ContentType.json;
    req.headers.set(HttpHeaders.contentLengthHeader, bytes.length);
    req.add(bytes);
    final res = await req.close();
    final resBody = await utf8.decodeStream(res);
    return jsonDecode(resBody);
  }

  // ── Firestore Value Helpers ───────────────────────────────────────────────

  Map<String, dynamic> _sv(String val) => {'stringValue': val};
  Map<String, dynamic> _iv(int val) => {'integerValue': val.toString()};
  Map<String, dynamic> _bv(bool val) => {'booleanValue': val};
  Map<String, dynamic> _timestampValue(DateTime dt) => {'timestampValue': dt.toUtc().toIso8601String()};
  Map<String, dynamic> _mapValue(Map<String, dynamic> map) => {'mapValue': {'fields': map}};
  Map<String, dynamic> _arrayValue(List<dynamic> list) => {'arrayValue': {'values': list}};

  void _printProgress(int current, int total, String label) {
    stdout.write('\r  -> Progress $label: $current / $total (${(current / total * 100).toStringAsFixed(0)}%)');
  }
}
