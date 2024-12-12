import 'package:vania/vania.dart';
import 'package:blog/app/models/customers.dart';
import 'package:vania/src/exception/validation_exception.dart';

class CustomersController extends Controller {
  List<Map<String, dynamic>> customers = [];

  Future<Response> index() async {
    final customerList = await Customers().query().get();
    return Response.json(customerList);
  }

  Future<Response> create() async {
    try {
      final emptyCustomer = {
        'cust_id': null,
        'cust_name': '',
        'cust_address': '',
        'cust_city': '',
        'cust_state': '',
        'cust_zip': '',
        'cust_country': '',
        'cust_telp': ''
      };

      return Response.json(emptyCustomer);
    } catch (e) {
      return Response.json({
        'message': 'Terjadi kesalahan di sisi server. Harap coba lagi nanti.',
        'error': e.toString()
      }, 500);
    }
  }

  Future<Response> store(Request request) async {
    try {
      // Validasi input untuk memastikan tidak kosong
      request.validate({
        'cust_name': 'required',
        'cust_address': 'required',
        'cust_city': 'required',
        'cust_state': 'required',
        'cust_zip': 'required',
        'cust_country': 'required',
        'cust_telp': 'required'
      }, {
        'cust_name.required': 'Nama pelanggan wajib diisi',
        'cust_address.required': 'Alamat pelanggan wajib diisi',
        'cust_city.required': 'Kota pelanggan wajib diisi',
        'cust_state.required': 'Provinsi pelanggan wajib diisi',
        'cust_zip.required': 'Kode pos pelanggan wajib diisi',
        'cust_country.required': 'Negara pelanggan wajib diisi',
        'cust_telp.required': 'Telepon pelanggan wajib diisi'
      });

      final customerData = request.input();

      // Cek pelanggan yang sudah ada
      final existingCustomer = customers.firstWhere(
          (c) => c['cust_name'] == customerData['cust_name'],
          orElse: () => {});

      if (existingCustomer.isNotEmpty) {
        return Response.json(
            {'message': 'Pelanggan dengan nama ini sudah ada.'}, 409);
      }

      customerData['cust_id'] = customers.length + 1; // Menetapkan ID pelanggan

      // Menambahkan pelanggan ke daftar
      customers.add(customerData);

      // Menyimpan pelanggan ke basis data
      await Customers().query().insert(customerData);

      return Response.json(
          {'message': 'Pelanggan berhasil ditambahkan.', 'data': customerData},
          201);
    } catch (e) {
      print('Error: $e');
      if (e is ValidationException) {
        final errorMessages = e.message;
        return Response.json({'errors': errorMessages}, 400);
      } else {
        return Response.json({
          'message': 'Terjadi kesalahan di sisi server. Harap coba lagi nanti.'
        }, 500);
      }
    }
  }

  Future<Response> show(int id) async {
    // Ambil data pelanggan berdasarkan id dari basis data
    final customer = await Customers()
        .query()
        .where('cust_id', '=', id) // Menggunakan id untuk mencari
        .first();
    if (customer == null) {
      throw Exception('Pelanggan tidak ditemukan');
    }
    return Response.json(customer);
  }

  Future<Response> edit(int id) async {
    try {
      // Ambil data pelanggan berdasarkan id dari basis data
      final customer =
          await Customers().query().where('cust_id', '=', id).first();

      if (customer == null) {
        return Response.json(
            {'message': 'Customer dengan ID $id tidak ditemukan.'}, 404);
      }

      return Response.json(customer);
    } catch (e) {
      return Response.json({
        'message': 'Terjadi kesalahan di sisi server. Harap coba lagi nanti.',
        'error': e.toString()
      }, 500);
    }
  }

  Future<Response> update(Request request, int id) async {
    try {
      // Validasi input untuk memastikan tidak kosong
      request.validate({
        'cust_name': 'required',
        'cust_address': 'required',
        'cust_city': 'required',
        'cust_state': 'required',
        'cust_zip': 'required',
        'cust_country': 'required',
        'cust_telp': 'required'
      }, {
        'cust_name.required': 'Nama pelanggan wajib diisi',
        'cust_address.required': 'Alamat pelanggan wajib diisi',
        'cust_city.required': 'Kota pelanggan wajib diisi',
        'cust_state.required': 'Provinsi pelanggan wajib diisi',
        'cust_zip.required': 'Kode pos pelanggan wajib diisi',
        'cust_country.required': 'Negara pelanggan wajib diisi',
        'cust_telp.required': 'Telepon pelanggan wajib diisi'
      });

      final Map<String, dynamic> customerData = {
        'cust_name': request.input('cust_name'),
        'cust_address': request.input('cust_address'),
        'cust_city': request.input('cust_city'),
        'cust_state': request.input('cust_state'),
        'cust_zip': request.input('cust_zip'),
        'cust_country': request.input('cust_country'),
        'cust_telp': request.input('cust_telp')
      };

      // Cek apakah customer dengan id tersebut ada
      final existingCustomer =
          await Customers().query().where('cust_id', '=', id).first();

      if (existingCustomer == null) {
        return Response.json(
            {'message': 'Customer dengan ID $id tidak ditemukan.'}, 404);
      }

      // Cek apakah ada customer lain dengan nama yang sama (selain customer yang sedang diupdate)
      final duplicateCustomer = await Customers()
          .query()
          .where('cust_name', '=', customerData['cust_name'])
          .where('cust_id', '!=', id)
          .first();

      if (duplicateCustomer != null) {
        return Response.json(
            {'message': 'Pelanggan dengan nama ini sudah ada.'}, 409);
      }

      // Update data customer
      await Customers().query().where('cust_id', '=', id).update(customerData);

      // Ambil data yang sudah diupdate
      final updatedCustomer =
          await Customers().query().where('cust_id', '=', id).first();

      return Response.json({
        'message': 'Data customer berhasil diperbarui.',
        'data': updatedCustomer
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
      // Cari Customer berdasarkan ID
      final customers =
          await Customers().query().where('cust_id', '=', id).first();

      if (customers == null) {
        return Response.json({
          'message': 'Customer dengan ID $id tidak ditemukan.',
        }, 404);
      }

      // Hapus Customer
      await Customers().query().where('cust_id', '=', id).delete();

      return Response.json({
        'message': 'Customer dengan ID $id telah berhasil dihapus.',
      }, 200);
    } catch (e) {
      return Response.json({
        'message': 'Terjadi kesalahan saat menghapus Customer.',
        'error': e.toString(),
      }, 500);
    }
  }
}

final CustomersController customersController = CustomersController();
