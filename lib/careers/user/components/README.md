# Careers Profile Components

Reusable widgets for the candidate (careers) profile pages. All components
are data-driven: they receive API models via constructor parameters and never
read services or Hive directly.

## Components

- **`profile_header_card.dart` — `ProfileHeaderCard`**: avatar, name, email
  and an API-driven completion badge (`isComplete` / `completionPercentage`).
- **`profile_info_card.dart` — `ProfileInfoCard`**: read-only personal
  information rendered from a `ProfileModel`.
- **`profile_completion_button.dart` — `ProfileCompletionButton`**: completion
  banner driven by `ProfileCompletionModel`, with a "Complete Profile" call to
  action when incomplete.
- **`logout_dialog.dart` — `LogoutDialog`**: logout confirmation dialog;
  dispatches `LogoutEvent` to `UserBloc`. Use `LogoutDialog.show(context)`.
- **`shared/profile_card.dart` — `ProfileCard`**: themed card container used
  by the profile components.

All exports are available through `index.dart`.

## Data flow

```
CareersProfilePage / CompleteProfilePage
        │  (BlocProvider<CareersProfileBloc> at route level)
        ▼
CareersProfileBloc ──► CareersProfileRepository ──► ProfileApiService ──► ApiService (Dio)
        │
        ▼
ProfileHeaderCard / ProfileInfoCard / ProfileCompletionButton (constructor props)
```

Styling uses the design tokens in `lib/config/themes/app_design_tokens.dart`
(`AppSpacing`, `AppRadius`, `AppSizes`, `AppColors`) — no hardcoded colors or
screen-relative sizing.
