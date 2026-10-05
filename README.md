# FitOn - Modern Fitness Mobile Application

A clean, modern fitness mobile application built with **Flutter**, **Material 3**, and **Firebase**, designed to deliver simple, beginner-friendly home workouts.

---

## 📱 Implemented Development Phase: Onboarding & Splash

As requested for this phase, only the primary onboarding and entry flow is implemented, converted faithfully from the provided wireframes:

1. **Intro / Splash Screen (`SplashScreen`)**
   - Soft glowing background with brand radial aura
   - FitOn logo badge (warm orange squircle with stylized "F." brandmark and teal accent)
   - "FitOn" brand title
   - Headline: *"Your fitness journey starts here."*
   - Subtitle: *"Simple home workouts made for you."*
   - Bottom CTA: Full-width dark teal pill button **"Next →"** with smooth route transition

2. **Welcome Onboarding Screen (`WelcomeOnboardingScreen`)**
   - Brand header with FitOn logo and **"● Newbie Friendly"** pill badge
   - Warm sunlit living room hero preview card with a floating community proof pill:
     - Multi-avatar stack (`JD`, `MK`, `SL`)
     - *"12,000+ beginners started this week"*
     - Teal favorite heart icon
   - Main headline: *"Start Your Fitness Journey"*
   - Subtitle: *"Simple home workouts designed for beginners."*
   - Three feature highlight cards with tinted icon containers:
     - 🎛️ **Personalized workouts** - *Matched to your goals, pace, and time.*
     - 🧘 **Beginner-friendly exercises** - *Simple routines made for beginners.*
     - 📅 **Simple fitness planning** - *Build a realistic weekly workout plan.*
   - Bottom CTA: Full-width dark teal pill button **"Get Started →"**
   - Quick setup footer: ⏱️ *"Set up your fitness profile in less than a minute."*

---

## 🏗️ Architecture & Project Structure

The project is structured following **Clean Architecture (Feature-First)** for maximum modularity and seamless scalability in future phases:

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart        # Direct color mappings from wireframes
│   │   ├── app_strings.dart       # All UI copy centralized
│   │   ├── app_typography.dart    # Standard text styles
│   │   └── asset_paths.dart       # Asset paths
│   ├── routes/
│   │   └── app_routes.dart        # Route declarations & custom page transitions
│   ├── services/
│   │   └── firebase_service.dart  # Firebase initialization abstraction
│   ├── theme/
│   │   └── app_theme.dart         # Material 3 ThemeData & color schemes
│   └── widgets/
│       ├── fiton_logo.dart        # FitOn logo badge & brand header
│       └── primary_pill_button.dart # Reusable dark teal pill button
├── features/
│   ├── splash/
│   │   └── presentation/screens/splash_screen.dart
│   ├── onboarding/
│   │   └── presentation/
│   │       ├── screens/welcome_onboarding_screen.dart
│   │       └── widgets/
│   │           ├── hero_preview_card.dart
│   │           ├── onboarding_feature_card.dart
│   │           └── onboarding_header.dart
│   ├── auth/                      # Ready for Firebase Auth
│   ├── workouts/                  # Ready for Cloud Firestore workouts
│   └── profile/                   # Ready for Firebase Storage & user stats
├── app.dart                       # Root MaterialApp configuration
└── main.dart                      # System Chrome & app initialization
```

---

## 🎨 Design System & Color Tokens

| Token | Hex | Usage |
|---|---|---|
| `primaryTeal` | `#006257` | Main action buttons, heart icon, active indicators |
| `logoOrange` | `#FF4820` | Brand logo badge background |
| `background` | `#F8FAFB` | App background |
| `cardBackground` | `#FFFFFF` | Feature cards and surface panels |
| `textPrimary` | `#0F172A` | Headlines and titles |
| `textSecondary` | `#64748B` | Subtitles and descriptive text |
| `badgeBgBlue` | `#E3EDFE` | "Newbie Friendly" badge container |
| `onlineGreen` | `#10B981` | "Newbie Friendly" indicator dot |
| `featureTealBg` | `#C8F3EA` | Workouts icon container |
| `featureGreenBg`| `#86EFAC` | Exercises icon container |
| `featurePeachBg`| `#F5E4DA` | Planning icon container |

---

## 🚀 Running the Project

Ensure you have Flutter installed:

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run the application (Android, iOS, or Web)
flutter run
```