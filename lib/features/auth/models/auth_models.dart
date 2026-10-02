class AuthUser {
  final String id;
  final String? phoneNumber;
  final String? email;
  final bool isVerified;
  final String status;

  AuthUser({
    required this.id,
    this.phoneNumber,
    this.email,
    required this.isVerified,
    required this.status,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      phoneNumber: json['phone_number'] as String?,
      email: json['email'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      status: json['status'] as String? ?? 'ACTIVE',
    );
  }
}

class AccountState {
  final bool requiresOnboarding;
  final bool profileCompleted;

  AccountState({
    required this.requiresOnboarding,
    required this.profileCompleted,
  });

  factory AccountState.fromJson(Map<String, dynamic> json) {
    return AccountState(
      requiresOnboarding: json['requires_onboarding'] as bool? ?? true,
      profileCompleted: json['profile_completed'] as bool? ?? false,
    );
  }
}

class AuthMeResponse {
  final AuthUser user;
  final AccountState account;

  AuthMeResponse({
    required this.user,
    required this.account,
  });

  factory AuthMeResponse.fromJson(Map<String, dynamic> json) {
    return AuthMeResponse(
      user: AuthUser.fromJson(json['user']),
      account: AccountState.fromJson(json['account']),
    );
  }
}
