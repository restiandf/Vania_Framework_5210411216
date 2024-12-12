import 'package:vania/vania.dart';
import 'package:blog/app/models/orderitems.dart';
import 'package:blog/app/models/orders.dart';
import 'package:blog/app/models/product.dart';
import 'package:vania/src/exception/validation_exception.dart';

class OrderitemsController extends Controller {
  List<Map<String, dynamic>> orderItems = [];

  Future<Response> index() async {
    final orderList = await Orderitems().query().get();
    return Response.json(orderList);
  }

  Future<Response> create() async {
    return Response.json({});
  }

  Future<Response> store(Request request) async {
    try {
      // Validate input
      request.validate({
        'order_num': 'required',
        'prod_id': 'required',
        'quantity': 'required|integer|min:1',
        'size': 'required|integer|min:1'
      }, {
        'order_num.required': 'Nomor pesanan wajib diisi',
        'prod_id.required': 'ID produk wajib diisi',
        'quantity.required': 'Jumlah produk wajib diisi',
        'quantity.integer': 'Jumlah produk harus berupa angka',
        'quantity.min': 'Jumlah produk minimal 1',
        'size.required': 'Ukuran produk wajib diisi',
        'size.integer': 'Ukuran harus berupa angka',
        'size.min': 'Ukuran produk minimal 1'
      });

      final orderItemData = request.input();

      // Check if the order and product exist
      final orderExists = await Orders()
              .query()
              .where('order_num', orderItemData['order_num'])
              .count() >
          0;

      final productExists = await Product()
              .query()
              .where('prod_id', orderItemData['prod_id'])
              .count() >
          0;

      if (!orderExists) {
        return Response.json({
          'message': 'Nomor pesanan tidak ditemukan.',
        }, 404);
      }

      if (!productExists) {
        return Response.json({'message': 'ID produk tidak ditemukan.'}, 404);
      }

      orderItemData['order_item'] =
          orderItems.length + 1; // Menetapkan ID pelanggan

      // Menambahkan pelanggan ke daftar
      orderItems.add(orderItemData);

      // Insert order item into the table
      final orderItemId = await Orderitems().query().insert(orderItemData);

      orderItemData['order_item'] =
          orderItemId; // Add order item ID to response

      return Response.json({
        'message': 'Order item berhasil ditambahkan.',
        'data': orderItemData
      }, 200);
    } catch (e) {
      print('Error: $e');
      if (e is ValidationException) {
        final errorMessages = e.message;
        return Response.json({'errors': errorMessages}, 400);
      } else {
        return Response.json({
          'message': 'Terjadi kesalahan di sisi server. Harap coba lagi nanti.',
          'error': e.toString()
        }, 500);
      }
    }
  }

  Future<Response> show(int id) async {
    // Ambil data pelanggan berdasarkan id dari basis data
    final orderitems = await Orderitems()
        .query()
        .where('order_item', '=', id) // Menggunakan id untuk mencari
        .first();
    if (orderitems == null) {
      throw Exception('Pelanggan tidak ditemukan');
    }
    return Response.json(orderitems);
  }

  Future<Response> update(Request request, int id) async {
    try {
      // Validate input
      request.validate({
        'order_num': 'required',
        'prod_id': 'required',
        'quantity': 'required|integer|min:1',
        'size': 'required|integer|min:1',
      }, {
        'order_num.required': 'Nomor pesanan wajib diisi',
        'prod_id.required': 'ID produk wajib diisi',
        'quantity.required': 'Jumlah produk wajib diisi',
        'quantity.integer': 'Jumlah produk harus berupa angka',
        'quantity.min': 'Jumlah produk minimal 1',
        'size.required': 'Ukuran produk wajib diisi',
        'size.integer': 'Ukuran harus berupa angka',
        'size.min': 'Ukuran produk minimal 1',
      });

      final orderItemData = request.input();

      // Check if the order item exists
      final existingOrderItem =
          await Orderitems().query().where('order_item', '=', id).first();

      if (existingOrderItem == null) {
        return Response.json({
          'message': 'Item pesanan tidak ditemukan.',
        }, 404);
      }

      // Check if the order and product exist
      final orderExists = await Orders()
              .query()
              .where('order_num', orderItemData['order_num'])
              .count() >
          0;

      final productExists = await Product()
              .query()
              .where('prod_id', orderItemData['prod_id'])
              .count() >
          0;

      if (!orderExists) {
        return Response.json({
          'message': 'Nomor pesanan tidak ditemukan.',
        }, 404);
      }

      if (!productExists) {
        return Response.json({'message': 'ID produk tidak ditemukan.'}, 404);
      }

      // Remove `order_item` from data if exists
      orderItemData.remove('order_item');

      // Update the order item data
      await Orderitems().query().where('order_item', '=', id).update({
        'order_num': orderItemData['order_num'],
        'prod_id': orderItemData['prod_id'],
        'quantity': orderItemData['quantity'],
        'size': orderItemData['size'],
      });

      return Response.json({
        'message': 'Order item berhasil diperbarui.',
        'data': orderItemData,
      }, 200);
    } catch (e) {
      print('Error: $e');
      if (e is ValidationException) {
        final errorMessages = e.message;
        return Response.json({'errors': errorMessages}, 400);
      } else {
        return Response.json({
          'message': 'Terjadi kesalahan di sisi server. Harap coba lagi nanti.',
          'error': e.toString()
        }, 500);
      }
    }
  }

  Future<Response> destroy(int id) async {
    try {
      // Periksa apakah item dengan ID tersebut ada
      final existingOrderItem =
          await Orderitems().query().where('order_item', '=', id).first();

      if (existingOrderItem == null) {
        return Response.json({
          'message': 'Item pesanan tidak ditemukan.',
        }, 404);
      }

      // Hapus item berdasarkan ID
      await Orderitems().query().where('order_item', '=', id).delete();

      return Response.json({
        'message': 'Item pesanan berhasil dihapus.',
      }, 200);
    } catch (e) {
      print('Error: $e');
      return Response.json({
        'message': 'Terjadi kesalahan di sisi server.',
        'error': e.toString()
      }, 500);
    }
  }
}

final OrderitemsController orderitemsController = OrderitemsController();
