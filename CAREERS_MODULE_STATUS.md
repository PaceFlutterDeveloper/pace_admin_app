# Careers Module — Complete Status

This document describes the **current state** of the Pace Careers module in the Flutter app: what works, what is partially built, what is missing, and what is misconfigured. It complements [`MISSING_API_INTEGRATIONS.md`](MISSING_API_INTEGRATIONS.md) (API gap list) and [`PROFILE_API_IMPLEMENTATION.md`](PROFILE_API_IMPLEMENTATION.md) (profile service details).

**Last reviewed:** June 2026  
**Base URL (public careers):** `https://paceeducation.com/careers/erp-api/`

---

## 1. Module overview

The careers module lets **candidates** browse Pace Group jobs and (when fully wired) register, complete a profile, and apply. Staff reach it from the admin login screen via **Explore Careers** (`/careers`).

### Main areas

| Area | Primary paths | Role |
|------|----------------|------|
| Jobs listing | `lib/UI/public/jobs/pages/jobs_page.dart` | Search, filter, browse jobs |
| Job detail | `lib/UI/public/jobs/pages/job_detail_page.dart` | View job + apply entry point |
| Candidate auth | `lib/UI/public/user/pages/login_page.dart`, `signup_page.dart` | Login / register |
| Profile | `lib/UI/public/user/pages/profile_page.dart`, `complete_profile_page.dart` | View / edit candidate profile |
| Applications | `lib/UI/public/application/` | My applications (built, not wired) |
| Routing | `lib/core/routes/app_routes.dart` | `/careers`, `/job-detail` ShellRoute |

### Entry flow

```
Staff login → Explore Careers → /careers (JobsPage)
                                    ├── Login (candidate)
                                    ├── Job detail → Apply
                                    └── Bottom nav: Home | My Jobs | Messages | Profile
```

---

## 2. API integration matrix

### 2.1 Working end-to-end

These APIs are called from UI and generally function as intended.

| Endpoint | Purpose | Service / BLoC | UI |
|----------|---------|----------------|-----|
| `POST auth-login.php` | Candidate login | `AuthApiService` → `UserBloc` | Candidate login |
| `POST auth-register.php` | Signup | `AuthApiService` → `UserBloc` | Signup |
| `POST auth-forgot-password.php` | Forgot password | `AuthApiService` → `UserBloc` | Login dialog |
| `GET jobs.php` | List / search / filter jobs | `JobsApiService` → `JobsBloc` | `JobsPage` |
| `GET job-details.php` | Job detail | `JobsApiService` → `JobsBloc` | `JobDetailPage` |
| `GET schools.php` | School dropdown | `JobsApiService` → `JobsBloc` | `EnhancedSearchBar` |
| `GET …/profile-completion` | Can candidate apply? | `AuthApiService` → `UserBloc` | Apply button |

Constants: [`lib/core/utils/constants/api_constant.dart`](lib/core/utils/constants/api_constant.dart) (static careers URLs).

### 2.2 Implemented in services + BLoC; UI usage varies

Profile APIs are implemented in [`ProfileApiService`](lib/UI/public/user/services/profile_api_service.dart) with handlers in [`UserBloc`](lib/UI/public/user/bloc/user_bloc.dart). **`MISSING_API_INTEGRATIONS.md` is outdated** for these—they are no longer “missing” at the service layer.

| Endpoint | Service | Primary UI |
|----------|---------|------------|
| `GET get-profile` | `getProfile()` | `CompleteProfilePage` (Basic tab) |
| `POST update-profile` | `updateProfile()` | Complete profile Basic tab |
| `POST/GET update/get-education` | `updateEducation()` / `getEducation()` | Education tab |
| `POST/GET update/get-experience` | `updateExperience()` / `getExperience()` | Experience tab |
| `POST/GET update/get-family` | `updateFamily()` / `getFamily()` | Family tab |
| `POST/GET update/get-references` | `updateReferences()` / `getReferences()` | References tab |
| `POST/GET update/get-professional-programs` | `updateProfessionalPrograms()` / `getProfessionalPrograms()` | Programs tab |
| `POST update-complete-profile` | `updateCompleteProfile()` | Service only; limited UI |

**Profile screen split:**

- **`ProfilePage`** — reads **local Hive** data via `CareersUserManager` only; does **not** call `GetFullProfileEvent`.
- **`CompleteProfilePage`** — uses **API** via `UserBloc` (multi-tab forms).

**Two update paths in `UserBloc`:**

- `UpdateProfileEvent` → updates **Hive only** (local).
- `UpdateProfileDataEvent` → calls **`update-profile` API**.

### 2.3 Built in code but not wired into the app

