import 'package:vania/vania.dart';

class CreateItemTable extends Migration {
  @override
  Future<void> up() async {
    super.up();
    await createTableNotExists('item', () {
      id();
      timeStamps();
    });
  }

  @override
  Future<void> down() async {
    super.down();
    await dropIfExists('item');
  }
}
