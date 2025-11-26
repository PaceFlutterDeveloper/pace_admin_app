# Profile Completion API Integration

This document explains how to use the profile completion API to check if a candidate's profile is complete and whether they can apply for jobs.

## Overview

The profile completion API allows you to:
- Check if a candidate's profile is complete
- Determine if the candidate can apply for jobs
- Get the completion percentage
- Retrieve missing fields that need to be filled

## API Endpoint

```
GET /erp-api/index.php/profile-completion?cand_id={candidate_id}
```

## Response Structure

```json
{
  "status": true,
  "message": "Profile completion status retrieved successfully",
  "data": {
    "completion": {
      "percentage": 75,
      "is_complete": false,
      "can_apply": false,
      "is_fresher": true,
      "required_percentage": 85,
      "missing_fields": [
        "date_of_birth",
        "marital_status",
        "visa_status",
        "nationality_country_id",
        "current_country_id",
        "expected_ctc",
        "available_from",
        "conviction_yn",
        "govt_issue_yn",
        "avatar_file",
        "education_records",
        "experience_records"
      ]
    }
  }
}
```

## Implementation

### 1. Model

The `ProfileCompletionModel` class handles the API response:

```dart
class ProfileCompletionModel {
  final bool isComplete;
  final bool canApply;
  final int percentage;
  final bool isFresher;
  final int requiredPercentage;
  final List<String> missingFields;
}
```

### 2. API Service

The `AuthApiService` includes a method to call the profile completion API:

```dart
Future<Either<MyError, ProfileCompletionModel>> getProfileCompletion({
  required String candidateId,
  String? token,
})
```

### 3. BLoC Events and States

#### Event
```dart
class CheckProfileCompletionEvent extends UserEvent {
  final String candidateId;
  CheckProfileCompletionEvent({required this.candidateId});
}
```

#### States
```dart
class ProfileCompletionLoading extends UserState {}
class ProfileCompletionSuccess extends UserState {
  final ProfileCompletionModel profileCompletion;
}
class ProfileCompletionError extends UserState {
  final String message;
}
```

### 4. Helper Utility

The `ProfileCompletionHelper` class provides utility methods:

```dart
// Check if user should navigate to complete profile
bool shouldNavigateToCompleteProfile(ProfileCompletionModel profileCompletion)

// Get user-friendly message
String getProfileCompletionMessage(ProfileCompletionModel profileCompletion)

// Check if user can apply for jobs
bool canApplyForJobs(ProfileCompletionModel profileCompletion)

// Check if profile is complete
bool isProfileComplete(ProfileCompletionModel profileCompletion)

// Get missing fields
List<String> getMissingFields(ProfileCompletionModel profileCompletion)
```

## Usage Examples

### Basic Usage

```dart
// Trigger profile completion check
context.read<UserBloc>().add(
  CheckProfileCompletionEvent(candidateId: '1'),
);

// Listen to state changes
BlocListener<UserBloc, UserState>(
  listener: (context, state) {
    if (state is ProfileCompletionSuccess) {
      final profileCompletion = state.profileCompletion;
      
      if (ProfileCompletionHelper.shouldNavigateToCompleteProfile(profileCompletion)) {
        // Navigate to complete profile page
        Navigator.pushNamed(context, '/complete-profile');
      } else {
        // Profile is complete - navigate to jobs or main app
        Navigator.pushNamed(context, '/jobs');
      }
    }
  },
  child: YourWidget(),
)
```

### Using the Helper Widget

```dart
ProfileCompletionWidget(
  candidateId: '1',
  onNavigateToCompleteProfile: () {
    Navigator.pushNamed(context, '/complete-profile');
  },
  onNavigateToJobs: () {
    Navigator.pushNamed(context, '/jobs');
  },
)
```

### Programmatic Check

```dart
// Check if profile is complete
if (ProfileCompletionHelper.isProfileComplete(profileCompletion)) {
  // Profile is complete
}

// Check if user can apply
if (ProfileCompletionHelper.canApplyForJobs(profileCompletion)) {
  // User can apply for jobs
}

// Get completion message
String message = ProfileCompletionHelper.getProfileCompletionMessage(profileCompletion);
```

## Navigation Logic

The typical navigation flow based on profile completion status:

1. **Profile Complete + Can Apply**: Navigate to jobs page or main app
2. **Profile Complete + Cannot Apply**: Show message and contact support
3. **Profile Incomplete**: Navigate to complete profile page

## Error Handling

The API call handles various error scenarios:

- Network errors
- API errors (400, 401, 403, 404, 500)
- Invalid candidate ID
- Missing authentication token

## Integration Steps

1. **Add the API endpoint** to your constants
2. **Create the model** for profile completion data
3. **Add the API service method** to make the call
4. **Add BLoC events and states** for state management
5. **Update the BLoC** to handle the new event
6. **Use the helper utility** for navigation logic
7. **Implement the UI** using the provided widgets

## Files Created/Modified

- `lib/UI/public/user/models/profile_completion_model.dart` - Model for API response
- `lib/UI/public/user/services/auth_api_service.dart` - API service method
- `lib/UI/public/user/bloc/user_events.dart` - New event added
- `lib/UI/public/user/bloc/user_states.dart` - New states added
- `lib/UI/public/user/bloc/user_bloc.dart` - Event handler added
- `lib/UI/public/user/utils/profile_completion_helper.dart` - Helper utility
- `lib/UI/public/user/components/profile_completion_widget.dart` - UI widget
- `lib/UI/public/user/examples/profile_completion_usage_example.dart` - Usage examples
- `lib/core/utils/constants/api_constant.dart` - API endpoint added

## Testing

To test the profile completion API:

1. Ensure you have a valid candidate ID
2. Make sure the API endpoint is accessible
3. Test with different profile completion states
4. Verify navigation logic works correctly
5. Test error handling scenarios

## Notes

- The API requires a valid candidate ID
- Authentication token is optional but recommended
- The response includes detailed breakdown of missing fields
- The completion percentage is calculated based on required fields
- The `can_apply` flag determines if the user can apply for jobs