| Endpoint | What exists | Gap |
|----------|-------------|-----|
| `GET …/my-applications` | `ApplicationApiService`, `ApplicationBloc`, `MyApplicationsPage` | **`ApplicationBloc` not registered** in [`dependancy_injection.dart`](lib/dependancy_injection.dart) or [`app.dart`](lib/app.dart). **No navigation** to `MyApplicationsPage`. Bottom nav **My Jobs** opens empty [`MyJobsPage`](lib/UI/public/user/pages/my_jobs_page.dart) instead. |

### 2.4 URL in constants only — no fetch / no UI

| Endpoint | Gap |
|----------|-----|
| `GET countries.php` | `ApiConstants.countriesUrl` exists. No `fetchCountries()` in `JobsApiService`. Not used for nationality/location dropdowns in profile forms. |

### 2.5 Auth APIs with service/BLoC but no UI

| Endpoint | Status |
|----------|--------|
| `POST auth-reset-password.php` | `ResetPasswordEvent` in `UserBloc`; no reset-password screen |
| `POST auth-resend-verification.php` | Handler exists; no post-signup verification UI |
| `POST auth-verify-email.php` | Handler exists; no deep-link / verify screen |

### 2.6 Completely missing from the codebase

| Endpoint | Impact |
|----------|--------|
| **`POST apply-job`** | No constant, service, or submit flow. **Candidates cannot submit applications.** |
| **`GET check-application`** | No constant or service. Cannot show “already applied” on job detail. |

Apply UI: [`apply_dialog.dart`](lib/UI/public/jobs/components/apply_dialog.dart) is still a placeholder. Apply button runs profile completion check only—no application POST.

---

## 3. Feature-by-feature status

### 3.1 Jobs listing (`JobsPage`)

| Feature | Status | Notes |
|---------|--------|--------|
| Search by keywords | ✅ Works | `SearchJobsEvent` → API `search` |
| School filter | ✅ Works | `SelectSchoolEvent` → API `school_id` |
| Location field | ❌ UI only | Updates `_location` in state; **never** sent to bloc or API |
| Pull to refresh | ✅ Works | `RefreshJobsEvent` |
| Open job detail | ✅ Works | `Routes.jobDetail` |
| Bookmark on card | ⚠️ Partial | In-memory `Set` only; lost on refresh; not on My Jobs screen |
| Infinite scroll / pagination | ❌ Not wired | `LoadMoreJobsEvent` in bloc; UI never dispatches it |
| `JobSearchFilter` widget | ❌ Unused | Page uses `EnhancedSearchBar` only |
| Employment type filter | ⚠️ Partial | Client-side logic in `JobsBloc`; not exposed in current UI |

### 3.2 Job detail and apply

| Feature | Status | Notes |
|---------|--------|--------|
| Load job details | ✅ Works | |
| Apply button | ⚠️ Partial | `AuthGuard` → `CheckProfileCompletionEvent` only |
| Submit application | ❌ Missing | No `apply-job` API integration |
| CV / cover letter upload | ❌ Missing | No multipart upload |
| `ApplyDialog` | ❌ Placeholder | Not connected to real apply flow |

### 3.3 Bottom navigation

| Tab | User expectation | Actual behavior |
|-----|------------------|-----------------|
| Home | Job list | ✅ `JobsPage` |
| My Jobs | Saved jobs or applications | ❌ Empty [`MyJobsPage`](lib/UI/public/user/pages/my_jobs_page.dart); ignores bookmarks and `MyApplicationsPage` |
| Messages | Employer chat | ❌ Empty [`MessagesPage`](lib/UI/public/user/pages/messages_page.dart); no API |
| Profile | Candidate profile | ⚠️ [`ProfilePage`](lib/UI/public/user/pages/profile_page.dart) — Hive data only |

### 3.4 Candidate authentication

| Feature | Status |
|---------|--------|
| Login + session token in Hive | ✅ |
| Signup → redirect to login | ✅ |
| Forgot password (dialog) | ✅ |
| Browse jobs as guest | ✅ |
| Email verification flow | ❌ No UI |
| Password reset (token link) | ❌ No UI |
| Server-side logout | ❌ Local Hive clear only |

### 3.5 Profile and completion

| Feature | Status |
|---------|--------|
| Profile completion check (`can_apply`) | ✅ On apply tap |
| Complete profile (6 tabs, API save) | ✅ Mostly via `CompleteProfilePage` |
| Main profile view from API | ❌ `ProfilePage` uses local manager only |
| CV upload | ❌ Text field for `cv_file`, not file picker |
| Countries dropdown | ❌ No countries API fetch |

---

## 4. Configuration and architecture issues

1. **`JobsBloc` token always `null`**  
   In [`app_routes.dart`](lib/core/routes/app_routes.dart), careers routes create `JobsBloc` with `token: null`. Candidate `sessionToken` from Hive is not passed. Public job reads may still work; authenticated job features will not.

