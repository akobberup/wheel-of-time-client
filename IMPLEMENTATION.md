# Årshjulet (Wheel of Time) - Full Implementation Guide

## Overview
This is a complete Flutter implementation of the Årshjulet task management app, featuring task lists, recurring tasks, task completion tracking, sharing/invitations, and image uploads.

## Features Implemented

### ✅ Authentication
- User registration with email/password (min 8 characters)
- Login with JWT token authentication
- Password reset via email
- Secure token storage (mobile: flutter_secure_storage, web: shared_preferences)
- Auto-logout and token validation

### ✅ Task Lists
- **Create** task lists with name, description, and optional image
- **View** all accessible task lists (owned + shared)
- **Edit** task list details
- **Delete** task lists (owner only)
- Visual indicators for task count, active tasks, and member count

### ✅ Tasks
- **Create** tasks with:
  - Name and description
  - Recurrence patterns (Daily, Weekly, Monthly, Yearly)
  - Repeat intervals (e.g., every 2 days, every 3 weeks)
  - First run date
  - Optional task image
  - Alarm times and completion windows
- **View** all tasks in a list with recurrence info
- **Complete** tasks with:
  - Custom completion date/time
  - Optional comment
  - Optional image attachment
- **Streaks** - Track consecutive completions
- **Active/Inactive** toggle for tasks

### ✅ Task Instances
- Auto-generated based on recurrence patterns
- Manual completion with timestamp
- Comment and image attachment support
- Streak contribution tracking

### ✅ Sharing & Invitations
- **Invite** users to task lists via email
- **Accept/Decline** pending invitations
- **View** all invitations (pending and historical)
- Email notifications for invitations
- Badge counter for pending invitations

### ✅ Permissions
- **Owner** - Full control (edit, delete, manage members)
- **Can Edit** - Can add/edit/complete tasks
- **Can View** - Read-only access

### ✅ Images
- Upload images for task lists, tasks, and task instances
- Support for USER, TASK_LIST, TASK, TASK_INSTANCE sources
- Gallery and camera picker integration
- Automatic thumbnail generation
- Cached network images for performance

### ✅ Localization
- **English** (en) - Full translation
- **Danish** (da) - Full translation, set as default
- Easy to add more languages
- Context-aware string interpolation

### ✅ UI/UX
- **Bottom Navigation** - Lists and Invitations tabs
- **Material 3** design system
- **Responsive** layouts
- **Pull to refresh** on all lists
- **Empty states** with helpful messages
- **Loading indicators** for async operations
- **Error handling** with retry options
- **Cached images** for better performance

## Architecture

```
lib/
├── models/               # Data models with freezed
│   ├── enums.dart       # RepeatUnit, AdminLevel, InvitationState, ImageSource
│   ├── task_list.dart
│   ├── task.dart
│   ├── task_instance.dart
│   ├── invitation.dart
│   ├── task_list_user.dart
│   ├── streak.dart
│   ├── image.dart
│   ├── local_time.dart
│   └── auth_response.dart
├── services/
│   └── api_service.dart  # Complete API client
├── providers/            # Riverpod state management
│   ├── auth_provider.dart
│   ├── task_list_provider.dart
│   ├── task_provider.dart
│   ├── task_instance_provider.dart
│   ├── invitation_provider.dart
│   ├── task_list_user_provider.dart
│   ├── image_provider.dart
│   └── locale_provider.dart
├── screens/              # Main screens
│   ├── login_screen.dart
│   ├── forgot_password_screen.dart
│   ├── reset_password_screen.dart
│   ├── main_navigation_screen.dart
│   ├── task_lists_screen.dart
│   ├── task_list_detail_screen.dart
│   └── invitations_screen.dart
├── widgets/              # Reusable dialogs
│   ├── create_task_list_dialog.dart
│   ├── create_task_dialog.dart
│   └── complete_task_dialog.dart
└── l10n/                 # Localization
    ├── app_strings.dart
    ├── strings_en.dart
    └── strings_da.dart
```

## API Integration

### Base URL
- Default: `http://localhost:8080`
- Configurable in `ApiService.baseUrl`

