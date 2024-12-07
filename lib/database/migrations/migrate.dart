import 'dart:io';
import 'package:vania/vania.dart';
import 'create_users_table.dart';
import 'create_product_table.dart';
import 'create_item_table.dart';

void main(List<String> args) async {
  await MigrationConnection().setup();
  if (args.isNotEmpty && args.first.toLowerCase() == "migrate:fresh") {
    await Migrate().dropTables();
  } else {
    await Migrate().registry();
  }
  await MigrationConnection().closeConnection();
  exit(0);
}

class Migrate {
  registry() async {
		 await CreateUserTable().up();
		 await CreateProductTable().up();
		 await CreateItemTable().up();
	}

  dropTables() async {
		 await CreateItemTable().down();
		 await CreateProductTable().down();
		 await CreateUserTable().down();
	 }
}
