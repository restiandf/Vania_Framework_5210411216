import 'package:vania/vania.dart';
import 'package:blog/app/http/controllers/product_controller.dart';
import 'package:blog/app/http/controllers/customers_controller.dart';
import 'package:blog/app/http/controllers/orders_controller.dart';
import 'package:blog/app/http/controllers/vendors_controller.dart';
import 'package:blog/app/http/controllers/orderitems_controller.dart';
import 'package:blog/app/http/controllers/produtcnotes_controller.dart';

class ApiRoute implements Route {
  @override
  void register() {
    // Router.basePrefix("/api");kalo pake ini error

    // Product

    Router.post("/api/product", productController.store);
    Router.get("/api/product", productController.show);
    Router.get("/api/product/{id}", productController.show);
    Router.put("/api/product/{id}", productController.update);
    Router.delete("/api/product/{id}", productController.destroy);

    // Customer

    Router.post("/api/customers", customersController.store);
    Router.get("/api/customers", customersController.index);
    Router.get("/api/customers/{id}", customersController.show);
    Router.put("/api/customers/{id}", customersController.update);
    Router.delete("/api/customers/{id}", customersController.destroy);

    // Order

    Router.post("/api/orders", ordersController.store);
    Router.get("/api/orders", ordersController.index);
    Router.get("/api/orders/{id}", ordersController.show);
    Router.put("/api/orders/{id}", ordersController.update);
    Router.delete("/api/orders/{id}", ordersController.destroy);

    // Vendors

    Router.post("/api/vendors", vendorsController.store);
    Router.get("/api/vendors", vendorsController.index);
    Router.get("/api/vendors/{id}", vendorsController.show);
    Router.put("/api/vendors/{id}", vendorsController.update);
    Router.delete("/api/vendors/{id}", vendorsController.destroy);

    // Orders Item

    Router.post("/api/ordersitem", orderitemsController.store);
    Router.get("/api/ordersitem", orderitemsController.index);
    Router.get("/api/ordersitem/{id}", orderitemsController.show);
    Router.put("/api/ordersitem/{id}", orderitemsController.update);
    Router.delete("/api/ordersitem/{id}", orderitemsController.destroy);

    // product notes
    Router.post("/api/productnotes", produtcnotesController.store);
    Router.get("/api/productnotes", produtcnotesController.index);
    Router.get("/api/productnotes/{id}", produtcnotesController.show);
    Router.put("/api/productnotes/{id}", produtcnotesController.update);
    Router.delete("/api/productnotes/{id}", produtcnotesController.destroy);
  }
}
