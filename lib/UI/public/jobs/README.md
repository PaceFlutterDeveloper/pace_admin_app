# Jobs Listing Feature

A comprehensive job listing UI with search and filter functionality for the admin app.

## Features

- **Job Listings**: Display jobs with title, company, location, date, and other details
- **Search Functionality**: Search jobs by title, company, or location
- **Filter Options**: Filter by department, status, employment type, and more
- **Responsive Design**: Adapts to different screen sizes
- **State Management**: Uses BLoC pattern for efficient state management
- **Error Handling**: Proper error states and loading indicators
- **Pull to Refresh**: Refresh job listings by pulling down

## Components

### 1. JobModel (`models/job_model.dart`)
Data model representing a job listing with fields:
- `id`: Unique identifier
- `title`: Job title
- `location`: Job location
- `company`: Company name
- `postedDate`: When the job was posted
- `description`: Job description
- `requirements`: Job requirements
- `salary`: Salary information
- `employmentType`: Full-time, Part-time, Contract
- `experienceLevel`: Entry, Mid, Senior
- `department`: Department category
- `status`: Open, Closed, On Hold
- `isActive`: Whether the job is active

### 2. JobCard (`components/job_card.dart`)
Displays individual job information in a card format with:
- Job title and status badge
- Company and location with icons
- Posted date with relative time formatting
- Employment type, experience level, and salary chips
- Job description preview

### 3. JobSearchFilter (`components/job_search_filter.dart`)
Search and filter component with:
- Text search field with clear button
- Dropdown filter with multiple options
- Real-time search and filter updates

### 4. JobsPage (`pages/jobs_page.dart`)
Main page that combines all components:
- Search and filter section at the top
- Scrollable list of job cards
- Loading, error, and empty states
- Pull-to-refresh functionality

### 5. JobsBloc (`bloc/jobs_bloc.dart`)
State management using BLoC pattern:
- `FetchJobsEvent`: Load jobs with optional search/filter
- `SearchJobsEvent`: Search jobs by query
- `FilterJobsEvent`: Filter jobs by category
- Mock data included for demonstration

## Usage

### Basic Usage
```dart
import 'package:admin_app/UI/public/jobs/pages/jobs_page.dart';
import 'package:admin_app/UI/public/jobs/bloc/jobs_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Wrap with BlocProvider
BlocProvider(
  create: (context) => JobsBloc(),
  child: const JobsPage(),
)
```

### Navigation
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BlocProvider(
      create: (context) => JobsBloc(),
      child: const JobsPage(),
    ),
  ),
);
```

### GoRouter Integration
Add to your routes:
```dart
GoRoute(
  path: '/jobs',
  name: 'jobs',
  builder: (_, __) => BlocProvider(
    create: (context) => JobsBloc(),
    child: const JobsPage(),
  ),
),
```

## Customization

### Colors
The UI uses the app's color scheme defined in `ConstColors`:
- Primary: Purple (#5B2ED4)
- Background: Light gray (#F1F3F8)
- Text: Dark gray (#1F1F1F) and light gray (#6E6E6E)
- Borders: Light gray (#E3E4E3)

### Filter Options
Modify the `_filterOptions` list in `JobsPage` to customize available filters:
```dart
final List<String> _filterOptions = [
  'All',
  'Department',
  'Engineering',
  'Design',
  // Add more options...
];
```

### Mock Data
Replace the mock data in `JobsBloc` with actual API calls:
```dart
// In _onFetchJobs method, replace mock data with:
final response = await jobsApiService.fetchJobs(
  searchQuery: event.searchQuery,
  filterBy: event.filterBy,
);
```

## API Integration

To integrate with a real API:

1. Create an API service class
2. Replace mock data in `JobsBloc` with actual API calls
3. Handle API errors appropriately
4. Add pagination if needed

Example API service structure:
```dart
class JobsApiService {
  Future<JobResponseModel> fetchJobs({
    String? searchQuery,
    String? filterBy,
    int page = 1,
    int limit = 10,
  }) async {
    // Implement API call
  }
}
```

## Dependencies

- `flutter_bloc`: State management
- `flutter`: UI framework

## File Structure

```
lib/UI/public/jobs/
├── bloc/
│   └── jobs_bloc.dart
├── components/
│   ├── job_card.dart
│   └── job_search_filter.dart
├── models/
│   └── job_model.dart
├── pages/
│   └── jobs_page.dart
├── example_usage.dart
└── README.md
```
