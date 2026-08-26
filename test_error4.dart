class RoleOrPermission {}
void main() {
  dynamic myFunc() {
    return (List<String> x) => x;
  }
  
  try {
    List<RoleOrPermission> Function(List<RoleOrPermission>) x = myFunc();
  } catch(e) {
    print(e.runtimeType);
    print(e.toString());
  }
}
