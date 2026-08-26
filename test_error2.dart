class RoleOrPermission {}
void main() {
  dynamic myFunc() {
    return <String>['a'];
  }
  
  try {
    List<RoleOrPermission> x = myFunc();
  } catch(e) {
    print(e.runtimeType);
    print(e.toString());
  }

  try {
    List<String> list = ['a'];
    List<RoleOrPermission> x = list as dynamic;
  } catch(e) {
    print(e.runtimeType);
    print(e.toString());
  }
}
