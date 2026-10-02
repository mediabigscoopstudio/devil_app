class Profile {
  final int? id;
  final String? name;
  final String? bio;
  final String? birthDate;
  final String? gender;
  final String? preferredGender;
  final String? profilePhotoUrl;
  final bool isProfileComplete;

  Profile({
    this.id,
    this.name,
    this.bio,
    this.birthDate,
    this.gender,
    this.preferredGender,
    this.profilePhotoUrl,
    this.isProfileComplete = false,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      name: json['name'],
      bio: json['bio'],
      birthDate: json['birth_date'],
      gender: json['gender'],
      preferredGender: json['preferred_gender'],
      profilePhotoUrl: json['profile_photo'],
      isProfileComplete: json['is_profile_complete'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'bio': bio,
      'birth_date': birthDate,
      'gender': gender,
      'preferred_gender': preferredGender,
    };
  }
}