2. **`ApplicationBloc` not in dependency injection**  
   `UserBloc` is registered; `ApplicationBloc` / `ApplicationApiService` are not. Opening `MyApplicationsPage` would fail at runtime.

3. **Conflicting “My Jobs” concepts**  
   - Bookmarks on list (memory only)  
   - `MyApplicationsPage` (real API, unreachable)  
   - `MyJobsPage` (empty placeholder, used by nav)

4. **Location vs `countryId`**  
   `JobsApiService.fetchJobs()` supports `countryId` query param. Location text box does not map to it.

5. **App theme**  
   Careers UI uses design tokens with dark support; [`app.dart`](lib/app.dart) sets `themeMode: ThemeMode.light` globally.

6. **Documentation drift**  
   - [`MISSING_API_INTEGRATIONS.md`](MISSING_API_INTEGRATIONS.md) — still lists profile endpoints as missing (incorrect for service layer).  
   - [`PROFILE_API_IMPLEMENTATION.md`](PROFILE_API_IMPLEMENTATION.md) — more accurate for profile APIs.

---

## 5. What candidates can do today

| Can do | Cannot do |
|--------|-----------|
| Browse, search, and filter jobs by school | Filter by location (field is decorative) |
| View job details | Submit an application |
| Register, log in, reset password via email request | Complete email verification in-app |
| Fill complete profile via API (Complete Profile) | See live API profile on main Profile tab |
| Tap Apply and get profile completion feedback | Apply even when profile is complete |
| Bookmark jobs until page refresh | See bookmarks or applications under My Jobs |

---

## 6. Recommended implementation priority

### Critical (core product)

1. Add **`POST apply-job`** to `ApiConstants`, `ApplicationApiService`, and apply UI (cover letter, CV upload, success/error).
2. Add **`GET check-application`** for applied state on job detail.
3. Register **`ApplicationBloc`** in DI; connect bottom nav or My Jobs to **`MyApplicationsPage`** (or rename tab to “Applications”).
4. Pass **candidate session token** into `JobsBloc` where auth is required.

### High (misleading or broken UX)

5. Wire **location** to API (`country` / countries list) or remove the field.
6. Load **`ProfilePage`** from `get-profile`, not only Hive.
7. **Persist bookmarks** or remove bookmark UI until backend exists.
8. Hook **`LoadMoreJobsEvent`** to list scroll for pagination.

### Medium

9. Implement **`GET countries`** for profile dropdowns.
10. **Email verification** and **reset password** screens.
11. **CV/resume file upload** (multipart), not text field.
12. **Messages** — requires backend contract + UI (currently none).

### Low / cleanup

13. Remove or integrate unused **`JobSearchFilter`**.
14. Update **`MISSING_API_INTEGRATIONS.md`** to reflect profile completion.
15. Align **`CompleteProfilePage`** styling with Pace Careers design system.

---

## 7. Key file reference

| Concern | Files |
|---------|--------|
| Routes | `lib/core/routes/app_routes.dart` |
| Job API | `lib/UI/public/jobs/services/jobs_api_service.dart` |
| Job state | `lib/UI/public/jobs/bloc/jobs_bloc.dart` |
| Jobs UI | `lib/UI/public/jobs/pages/jobs_page.dart`, `components/enhanced_search_bar.dart`, `careers_bottom_nav.dart` |
| Apply | `lib/UI/public/jobs/components/apply_button.dart`, `apply_dialog.dart` |
| Auth API | `lib/UI/public/user/services/auth_api_service.dart` |
| Profile API | `lib/UI/public/user/services/profile_api_service.dart` |
| User state | `lib/UI/public/user/bloc/user_bloc.dart` |
| Local candidate session | `lib/UI/public/user/services/careers_user_service.dart` |
| Applications (unwired) | `lib/UI/public/application/` |
| API URLs | `lib/core/utils/constants/api_constant.dart` |
| DI | `lib/dependancy_injection.dart`, `lib/app.dart` |

---

## 8. Related documents

| Document | Scope |
|----------|--------|
| [`MISSING_API_INTEGRATIONS.md`](MISSING_API_INTEGRATIONS.md) | Original API gap list (partially outdated for profile) |
| [`PROFILE_API_IMPLEMENTATION.md`](PROFILE_API_IMPLEMENTATION.md) | Profile service methods and models |
| [`lib/UI/public/jobs/README.md`](lib/UI/public/jobs/README.md) | Jobs component notes |
| [`lib/UI/public/user/README_PROFILE_COMPLETION.md`](lib/UI/public/user/README_PROFILE_COMPLETION.md) | Profile completion API usage |

---

*This is a UI/integration status document. Backend behavior should be verified against the live PACE Education Careers API documentation when implementing missing endpoints.*
