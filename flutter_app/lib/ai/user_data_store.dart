class UserData {
  String name;
  int age;
  String gender;
  double weight;
  double height;
  String goal;

  UserData({
    this.name = "User",
    this.age = 25,
    this.gender = "female",
    this.weight = 60,
    this.height = 170,
    this.goal = "maintain",
  });
}

class UserDataStore {
  static final UserDataStore _instance = UserDataStore._internal();
  factory UserDataStore() => _instance;
  UserDataStore._internal();

  final UserData data = UserData();

  void updateName(String name) => data.name = name;
  void updateAge(int age) => data.age = age;
  void updateGender(String gender) => data.gender = gender;
  void updateMeasurements(double weight, double height) {
    data.weight = weight;
    data.height = height;
  }
  void updateGoal(String goal) => data.goal = goal;
}
