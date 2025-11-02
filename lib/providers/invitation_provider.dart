import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/invitation.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

final invitationProvider = StateNotifierProvider<InvitationNotifier, AsyncValue<List<InvitationResponse>>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final authState = ref.watch(authProvider);

  // Set token on API service whenever auth state changes
  if (authState.user?.token != null) {
    apiService.setToken(authState.user!.token);
  }

  return InvitationNotifier(apiService);
});

class InvitationNotifier extends StateNotifier<AsyncValue<List<InvitationResponse>>> {
  final ApiService _apiService;

  InvitationNotifier(this._apiService) : super(const AsyncValue.loading()) {
    loadPendingInvitations();
  }

  Future<void> loadPendingInvitations() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _apiService.getMyPendingInvitations());
  }

  Future<void> loadAllInvitations() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _apiService.getMyInvitations());
  }

  Future<InvitationResponse?> createInvitation(CreateInvitationRequest request) async {
    try {
      final invitation = await _apiService.createInvitation(request);
      return invitation;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }

  Future<bool> acceptInvitation(int id) async {
    try {
      await _apiService.acceptInvitation(id);
      await loadPendingInvitations(); // Refresh the list
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> declineInvitation(int id) async {
    try {
      await _apiService.declineInvitation(id);
      await loadPendingInvitations(); // Refresh the list
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> cancelInvitation(int id) async {
    try {
      await _apiService.cancelInvitation(id);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }
}

// Provider for invitations for a specific task list
final taskListInvitationsProvider = FutureProvider.family<List<InvitationResponse>, int>((ref, taskListId) async {
  final apiService = ref.watch(apiServiceProvider);
  final authState = ref.watch(authProvider);

  // Ensure token is set
  if (authState.user?.token != null) {
    apiService.setToken(authState.user!.token);
  }

  return apiService.getInvitationsByTaskList(taskListId);
});
