class RoleOrPermission {}
void main() {
  dynamic data = <String>['admin', 'user'];
  
  try {
    List<RoleOrPermission> x = data as List<RoleOrPermission>;
  } catch(e) {
    print(e.runtimeType);
    print(e.toString());
  }
}
