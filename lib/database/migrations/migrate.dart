import 'dart:io';
import 'package:vania/vania.dart';
import '1_customers_table.dart';
import '2_orders_table.dart';
import '3_vendors_table.dart';
import '4_product_table.dart';
import '6_productnotes_table.dart';
import '5_orderitems_table.dart';

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
    await CreateCustomersTable().up(); // Customers
    await CreateVendorsTable().up(); // Vendors
    await CreateProductTable().up(); // Products
    await CreateOrdersTable().up(); // Orders
    await CreateOrderitemsTable().up(); // OrderItems
    await CreateProductnotesTable().up(); // ProductNotes
  }

  dropTables() async {
    await CreateProductnotesTable().down();
    await CreateOrderitemsTable().down();
    await CreateOrdersTable().down();
    await CreateProductTable().down();
    await CreateVendorsTable().down();
    await CreateCustomersTable().down();
  }
}
