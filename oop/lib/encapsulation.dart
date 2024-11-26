class Student {
  // Private properties
  String _name;
  int _age;

  // Constructor
  Student(this._name, this._age);

  // Getters
  String get name => _name;
  int get age => _age;

  // Setters
  set name(String name) {
    _name = name;
  }

  set age(int age) {
    if (age > 0) {
      _age = age;
    } else {
      print("Age must be positive.");
    }
  }
}

void main() {
  Student student = Student("Alice", 20);
  print("Student Name: ${student.name}");
  print("Student Age: ${student.age}");

  student.name = "Bob"; // Using setter
  student.age = 22; // Using setter
  print("Updated Name: ${student.name}");
  print("Updated Age: ${student.age}");
}
