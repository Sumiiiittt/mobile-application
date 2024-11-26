abstract class Animal {
  void sound(); // Abstract method
}

class Dog extends Animal {
  @override
  void sound() {
    print("Dog barks");
  }
}

class Cat extends Animal {
  @override
  void sound() {
    print("Cat meows");
  }
}

void main() {
  Animal dog = Dog();
  Animal cat = Cat();

  dog.sound();
  cat.sound();
}
