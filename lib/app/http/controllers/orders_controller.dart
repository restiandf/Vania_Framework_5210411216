import 'package:vania/vania.dart';
import 'package:blog/app/models/orders.dart';
import 'package:blog/app/models/orderitems.dart';
import 'package:blog/app/models/customers.dart';
import 'package:vania/src/exception/validation_exception.dart';

class OrdersController extends Controller {
  Future<Response> index() async {
    try {
      // Mengambil semua data dari tabel Orders
      final orders = await Orders()
          .query()
          .select(['order_num', 'order_date', 'cust_id']).get();

      if (orders.isNotEmpty) {
        return Response.json({
          'message': 'Data berhasil di-fetch',
          'total': orders.length,
          'data': orders,
        });
      } else {
        return Response.json({
          'message': 'Data tidak ditemukan',
          'total': 0,
        }, 404);
      }
    } catch (e) {
      return Response.json({
        'message': 'Terjadi kesalahan: ${e.toString()}',
      }, 500);
    }
  }

  Future<Response> store(Request request) async {
    try {
      // Validasi input untuk memastikan tidak kosong
      request.validate({
        'order_date': 'required|date', // Ensure the date format is valid
        'cust_id': 'required',
      }, {
        'order_date.required': 'Tanggal order wajib diisi',
        'order_date.date':
            'Format tanggal tidak valid', // Added date validation message
        'cust_id.required': 'ID pelanggan wajib diisi',
      });

      final orderData = request.input();

      // Pastikan cust_id adalah integer
      final int cust_id = int.tryParse(orderData['cust_id'].toString()) ?? -1;

      // Cek keberadaan pelanggan berdasarkan cust_id
      final customerCount = await Customers()
          .query()
          .where('cust_id', '=', cust_id) // Use custId as an integer
          .count();

      if (customerCount == 0) {
        return Response.json({
          'message': 'Pelanggan dengan ID tersebut tidak ditemukan.',
        }, 404);
      }

      // Generate order_num jika tidak ada
      final lastOrder = await Orders()
          .query()
          .select(['order_num'])
          .orderBy('order_num', 'desc')
          .first();

      final newOrderNum = lastOrder == null
          ? 1
          : (int.parse(lastOrder['order_num'].toString()) + 1);

      // Pastikan order_num tetap integer
      orderData['order_num'] = newOrderNum;

      // Simpan data order ke database
      final insertedOrder = await Orders().query().insert(orderData);

      return Response.json({
        'message': 'Order berhasil ditambahkan.',
        'data': insertedOrder,
      }, 201);
    } catch (e) {
      if (e is ValidationException) {
        return Response.json({
          'errors': e.message,
        }, 400);
      } else {
        return Response.json({
          'message': 'Terjadi kesalahan di sisi server. Harap coba lagi nanti.',
          'error': e.toString(),
        }, 500);
      }
    }
  }

  Future<Response> show(int id) async {
    try {
      // Ambil data order berdasarkan ID
      final order = await Orders()
          .query()
          .join('customers', 'customers.cust_id', '=', 'orders.cust_id')
          .select([
            'orders.order_num', // Specify the table for order_num
            'orders.order_date', // Specify the table for order_date
            'orders.cust_id', // Specify the table for cust_id
            'customers.cust_name' // Specify the table for cust_name
          ])
          .where('orders.order_num', '=', id) // Use id directly as an integer
          .first();

      if (order == null) {
        return Response.json({
          'message': 'Order tidak ditemukan.',
        }, 404);
      }

      return Response.json({
        'message': 'Data berhasil ditemukan.',
        'data': order,
      });
    } catch (e) {
      return Response.json({
        'message': 'Terjadi kesalahan: ${e.toString()}',
      }, 500);
    }
  }

  Future<Response> update(Request request, int id) async {
    try {
      // Validasi input untuk memastikan tidak kosong
      request.validate({
        'order_date': 'required|date',
        'cust_id': 'required|integer',
      }, {
        'order_date.required': 'Tanggal order wajib diisi',
        'order_date.date': 'Format tanggal tidak valid',
        'cust_id.required': 'ID pelanggan wajib diisi',
        'cust_id.integer': 'ID pelanggan harus berupa angka',
      });

      // Construct order data from request input
      final Map<String, dynamic> orderData = {
        'order_date': request.input('order_date'),
        'cust_id': request.input('cust_id'),
      };

      // Cek apakah ada customer dengan cust_id yang valid
      final customerId =
          orderData['cust_id'].toString(); // Ensure cust_id is a String
      final customerExists =
          await Customers().query().where('cust_id', customerId).first();

      if (customerExists == null) {
        return Response.json({
          'message': 'Pelanggan dengan ID tersebut tidak ditemukan.',
        }, 404);
      }

      // Cek apakah order dengan id tersebut ada
      final existingOrder = await Orders()
          .query()
          .where('order_num', '=', id) // Convert id to String
          .first();

      if (existingOrder == null) {
        return Response.json({
          'message': 'Order dengan nomor $id tidak ditemukan.',
        }, 404);
      }

      // Update data order
      await Orders()
          .query()
          .where('order_num', '=', id) // Convert id to String
          .update(orderData);

      // Ambil data yang sudah diupdate
      final updatedOrder = await Orders()
          .query()
          .where('order_num', '=', id) // Convert id to String
          .first();

      return Response.json({
        'message': 'Data order berhasil diperbarui.',
        'data': updatedOrder,
      }, 200);
    } catch (e) {
      print('Error: $e');
      if (e is ValidationException) {
        final errorMessages = e.message;
        return Response.json({'errors': errorMessages}, 400);
      } else {
        return Response.json({
          'message': 'Terjadi kesalahan di sisi server. Harap coba lagi nanti.',
          'error': e.toString(),
        }, 500);
      }
    }
  }

  Future<Response> destroy(int id) async {
    try {
      // Hapus data order berdasarkan ID
      final deletedCount = await Orders()
          .query()
          .where('order_num', '=', id) // Konversi id menjadi String
          .delete();

      if (deletedCount == 0) {
        return Response.json({
          'message': 'Order tidak ditemukan atau sudah dihapus.',
        }, 404);
      }

      return Response.json({
        'message': 'Order berhasil dihapus.',
      });
    } catch (e) {
      return Response.json({
        'message': 'Terjadi kesalahan: ${e.toString()}',
      }, 500);
    }
  }
}

final OrdersController ordersController = OrdersController();
