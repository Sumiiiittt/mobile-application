class Vehicle {
  void start() {
    print("Vehicle is starting");
  }
}

class Car extends Vehicle {
  void honk() {
    print("Car is honking");
  }
}

void main() {
  Car myCar = Car();
  myCar.start(); // Inherited from Vehicle
  myCar.honk(); // Specific to Car
}
