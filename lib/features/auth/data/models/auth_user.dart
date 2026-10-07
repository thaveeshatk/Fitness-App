/// Simple user session model representing an authenticated user.
class AuthUser {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;

  const AuthUser({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
  });

  factory AuthUser.mockDefault() {
    return const AuthUser(
      uid: 'user_alex_01',
      name: 'Alex',
      email: 'alex@example.com',
      photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=150&auto=format&fit=crop',
    );
  }

  AuthUser copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
  }) {
    return AuthUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
