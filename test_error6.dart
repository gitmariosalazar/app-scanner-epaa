class RoleOrPermission {}

class User {
  final List<RoleOrPermission> roles;
  User({required this.roles});
}

void main() {
  dynamic json = {'roles': <String>['a', 'b']};
  
  try {
    List<RoleOrPermission> roles = json['roles'] ?? [];
  } catch(e) {
    print(e.runtimeType);
    print(e.toString());
  }
}
