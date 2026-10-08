# Beginner Home Fitness App: Module Breakdown (Members 01-04)

A beginner-friendly home workout and fitness tracking app. Personalization and planning are inspired by FitOn; the adaptive missed-workout plan is the team's own design solution.

---

# Member 01: Onboarding & Personalization

## 1. Responsibility

Member 01 owns the user's first contact with the app. Their job is to **understand who the user is and turn that into a personalized starting experience**. Every other module depends on this one, because it creates the user profile that drives recommendations, plans and progress targets.

In short: Member 01 collects the data, and the rest of the system uses it.

## 2. What each part does

**Screen 1: Welcome / Onboarding (FR01).** Introduces the app (logo, welcome message, short intro, beginner-friendly benefits) and has one action, `Get Started`. It collects no data. Its purpose is to set expectations and move the user into setup.

**Screen 2: Fitness Profile Setup (FR02).** The most important screen in this module. It collects five inputs:
- Fitness level
- Previous experience
- Fitness goal
- Available workout time
- Available equipment

These five values form the **user profile**, which is the core data object of the whole app.

**Screen 3: Personalized Home (FR03, FR04, FR18).** The main dashboard after onboarding. It shows:
- A personalized greeting
- Today's recommendation (recommended workout, duration, difficulty)
- Quick workout options
- A basic progress summary

This is the hub screen from which users enter the rest of the app.

**Screen 4: Workout Recommendation (FR03, FR04).** The matching logic. It compares the profile with the workout library and produces a result such as *Beginner Full Body, 20 minutes, No Equipment, Start Workout*. Screen 3 displays this result, and `Start Workout` hands the user off to Member 02.

## 3. How the parts connect internally

The four screens form a linear pipeline:

1. **Welcome** (intent to start)
2. **Profile Setup** (creates the profile)
3. **Recommendation logic** (reads the profile, selects a workout)
4. **Personalized Home** (displays the recommendation and summary)

Screen 4 is mostly a logic layer that surfaces its output on Screen 3. After the first run, returning users skip Screens 1 and 2 and land directly on Screen 3.

## 4. How Member 01 connects to the other members

| Connection | Direction | What flows |
|---|---|---|
| **Member 02** (Discovery & Experience) | Outbound | `Start Workout` and quick-workout taps open Workout Details (Screen 6). The profile's level, time and equipment can pre-filter Workout Search (Screen 5). |
| **Member 03** (Progress & Motivation) | Inbound | The progress summary on Home (FR18) reads workouts completed, active minutes and streak from Member 03's data. The fitness goal from the profile gives their Goals screen its starting target. |
| **Member 04** (Planning & Consistency) | Two-way | Member 01 supplies the initial profile and available time, which Member 04 uses to build the first weekly plan. Member 04's Profile & Preferences screen (16) edits the same profile, and the Adaptive Plan (14) can change what Home recommends. Home's "today's recommendation" should read from the plan when one exists. |

## 5. Main data flow

```
 NEW USER
    │
    ▼
[1 Welcome] ──Get Started──▶ [2 Profile Setup]
                                   │ creates
                                   ▼
                          ┌──────────────────┐
                          │   USER PROFILE   │◀──── edited by M4 (Screen 16)
                          │ level, experience│
                          │ goal, time,      │
                          │ equipment        │
                          └───┬──────┬───┬───┘
              reads           │      │   │ reads
        ┌─────────────────────┘      │   └──────────────────┐
        ▼                            ▼                      ▼
[4 Recommendation] ◀── Workout     [M4 builds         [M3 sets initial
   logic                library      first weekly        goal target]
   │                    (M2)        plan (FR05)]
   ▼
[3 Personalized Home] ◀──────── progress data (M3: workouts, minutes, streak)
   │            ▲
   │            └──────────── adapted workout (M4 Adaptive Plan)
   │
   ├── Start Workout ──▶ M2: Workout Details (6) ──▶ Active Workout (8)
   ├── Quick options ──▶ M2: Workout Search (5)
   └── Progress summary ──▶ M3: Progress Dashboard (11)
```

