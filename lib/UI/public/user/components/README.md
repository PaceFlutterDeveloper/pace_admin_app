# User Profile Components

This directory contains reusable components for the user profile functionality, following clean architecture principles with integrated profile completion status.

## Component Structure

### Main Components

#### 1. **ProfileHeaderCard** (`profile_header_card.dart`)
- Displays user avatar, name, and email
- Shows profile completion status with visual indicators
- Uses color-coded status badges (green for complete, orange for incomplete)
- Includes completion callback for navigation

#### 2. **ProfileInfoCard** (`profile_info_card.dart`)
- Displays personal information in read-only format
- Shows user data from CareersUserManager
- Clean, informative layout with icons and labels
- No editing capabilities - purely informational

#### 3. **ProfileCompletionButton** (`profile_completion_button.dart`)
- **Simple Profile Status Display**: Shows completion status based on local data
- **Dynamic UI**: Shows different states based on completion status
- **Complete Profile**: Shows success message and status
- **Incomplete Profile**: Shows warning with "Complete Profile" button
- **Navigation Support**: Handles navigation to complete profile page

#### 4. **LogoutDialog** (`logout_dialog.dart`)
- Confirmation dialog for logout action
- Clean, reusable dialog component
- Static show method for easy usage

### Shared Components

#### 1. **ProfileCard** (`shared/profile_card.dart`)
- Reusable card container with consistent styling
- White background with subtle shadow
- Rounded corners and padding
- Used across all profile components

## Profile Completion Integration

### Features

1. **Simple Status Display**: Shows completion status based on local user data
2. **Visual Status Indicators**: Color-coded badges and icons
3. **Direct Navigation**: Single button to complete profile when incomplete
4. **Clean UI**: Simplified interface without unnecessary API calls

### Status States

#### ✅ **Profile Complete**
- Green success indicator
- "Profile Complete!" message
- Confirmation that user can apply for jobs

#### ⚠️ **Profile Incomplete**
- Orange warning indicator
- "Profile Incomplete" message
- Single action button:
  - **Complete Profile**: Navigates to profile completion page

## Usage Example

```dart
import 'package:admin_app/UI/public/user/components/index.dart';

// In your widget
Column(
  children: [
    ProfileHeaderCard(),
    SizedBox(height: 24),
    ProfileInfoCard(),
    SizedBox(height: 24),
    ProfileCompletionButton(
      onNavigateToCompleteProfile: () {
        Navigator.pushNamed(context, '/complete-profile');
      },
    ),
  ],
)
```

## Simple Integration

The ProfileCompletionButton uses local user data for status:

```dart
// Simple usage - no API calls needed
ProfileCompletionButton(
  onNavigateToCompleteProfile: () {
    Navigator.pushNamed(context, '/complete-profile');
  },
)
```

## Benefits

### 1. **Clean Architecture**
- Single responsibility principle
- Clear separation of concerns
- Easy to maintain and extend

### 2. **Reusability**
- Components can be used across different pages
- Consistent UI/UX throughout the app
- Shared styling and behavior

### 3. **Simple Profile Management**
- Local status detection
- Context-aware UI updates
- Clean, straightforward interface

### 4. **User Experience**
- Clear visual feedback
- Intuitive navigation flow
- Loading states and error handling

### 5. **Maintainability**
- Easy to modify individual components
- Clear component boundaries
- Consistent code structure

## File Organization

```
components/
├── index.dart                           # Export all components
├── profile_header_card.dart            # Profile header with status
├── profile_form_card.dart              # Profile form
├── profile_completion_button.dart      # Smart completion button
├── logout_dialog.dart                  # Logout confirmation
├── README.md                           # Documentation
└── shared/                             # Shared components
    ├── custom_form_field.dart          # Form field styling
    └── profile_card.dart               # Card container
```

## Design Principles

1. **Component-Based**: Each component has a single, clear purpose
2. **Props-Based API**: Clear input parameters for customization
3. **State Management**: Proper BLoC integration for state handling
4. **Responsive Design**: All components adapt to screen size
5. **Accessibility**: Proper semantic structure and contrast
6. **Error Handling**: Graceful error states and user feedback

## Future Enhancements

- Add profile picture upload functionality
- Implement profile completion progress bar
- Add skill tags and preferences
- Create profile sharing functionality
- Add profile analytics and insights
