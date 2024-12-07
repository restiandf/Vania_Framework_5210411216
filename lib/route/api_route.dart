import 'package:vania/vania.dart';
import 'package:blog/app/http/controllers/product_controller.dart';

class ApiRoute implements Route {
  @override
  void register() {
    // Router.basePrefix("/api");kalo pake ini error

    Router.post("/api/product", productController.store);
    Router.get("/api/product", productController.show);
    Router.get("/api/product/{id}", productController.show);
    Router.put("/api/product/{id}", productController.update);
    Router.delete("/api/product/{id}", productController.destroy);
  }
}