### Authentication
All endpoints (except `/api/auth/**`) require JWT authentication:
```dart
Authorization: Bearer {token}
```

### Endpoints Implemented

**Authentication:**
- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/forgot-password`
- `GET /api/auth/validate-reset-token`
- `POST /api/auth/reset-password`

**Task Lists:**
- `GET /api/task-lists` - All accessible lists
- `GET /api/task-lists/owned` - User's owned lists
- `GET /api/task-lists/shared` - Shared with user
- `GET /api/task-lists/{id}` - Single list
- `POST /api/task-lists` - Create
- `PUT /api/task-lists/{id}` - Update
- `DELETE /api/task-lists/{id}` - Delete

**Tasks:**
- `GET /api/tasks/task-list/{taskListId}` - Tasks in list
- `GET /api/tasks/{id}` - Single task
- `POST /api/tasks` - Create
- `PUT /api/tasks/{id}` - Update
- `DELETE /api/tasks/{id}` - Delete

**Task Instances:**
- `GET /api/task-instances/task/{taskId}` - Instances for task
- `GET /api/task-instances/task-list/{taskListId}` - Instances for list
- `GET /api/task-instances/{id}` - Single instance
- `POST /api/task-instances` - Create (complete task)

**Streaks:**
- `GET /api/task-instances/task/{taskId}/streak/current`
- `GET /api/task-instances/task/{taskId}/streak/longest`
- `GET /api/task-instances/task/{taskId}/streaks`

**Invitations:**
- `GET /api/invitations/my-invitations/pending`
- `GET /api/invitations/my-invitations`
- `GET /api/invitations/task-list/{taskListId}`
- `GET /api/invitations/{id}`
- `POST /api/invitations` - Create
- `POST /api/invitations/{id}/accept`
- `POST /api/invitations/{id}/decline`
- `DELETE /api/invitations/{id}` - Cancel

**Task List Users:**
- `GET /api/task-list-users/task-list/{taskListId}`
- `PUT /api/task-list-users` - Update permissions
- `DELETE /api/task-list-users` - Remove user

**Images:**
- `POST /api/images` - Upload (multipart/form-data)
- `GET /api/images/{id}` - Get image
- `GET /api/images/{id}/thumbnail` - Get thumbnail
- `DELETE /api/images/{id}` - Delete

## State Management with Riverpod

### Providers

**Task Lists:**
```dart
final taskListProvider = StateNotifierProvider<TaskListNotifier, AsyncValue<List<TaskListResponse>>>
final taskListDetailProvider = FutureProvider.family<TaskListResponse, int>
```

**Tasks:**
```dart
final tasksProvider = StateNotifierProvider.family<TasksNotifier, AsyncValue<List<TaskResponse>>, int>
final taskDetailProvider = FutureProvider.family<TaskResponse, int>
```

**Task Instances:**
```dart
final taskInstancesProvider = StateNotifierProvider.family<TaskInstancesNotifier, AsyncValue<List<TaskInstanceResponse>>, int>
```

**Invitations:**
```dart
final invitationProvider = StateNotifierProvider<InvitationNotifier, AsyncValue<List<InvitationResponse>>>
```

**Images:**
```dart
final imageServiceProvider = Provider<ImageService>
```

## Data Models

All models use **freezed** for immutability and code generation:

```dart
@freezed
class TaskListResponse with _$TaskListResponse {
  const factory TaskListResponse({
    required int id,
    required String name,
    String? description,
    required int ownerId,
    required String ownerName,
    String? taskListImagePath,
    @Default(0) int taskCount,
    @Default(0) int activeTaskCount,
    @Default(0) int memberCount,
  }) = _TaskListResponse;

  factory TaskListResponse.fromJson(Map<String, dynamic> json) =>
      _$TaskListResponseFromJson(json);
}
```

## Usage Examples

### Creating a Task List
```dart
final request = CreateTaskListRequest(
  name: 'Household Chores',
  description: 'Daily and weekly household tasks',
);

