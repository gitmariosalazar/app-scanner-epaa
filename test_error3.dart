class RoleOrPermission {}
void main() {
  dynamic myFunc() {
    List<String> inner() => ['a'];
    return inner;
  }
  
  try {
    List<RoleOrPermission> Function() x = myFunc();
    x();
  } catch(e) {
    print(e.runtimeType);
    print(e.toString());
  }

  try {
    List<RoleOrPermission> x = [].map((e) => e as RoleOrPermission).toList();
  } catch (e) {}
}
