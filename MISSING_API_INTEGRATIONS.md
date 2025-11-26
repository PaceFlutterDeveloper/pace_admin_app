# Missing API Integrations

This document lists the API integrations that are **missing** from the Flutter app based on the PACE Education Careers API documentation.

## Summary

**Total Missing: 10 API endpoints**

## 1. Profile Management APIs (7 endpoints)

### GET /get-profile
- **Purpose**: Retrieve complete user profile information
- **Required Query Parameter**: `cand_id`
- **Implementation Needed**: 
  - Add endpoint to `ApiConstants`
  - Create service method in a new `ProfileApiService` or extend `AuthApiService`
  - Add BLoC event/state handling
  - Create UI for displaying profile data

### POST /update-profile
- **Purpose**: Update basic profile information (name, email, phone, DOB, etc.)
- **Required Body**: `cand_id`, and other profile fields
- **Implementation Needed**: Similar to above

### POST /update-education
- **Purpose**: Update education records
- **Required Body**: Education details
- **Implementation Needed**: Service + UI for managing education entries

### POST /update-experience
- **Purpose**: Update work experience records
- **Required Body**: Experience details
- **Implementation Needed**: Service + UI for managing experience entries

### POST /update-family
- **Purpose**: Update family member information
- **Required Body**: Family member details
- **Implementation Needed**: Service + UI for managing family members

### POST /update-references
- **Purpose**: Update professional references
- **Required Body**: Reference details
- **Implementation Needed**: Service + UI for managing references

### POST /update-professional-programs
- **Purpose**: Update professional programs/certifications
- **Required Body**: Program details
- **Implementation Needed**: Service + UI for managing professional programs

### POST /update-complete-profile
- **Purpose**: Update entire profile at once
- **Required Body**: Complete profile data
- **Implementation Needed**: Service method that combines all profile updates

## 2. Job Application APIs (2 endpoints)

### POST /apply-job
- **Purpose**: Submit a job application
- **Required Body**: 
  - `job_id`
  - `cand_id`
  - `cover_letter`
  - `cv_file`
  - `source`
- **Implementation Needed**: 
  - Add endpoint to `ApiConstants`
  - Create method in `ApplicationApiService`
  - Add BLoC event for applying to jobs
  - Implement file upload for CV
  - Update `ApplyDialog` component to actually submit applications

### GET /check-application
- **Purpose**: Check application status for a specific job
- **Required Query Parameters**: `job_id`, `cand_id`
- **Implementation Needed**: 
  - Add endpoint to `ApiConstants`
  - Create method in `ApplicationApiService`
  - Add UI to show application status

## 3. Reference Data (1 endpoint)

### GET /countries
- **Status**: Endpoint exists in `ApiConstants.getCountriesUrl()` at line 142-144
- **Implementation Needed**: 
  - Create `fetchCountries()` method in `JobsApiService` (similar to `fetchSchools()`)
  - Add model for country data
  - Add BLoC state management for countries
- **Note**: Should be used for nationality/location dropdowns in profile

## Implementation Priority

### High Priority (Required for core functionality)
1. **POST /apply-job** - Users need to be able to apply for jobs
2. **GET /get-profile** - Display and manage user profiles
3. **POST /update-profile** - Update basic profile information
4. **POST /update-education** - Add/update education records
5. **POST /update-experience** - Add/update work experience

### Medium Priority (Enhanced profile management)
6. **POST /update-references** - Add professional references
7. **POST /update-family** - Add family information
8. **POST /update-professional-programs** - Add certifications
9. **GET /check-application** - Track application status

### Low Priority (Nice to have)
10. **POST /update-complete-profile** - Bulk profile update

## Files That Need Creation/Updates

### New Files to Create
1. `lib/UI/public/profile/services/profile_api_service.dart` - Profile management APIs
2. `lib/UI/public/profile/bloc/profile_bloc.dart` - Profile state management
3. `lib/UI/public/profile/bloc/profile_events.dart` - Profile events
4. `lib/UI/public/profile/bloc/profile_states.dart` - Profile states
5. `lib/UI/public/profile/pages/profile_page.dart` - Main profile UI
6. `lib/UI/public/profile/components/education_form.dart` - Education input form
7. `lib/UI/public/profile/components/experience_form.dart` - Experience input form

### Files to Update
1. ✅ `lib/core/utils/constants/api_constant.dart` - **DONE** - All profile endpoints added
2. `lib/UI/public/application/services/application_api_service.dart` - Add apply-job method
3. `lib/UI/public/jobs/components/apply_dialog.dart` - Connect to actual API
4. `lib/UI/public/jobs/services/jobs_api_service.dart` - Add countries fetching if missing
5. ✅ Profile models and services created in `lib/UI/public/user/`

## Implementation Notes

- ✅ Profile management APIs added to existing `user` folder structure (not a separate `profile` folder)
- ✅ All 8 profile API endpoints implemented in `ProfileApiService`
- The current profile update implementation in `UserBloc` only updates local state, not server-side
- Need to integrate `ProfileApiService` with existing `UserBloc` or create new BLoC
- Need to implement file upload functionality for CV/resume
- Profile completion check is already implemented and can be used to trigger profile update flows
- Countries endpoint might need to be added to `JobsApiService` if not already there

