// hello world

void main(List<String> arguments) {   
    var cad = '''

        Hello world
        
    ''';
  // print args
    print(cad);

  var myUser = User('John Doe', 30);
  myUser.age = 31;

}

class User {
  String _name;
  int _age;

  User(this._name, this._age);

  void showInfo() {
    print('Name: $_name, Age: $_age');
  }

  get name => _name;

  set name(String name) => _name = name;

  get age => _age;

  set age(int age) => _age = age;
}

// var fig = Figura('Figura genérica'); // Error: no se puede instanciar una clase abstracta