## 6. Key design point

Everyone depends on the **profile data structure**, so the five fields and their allowed values (for example, levels: Beginner / Intermediate; equipment: None / Dumbbells / Bands) should be agreed by all four members early. The same values need to be used as tags in the workout library for the recommendation logic to work.

---

# Member 02: Workout Discovery & Workout Experience

## Responsibility
Member 02 helps the user **find a suitable workout and perform it safely**. This module owns the workout library, the exercise content and the live workout session, so it is the core of what the app actually delivers.

## What each part does
- **Workout Search (5, FR03, FR04, FR06):** Search plus filters (category, difficulty, duration, equipment, workout type). It returns a list of matching workouts.
- **Workout Details (6, FR06-FR09):** A pre-start overview: title, duration, difficulty, intensity, equipment, exercise list, preview and safety information. It ends with `Start Workout`.
- **Exercise Guidance (7, FR07-FR09):** Per-exercise demonstration, step-by-step instructions, correct technique and safety notes, with Previous/Next controls. This is the main support for beginners.
- **Active Workout (8):** The live session: current exercise, timer, exercise progress, pause/resume, next exercise and overall workout progress.

## How the parts connect internally
Search → Details → Active Workout is the main path. Exercise Guidance can be opened from Details (to learn before starting) or from inside Active Workout (a "how do I do this?" help action) and returns the user to where they came from. Details and Active Workout share the same **workout object** (an ordered list of exercises with durations).

## How Member 02 connects to the others
| Module | Direction | What flows |
|---|---|---|
| **Member 01** | Inbound | The profile pre-filters Search; Home's `Start Workout` and quick options open Details directly. Member 02 also provides the workout library that Member 01's recommendation logic selects from. |
| **Member 03** | Outbound | When Active Workout ends, it sends a **session result** (workout ID, duration, completed or not, exercises done) to Workout Complete (9). |
| **Member 04** | Two-way | Plan screens and the Adaptive Plan open Workout Details for scheduled or adjusted workouts. Member 04's adaptive logic also needs workouts tagged by duration and level so it can pick a shorter alternative. |

## Data flow
```
Filters/search text ─▶ [5 Search] ─▶ workout list
                          │ select
                          ▼
                    [6 Details] ◀── workout library (exercises, safety info)
                     │        │
                     │        └─▶ [7 Guidance] (view technique, return)
                     ▼ Start
                    [8 Active Workout] ◀─▶ [7 Guidance] (help mid-session)
                     │ finish / quit
                     ▼
        session result ─▶ Member 03 (Workout Complete, History)
```

---

# Member 03: Progress & Motivation

## Responsibility
Member 03 helps the user **see what they have achieved and stay motivated**. This module owns the record of what the user has done and turns it into feedback, statistics and goals.

## What each part does
- **Workout Complete (9, FR13-FR15):** The post-workout screen: completion message, duration, active minutes, calories, goal progress and motivational feedback. It is also where the new session record is saved.
- **Workout History (10, FR13, FR14):** A list of past workouts with date, name, duration, type and completion status.
- **Progress Dashboard (11, FR13, FR14, FR18):** Aggregated view: completed workouts, active minutes, calories, weekly consistency, progress chart and current streak.
- **Goals & Challenges (12, FR15, FR17):** Weekly workout goal, progress toward it, streak, achievements and challenges.

## How the parts connect internally
Workout Complete **writes** a session record. History **lists** those records, the Dashboard **aggregates** them, and Goals & Challenges **compares** the aggregates with targets (weekly goal, streak, challenge conditions). A new record can therefore trigger an achievement or a goal update that is shown back on Workout Complete.

## How Member 03 connects to the others
| Module | Direction | What flows |
|---|---|---|
| **Member 01** | Two-way | Receives the user's fitness goal to set initial targets; sends a basic progress summary (workouts, minutes, streak) to Personalized Home (FR18). |
| **Member 02** | Inbound | Receives the session result when a workout ends (workout ID, type, duration, completion). |
| **Member 04** | Two-way | Sends completion and missed-workout data that the Adaptive Plan and My Plan use (completed workouts, streak, consistency). Receives the weekly workout frequency target so Goals match the plan. |

