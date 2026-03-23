# 🎵 Rythmify - Your Ultimate Music Experience

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Riverpod](https://img.shields.io/badge/Riverpod-State%20Management-%233D6117.svg?style=for-the-badge&logo=flutter&logoColor=white)](https://riverpod.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Backend%20as%20a%20Service-%233ECF8E.svg?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
[![Clean Architecture](https://img.shields.io/badge/Architecture-Clean%20%26%20Modular-%23000.svg?style=for-the-badge)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

**Rythmify** is a high-performance, feature-rich music streaming application built with Flutter. It combines a sleek UI with powerful audio capabilities, social features, and a robust backend to provide an immersive musical journey.

---

## ✨ Core Features

### 🎧 Seamless Audio Experience
- **Advanced Player**: Full-featured player with play/pause, seek, skip, and background playback support powered by `just_audio` and `audio_service`.
- **High-Quality Streaming**: Optimized audio delivery for a crisp listening experience.
- **Track Details**: Rich metadata, album art, and artist information.

### 🌟 Social & Discovery
- **Music Feed**: Stay updated with the latest releases and community trends.
- **Messaging**: Built-in messaging system to share music and connect with friends.
- **Comments & Likes**: Engage with tracks and artists through community discussions.
- **Track Sharing**: Easily share your favorite music via social media (WhatsApp, etc.).

### 📂 Library & Personalization
- **Playlist Management**: Create, edit, and organize your custom playlists.
- **User Profiles**: Personalized profiles with your music history and preferences.
- **Search**: Fast and intuitive search for tracks, artists, and albums.
- **Track Upload**: Empowering creators to upload and share their own music.

### 🛡️ Secure & Scalable
- **Authentication**: Secure login using Google Sign-In, Apple Sign-In, and standard auth providers.
- **Real-time Sync**: Instant updates across devices using Supabase.
- **Offline Support**: Local caching and storage using Hive and Shared Preferences.

---

## 🛠️ Technology Stack

- **Frontend**: [Flutter](https://flutter.dev) (Dart)
- **State Management**: [Riverpod](https://riverpod.dev) (Modular & Reactive)
- **Backend**: [Supabase](https://supabase.com) (Auth, Database, Storage)
- **Routing**: [GoRouter](https://pub.dev/packages/go_router)
- **Audio Engine**: `just_audio` & `audio_service`
- **Database (Local)**: Hive & Shared Preferences
- **UI Components**: Material 3, Google Fonts, Shimmer effects, Lucide-style icons.

---

## 🏗️ Architecture

Rythmify follows a **Clean Architecture** approach, ensuring the codebase is scalable, maintainable, and testable. The project is organized by **features**:

```text
lib/
├── config/           # Application-wide configurations (Theme, Constants)
├── core/             # Shared logic, utilities, and common UI components
│   ├── data/         # Common data sources & repositories
│   ├── domain/       # Shared entities & use cases
│   ├── presentation/ # Shared widgets
│   ├── routing/      # Navigation logic (GoRouter)
│   └── services/     # Third-party service integrations
└── features/         # Feature-specific modules
    ├── authentication/
    ├── player/
    ├── track_upload/
    ├── track/
    ├── feed/
    ├── comments/
    ├── messaging/
    ├── notifications/
    ├── profile/
    ├── playlist/
    ├── library/
    ├── search/
    ├── settings/
    └── premium/
```

Each feature module is further divided into `data`, `domain`, and `presentation` layers to maintain strict separation of concerns.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.11.1+)
- [Dart SDK](https://dart.dev/get-started)
- [Docker](https://www.docker.com/) (Optional, for local mock backend)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/rythmify.git
   cd rythmify
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **(Optional) Run local mock API:**
   Rythmify uses a local `json-server` for development.
   ```bash
   docker-compose up -d
   ```

4. **Run the application:**
   ```bash
   flutter run
   ```

---

## 📸 Screenshots

| Onboarding | Home Feed | Music Player |
| :---: | :---: | :---: |
| ![Onboarding](https://via.placeholder.com/300x600?text=Onboarding) | ![Home](https://via.placeholder.com/300x600?text=Home+Feed) | ![Player](https://via.placeholder.com/300x600?text=Music+Player) |

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:
1. Fork the Project.
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`).
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the Branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<p align="center">Made with ❤️ for Music Lovers</p>
