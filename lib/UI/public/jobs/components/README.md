# Job Detail Components

This directory contains reusable components for the job detail functionality, following clean architecture principles.

## Component Structure

### Main Components

#### 1. **JobHeaderCard** (`job_header_card.dart`)
- Displays job title, company, location, status, and dates
- Includes share functionality
- Shows status badge with color coding
- Handles date formatting and deadline display

#### 2. **JobInfoCard** (`job_info_card.dart`)
- Shows employment type, experience level, and salary
- Uses InfoRow components for consistent layout
- Displays salary information conditionally

#### 3. **JobDescriptionCard** (`job_description_card.dart`)
- Displays job description text
- Uses shared DescriptionText component
- Only shows if description is not empty

#### 4. **JobRequirementsCard** (`job_requirements_card.dart`)
- Shows job requirements
- Uses shared DescriptionText component
- Only shows if requirements exist

#### 5. **CompanyCard** (`company_card.dart`)
- Displays company information
- Shows generic company description
- Uses company name from job model

#### 6. **ApplyButton** (`apply_button.dart`)
- Main apply button with gradient styling
- Handles authentication check
- Triggers apply dialog on tap

#### 7. **ApplyDialog** (`apply_dialog.dart`)
- Modal dialog for job application
- Static show method for easy usage
- Handles application submission callback

### Shared Components

#### 1. **CardDecoration** (`shared/card_decoration.dart`)
- Reusable card styling
- Consistent border, shadow, and radius
- Used across all card components

#### 2. **SectionTitle** (`shared/section_title.dart`)
- Consistent section title styling
- Responsive font sizing
- Used in all card components

#### 3. **InfoRow** (`shared/info_row.dart`)
- Icon + label + value layout
- Consistent spacing and typography
- Used in JobInfoCard

#### 4. **DescriptionText** (`shared/description_text.dart`)
- Consistent text styling for descriptions
- Proper line height and font weight
- Used in description and requirements cards

## Usage Example

```dart
import 'package:admin_app/UI/public/jobs/components/index.dart';

// In your widget
Column(
  children: [
    JobHeaderCard(job: job),
    SizedBox(height: 16),
    JobInfoCard(job: job),
    SizedBox(height: 16),
    if (job.description.isNotEmpty) JobDescriptionCard(job: job),
    if (job.requirements?.isNotEmpty ?? false) JobRequirementsCard(job: job),
    CompanyCard(job: job),
    ApplyButton(
      job: job,
      onApply: () => _handleApply(job),
    ),
  ],
)
```

## Benefits

### 1. **Reusability**
- Components can be used across different pages
- Consistent UI/UX throughout the app
- Easy to maintain and update

### 2. **Maintainability**
- Single responsibility principle
- Easy to modify individual components
- Clear separation of concerns

### 3. **Testability**
- Each component can be tested independently
- Mock data can be easily provided
- Isolated functionality testing

### 4. **Scalability**
- Easy to add new components
- Simple to extend existing components
- Clean import structure with index file

### 5. **Performance**
- Only rebuilds necessary components
- Efficient widget tree structure
- Optimized rendering

## File Organization

```
components/
├── index.dart                    # Export all components
├── job_header_card.dart         # Main job header
├── job_info_card.dart           # Job information
├── job_description_card.dart    # Job description
├── job_requirements_card.dart   # Job requirements
├── company_card.dart            # Company information
├── apply_button.dart            # Apply button
├── apply_dialog.dart            # Apply dialog
└── shared/                      # Shared components
    ├── card_decoration.dart     # Card styling
    ├── section_title.dart       # Section titles
    ├── info_row.dart           # Info row layout
    └── description_text.dart   # Description text
```

## Design Principles

1. **Single Responsibility**: Each component has one clear purpose
2. **Composition over Inheritance**: Components are composed together
3. **Props-based API**: Clear input parameters for customization
4. **Consistent Styling**: Shared styling through utility components
5. **Responsive Design**: All components adapt to screen size
6. **Accessibility**: Proper semantic structure and contrast

## Future Enhancements

- Add animation support
- Implement theme switching
- Add accessibility features
- Create component documentation
- Add unit tests for each component
