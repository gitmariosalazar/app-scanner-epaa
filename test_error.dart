class RoleOrPermission {}
void main() {
  dynamic json = {'roles': <String>['a', 'b']};
  
  try {
    List<RoleOrPermission> roles = (json['roles'] as List<dynamic>?)
            ?.map((e) => RoleOrPermission())
            .toList() ??
        [];
    print(roles);
  } catch(e) {
    print(e.runtimeType);
    print(e.toString());
  }
}