## Data flow
```
session result (from M2)
        ▼
[9 Workout Complete] ──saves──▶ WORKOUT LOG
                                  │
              ┌───────────────────┼────────────────────┐
              ▼                   ▼                    ▼
        [10 History]      [11 Dashboard]      [12 Goals & Challenges]
                                  │                    ▲
                                  │                    └── goal/frequency (M1, M4)
                                  ├─▶ summary ─▶ M1 Home
                                  └─▶ completion/consistency ─▶ M4 Plan & Adaptive Plan
```

---

# Member 04: Planning & Consistency

## Responsibility
Member 04 helps the user **organize workouts, stay consistent and adapt when life changes**. It turns recommendations into a schedule and responds when the user falls behind. The Adaptive Plan is the app's most distinctive feature.

## What each part does
- **My Plan / Fitness Program (13, FR05, FR10):** The structured weekly schedule: current program, today's workout, upcoming, completed and rest days, plus `Continue Plan`.
- **Adaptive Plan (14, FR10, FR12, FR15):** Detects missed workouts and replaces the plan with something more manageable (for example, a 15-minute beginner, no-equipment session) with a supportive message instead of a "restart".
- **Reminders & Schedule (15, FR16):** Workout days, time, reminder on/off and frequency, and scheduled workouts.
- **Profile & Preferences (16):** Edit goal, level, duration, preferred types, equipment, frequency and privacy settings.

## How the parts connect internally
Reminders & Schedule defines **when** the user trains, and My Plan defines **what** they do on those days. The Adaptive Plan watches My Plan against actual completion and rewrites upcoming entries. Profile & Preferences changes the inputs (time, level, equipment, frequency) that My Plan and the Adaptive Plan both use, so an edit there can regenerate the plan.

## How Member 04 connects to the others
| Module | Direction | What flows |
|---|---|---|
| **Member 01** | Two-way | Reads the initial profile to build the first plan; Profile & Preferences edits that same profile; Home's "today's recommendation" should follow the plan or adapted workout. |
| **Member 02** | Two-way | Picks workouts from the library by duration, level and equipment; opens Workout Details for scheduled or adapted sessions. |
| **Member 03** | Inbound mostly | Reads completion history, streak and consistency to detect misses and mark plan days complete; shares the weekly frequency so goals line up. |

## Data flow
```
PROFILE (M1) ──▶ [13 My Plan] ◀── [15 Schedule/Reminders]
                    ▲   │
 [16 Preferences] ──┘   └─ today's workout ─▶ M1 Home / M2 Details
                    ▲
 completion data (M3) ─▶ [14 Adaptive Plan] ─▶ updated shorter workout ─▶ M2 Details
                                   │
                                   └─▶ rewrites upcoming days in My Plan
```

---

# The Full System Loop

```
M1 Onboarding ──profile──▶ M4 Plan ──scheduled workout──▶ M2 Find & Perform
      ▲                       ▲                                  │
      │ summary               │ completion/misses                │ session result
      └────────── M3 Progress & Motivation ◀─────────────────────┘
```

1. **M1** creates the profile and first recommendation.
2. **M4** turns that into a weekly plan and reminders.
3. **M2** delivers the workout.
4. **M3** records it, updates stats and goals, and feeds results back to **M1** (Home summary) and **M4** (adaptive decisions).

## Shared Data the Team Must Agree On
- **User profile:** field names and allowed values (owned by M1, edited by M4).
- **Workout object:** ID, duration, level, equipment, type, exercises (owned by M2, used by M1, M3, M4).
- **Session record:** workout ID, date, duration, completion status (created by M2, stored by M3, read by M4).
- **Plan entry:** date, workout ID, status (owned by M4, read by M1 and M3).

Member 01 and Member 04 both touch the profile, so decide early that Member 01 owns the structure and Member 04 only edits it.
