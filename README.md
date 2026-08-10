# ConnectHub 🚀

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%26%20Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![State Management](https://img.shields.io/badge/State%20Management-BLoC%2FCubit-40C4FF?style=for-the-badge)](https://bloclibrary.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)

**ConnectHub** is a modern, feature-rich social media application built with **Flutter**, **Firebase**, and an integrated **AI Assistant**. Designed with clean architecture principles and BLoC state management, ConnectHub offers a seamless experience for connecting users, sharing posts, engaging through comments & likes, and conversing with an AI chatbot.

---

## ✨ Features

- 🔐 **User Authentication**
  - Secure Email & Password sign-up and log-in powered by Firebase Auth.
  - Persistent session management with auto-login on startup.

- 📰 **Interactive Newsfeed**
  - Real-time updates for user posts.
  - Interactive post cards showing author info, dynamic timestamps, and media attachments.
  - Instant post liking and real-time comment threads.

- 📝 **Post Creation & Media Sharing**
  - Create custom text posts.
  - Image picker integration for selecting and attaching photos from gallery or camera.

- 👤 **Personalized User Profiles**
  - View personal and other users' profiles.
  - Profile customization including bio, profile avatar, and user-specific post timelines.

- 🤖 **AI Assistant Chatbot**
  - Integrated AI Companion for interactive Q&A and user assistance.
  - Fast, responsive messaging interface connected via Dio to an n8n automated AI workflow endpoint.

- 🎨 **Modern & Sleek UI/UX**
  - Custom design system with consistent color palettes, clean typography, smooth transitions, and Material Design 3 guidelines.

---

## 🛠️ Architecture & Tech Stack

ConnectHub follows **Feature-First Clean Architecture** for maintainability, scalability, and high testability.

### **Tech Stack**
- **Framework:** [Flutter](https://flutter.dev) (Dart SDK `^3.12.2`)
- **Backend & Database:** [Firebase Authentication](https://firebase.google.com/products/auth), [Cloud Firestore](https://firebase.google.com/products/firestore)
- **State Management:** [Flutter BLoC / Cubit](https://pub.dev/packages/flutter_bloc)
- **Networking:** [Dio](https://pub.dev/packages/dio), [HTTP](https://pub.dev/packages/http)
- **Image Handling:** [Image Picker](https://pub.dev/packages/image_picker), [Cached Network Image](https://pub.dev/packages/cached_network_image)
- **AI Automation:** n8n Workflow Webhooks

---

## 📁 Project Structure

```text
lib/
├── core/
│   ├── errors/           # Custom error handlers and failures
│   ├── services/         # Services (e.g. AI Chat Dio service)
│   └── utils/            # App theme, assets, constants, & helpers
├── features/
│   ├── auth/             # Authentication feature (Login, Register, Cubits)
│   ├── chatbot/          # AI Chatbot feature (UI, Repos, Models, Cubits)
│   ├── home/             # Main feed feature (Posts listing, Feed Cubit)
│   ├── post/             # Post creation, comments & detail views
│   ├── profile/          # User profile view & edit features
│   └── splash/           # Splash screen & initial route checking
├── firebase_options.dart # Firebase platform options configuration
└── main.dart             # App entry point & MultiBlocProvider setup
```

---

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed on your development environment:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.x or higher)
- [Dart SDK](https://dart.dev/get-dart)
- Android Studio / VS Code with Flutter plugins
- iOS Simulator / Android Emulator or physical device

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/hossamelshafay/ConnectHub.git
   cd ConnectHub
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration:**
   Ensure Firebase is initialized for your platforms. If using your own project, configure it using the FlutterFire CLI:
   ```bash
   flutterfire configure
   ```

4. **Run the Application:**
   ```bash
   flutter run
   ```

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [Issues page](https://github.com/hossamelshafay/ConnectHub/issues).

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git checkout -b feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
