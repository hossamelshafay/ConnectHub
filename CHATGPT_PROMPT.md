# 🚀 ConnectHub — Prompt for ChatGPT

> **How to use this file:** Copy the text below completely and paste it into ChatGPT (or Claude) to get high-quality recommendations for new features, UI/UX improvements, architectural optimizations, and growth ideas for ConnectHub.

---

### 📋 COPY FROM HERE BELOW:

```text
You are an expert Senior Flutter Engineer, Product Manager, and Mobile UI/UX Designer.
Below is a complete summary of my social media mobile application called **ConnectHub**.
Please read the details carefully and give me creative, practical, and technical recommendations to take this app to the next level.

==================================================
1. APP OVERVIEW
==================================================
- App Name: ConnectHub
- Description: A modern, real-time social media mobile application.
- Platform: Cross-Platform Mobile (iOS & Android) built with Flutter (Dart).
- Architecture: Feature-First Clean Architecture (Presentation, Data/Repo layers).
- State Management: Flutter BLoC / Cubit.
- Backend & Cloud Services: Firebase (Firebase Auth, Cloud Firestore NoSQL Database).
- Image Upload: ImageBB API (via Dio multipart HTTP requests).
- AI Integration: Integrated AI Assistant powered by n8n Webhook API (for post idea generation & chat).

==================================================
2. CURRENTLY IMPLEMENTED FEATURES
==================================================
1. Authentication & Onboarding:
   - Email & Password Sign Up, Login, Password Reset.
   - Session persistence on app launch.
   - Animated Splash Screen & smooth Auth Form transitions.

2. Feed & Post System:
   - Real-Time Feed stream ordered by creation timestamp.
   - Pull-to-Refresh support & custom shimmer loading skeletons.
   - Post Creation with title, description, and image attachment (Camera/Gallery picker + ImageBB upload).
   - Real-time Like/Unlike system with live counter updates and "Liked By" modal sheet.
   - Post Details View with a real-time comments subcollection stream & comment count.
   - Visual "Your Post" gradient indicator badge on posts created by the logged-in user.

3. User Profile & Follow System:
   - Own Profile Screen with live stats (Total Posts, Total Likes, Followers Count, Following Count).
   - User Profile Screen for viewing other users' profiles.
   - Atomic Real-Time Follow / Unfollow System:
     * Built with Firestore Transactions (`runTransaction`) for strict counter integrity.
     * Prevents race conditions, double-follows, and negative counters.
     * Optimistic loading lock (`isActionLoading`) on follow buttons to prevent spamming.
     * Real-time O(1) follow status checking.

4. AI Chatbot (Post Assistant):
   - In-app AI chatbot tab to brainstorm post ideas and content captions.
   - Real-time typing indicator and persistent chat bubble history.
   - Webhook connection to n8n AI engine.

5. UI / UX Design System:
   - Custom animated pill-style Bottom Navigation Bar.
   - Tab switching animations using AnimatedSwitcher.
   - Cohesive typography, custom color palette (`AppColors`), reusable custom buttons and input fields.

==================================================
3. TECHNICAL DEPENDENCIES & STACK
==================================================
- SDK: Flutter ^3.12.2
- State Management: flutter_bloc (^9.1.1)
- Backend: firebase_core (^3.13.0), firebase_auth (^5.7.0), cloud_firestore (^5.6.7)
- Network: dio (^5.8.0+1)
- Utilities & UI: image_picker, cached_network_image, intl, cupertino_icons

==================================================
4. WHAT I NEED FROM YOU (CHATGPT)
==================================================
Please give me a structured, prioritized response with actionable recommendations in the following 5 categories:

1. 🌟 New Core & Engagement Features:
   - What essential or innovative social media features should I add next? (e.g., Stories/Reels, Direct Messaging/Chat, Bookmarks, Hashtags, Polls, Search/Explore page, Notifications).
   - How can I rank or filter posts (e.g., Trending feed vs. Following-only feed)?

2. 🎨 UI/UX & Micro-Interactions:
   - Suggestions for polishing the design (Dark Mode / Custom Themes, Double-tap to like animation, Swipe-to-delete/reply gestures, skeleton improvements, full-screen media viewer).

3. ⚡ Technical & Architectural Optimizations:
   - Database optimizations (pagination/infinite scroll for posts, indexing, local offline caching with Hive/Isar).
   - Security improvements (Firestore rules enhancements, environment variables setup using flutter_dotenv).
   - Code structure / testing suggestions (Unit tests for Cubits, Integration tests).

4. 🤖 Advanced AI Features:
   - How can I leverage AI further inside ConnectHub? (e.g., AI auto-captioning from uploaded images, AI sentiment analysis on comments, automated content moderation/NSFW filter).

5. 🚀 Roadmap & Quick Wins:
   - Give me a phased roadmap: What to build in Phase 1 (Quick Wins), Phase 2 (Medium Effort), and Phase 3 (Advanced Features).

Please be specific, practical, and provide code or architectural hints where appropriate!
```