final result = await ref.read(taskListProvider.notifier).createTaskList(request);
```

### Creating a Recurring Task
```dart
final request = CreateTaskRequest(
  name: 'Water plants',
  description: 'Water all indoor plants',
  taskListId: 1,
  repeatUnit: RepeatUnit.DAYS,
  repeatDelta: 2,  // Every 2 days
  firstRunDate: DateTime.now(),
);

final result = await ref.read(tasksProvider(taskListId).notifier).createTask(request);
```

### Completing a Task
```dart
final request = CreateTaskInstanceRequest(
  taskId: 1,
  completedDateTime: DateTime.now(),
  optionalComment: 'All plants watered!',
);

final result = await ref.read(taskInstancesProvider(taskId).notifier).createTaskInstance(request);
```

### Sending an Invitation
```dart
final request = CreateInvitationRequest(
  taskListId: 1,
  emailAddress: 'friend@example.com',
);

final result = await ref.read(invitationProvider.notifier).createInvitation(request);
```

### Uploading an Image
```dart
final imageService = ref.read(imageServiceProvider);
final image = await imageService.pickAndUploadImage(ImageSource.TASK_LIST);
```

## Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.6.1       # State management
  http: ^1.2.2                    # HTTP client
  flutter_secure_storage: ^9.2.2 # Secure storage
  shared_preferences: ^2.3.4     # Web storage
  freezed_annotation: ^2.4.4     # Code generation
  json_annotation: ^4.9.0        # JSON serialization
  image_picker: ^1.0.7           # Image picker
  cached_network_image: ^3.3.1   # Cached images
  flutter_localizations:          # Localization
    sdk: flutter

dev_dependencies:
  build_runner: ^2.4.13
  freezed: ^2.5.7
  json_serializable: ^6.8.0
```

## Build Instructions

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Generate code (freezed + json_serializable):**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

## Environment Configuration

### Development
- API Base URL: `http://localhost:8080`
- Default locale: Danish (da)

### Production
Update `ApiService.baseUrl` to point to your production server.

## Testing

The backend API must be running on `http://localhost:8080` for the app to function.

### Quick Test Flow:
1. Register a new account
2. Create a task list
3. Add tasks with recurrence patterns
4. Complete tasks
5. View streaks
6. Invite another user (they'll receive an email)
7. Accept invitation and view shared list

## Future Enhancements

Suggested features to add:
- [ ] Task list search and filtering
- [ ] Task sorting (by name, due date, etc.)
- [ ] Notifications for upcoming tasks
- [ ] Calendar view of tasks
- [ ] Statistics and analytics
- [ ] Export/import functionality
- [ ] Dark mode
- [ ] Offline support with local database
- [ ] Task templates
- [ ] Subtasks
- [ ] Tags/categories
- [ ] Custom recurrence patterns
- [ ] Task reminders
- [ ] User profiles
- [ ] Task comments/notes history

## Known Limitations

1. **No offline support** - Requires active internet connection
2. **No task editing** - Currently can only create/delete tasks, not edit
3. **No user management screen** - Can't view/manage task list members in UI (API supports it)
4. **No "Today" view** - No dedicated screen for today's tasks
5. **Basic error handling** - Could be more user-friendly
6. **No task list image display** - API supports it but not shown in current UI
7. **No advanced filtering** - Can't filter by date range, status, etc.

## Troubleshooting

### Build errors after adding models
Run: `flutter pub run build_runner build --delete-conflicting-outputs`

### "Failed to load task lists" error
- Check that backend is running on `http://localhost:8080`
- Verify JWT token is valid
- Check network connectivity

### Image upload fails
- Verify image picker permissions in AndroidManifest.xml and Info.plist
- Check file size limits on backend

### Localization not working
- Verify `flutter_localizations` is added to dependencies
- Run `flutter pub get` again
- Hot restart the app (not just hot reload)

## Code Quality

- ✅ Type-safe models with freezed
- ✅ Null safety enabled
- ✅ Consistent error handling
- ✅ Provider-based state management
- ✅ Separation of concerns (models/services/providers/screens)
- ✅ Comprehensive API coverage
- ✅ Full localization support
- ✅ Material Design 3
- ✅ Responsive layouts

## License
Private

## Contributors
- Claude (Anthropic) - Full implementation
- Anders Kobberup - Product owner
