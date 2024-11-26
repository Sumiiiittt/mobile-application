import 'package:dartz/dartz.dart';
void main(){
class Arithmetic
{
  final int first;
  final int second;

  Arithmetic (this.first, this.second);

  int sub()
  {
    return first - second;
  }

  Either<String, int> add()
{
  try{
    return Right(first + second);

  }catch(e)
  {
    return Left(e.toString());
  }
}

}

}
