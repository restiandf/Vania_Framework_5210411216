import 'package:vania/vania.dart';
import 'package:blog/app/models/vendors.dart';
import 'package:vania/src/exception/validation_exception.dart';

class VendorsController extends Controller {
  List<Map<String, dynamic>> vendors = [];
  Future<Response> index() async {
    // Mengambil data pelanggan dari basis data
    final vendorsList =
        await Vendors().query().get(); // Ambil data dari database
    return Response.json(vendorsList);
  }

  Future<Response> create() async {
    return Response.json({});
  }

  Future<Response> store(Request request) async {
    try {
      // Validasi input
      request.validate({
        'vend_name': 'required|string|max_length:50',
        'vend_address': 'required|string',
        'vend_city': 'required|string',
        'vend_state': 'required|string|max_length:5',
        'vend_zip': 'required|string|max_length:7',
        'vend_country': 'required|string|max_length:25'
      }, {
        'vend_name.required': 'Nama vendor wajib diisi',
        'vend_name.string': 'Nama vendor harus berupa teks',
        'vend_name.max_length': 'Nama vendor maksimal 50 karakter',
        'vend_address.required': 'Alamat vendor wajib diisi',
        'vend_address.string': 'Alamat vendor harus berupa teks',
        'vend_city.required': 'Kota vendor wajib diisi',
        'vend_city.string': 'Kota vendor harus berupa teks',
        'vend_state.required': 'Provinsi vendor wajib diisi',
        'vend_state.string': 'Provinsi vendor harus berupa teks',
        'vend_state.max_length': 'Provinsi vendor maksimal 5 karakter',
        'vend_zip.required': 'Kode pos vendor wajib diisi',
        'vend_zip.string': 'Kode pos vendor harus berupa teks',
        'vend_zip.max_length': 'Kode pos vendor maksimal 7 karakter',
        'vend_country.required': 'Negara vendor wajib diisi',
        'vend_country.string': 'Negara vendor harus berupa teks',
        'vend_country.max_length': 'Negara vendor maksimal 25 karakter'
      });

      var vendorsData = request.input();

      // Cek Vendors yang sudah ada
      final existingVendors = await Vendors()
          .query()
          .where('vend_name', '=', vendorsData['vend_name'])
          .first();

      if (existingVendors != null) {
        return Response.json(
            {'message': 'Vendors dengan nama ini sudah ada.'}, 409);
      }

      // Generate vend_id
      vendorsData['vend_id'] = vendors.length + 1; // Menetapkan ID pelanggan

      // Menambahkan pelanggan ke daftar
      vendors.add(vendorsData);

      await Vendors().query().insert(vendorsData);

      return Response.json(
          {'message': 'Vendors berhasil ditambahkan.', 'data': vendorsData},
          201);
    } catch (e) {
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

  Future<Response> show([int? id]) async {
    try {
      if (id != null) {
        // Jika ada ID, ambil produk spesifik
        final vendors =
            await Vendors().query().where('vend_id', '=', id).first();

        if (vendors == null) {
          return Response.json({
            'message': 'Produk dengan ID $id tidak ditemukan.',
          }, 404);
        }

        return Response.json({
          'message': 'Detail produk.',
          'data': vendors,
        }, 200);
      }

      // Jika tidak ada ID, ambil semua produk
      final listVendors = await Vendors().query().get();
      return Response.json({
        'message': 'Daftar produk.',
        'data': listVendors,
      }, 200);
    } catch (e) {
      return Response.json({
        'message': 'Terjadi kesalahan saat mengambil data produk.',
        'error': e.toString(),
      }, 500);
    }
  }

  Future<Response> edit(int id) async {
    return Response.json({});
  }

  Future<Response> update(Request request, int id) async {
    try {
      // Validasi input
      request.validate({
        'vend_name': 'required|string|max_length:50',
        'vend_address': 'required|string',
        'vend_city': 'required|string',
        'vend_state': 'required|string|max_length:5',
        'vend_zip': 'required|string|max_length:7',
        'vend_country': 'required|string|max_length:25'
      }, {
        'vend_name.required': 'Nama vendor wajib diisi',
        'vend_name.string': 'Nama vendor harus berupa teks',
        'vend_name.max_length': 'Nama vendor maksimal 50 karakter',
        'vend_address.required': 'Alamat vendor wajib diisi',
        'vend_address.string': 'Alamat vendor harus berupa teks',
        'vend_city.required': 'Kota vendor wajib diisi',
        'vend_city.string': 'Kota vendor harus berupa teks',
        'vend_state.required': 'Provinsi vendor wajib diisi',
        'vend_state.string': 'Provinsi vendor harus berupa teks',
        'vend_state.max_length': 'Provinsi vendor maksimal 5 karakter',
        'vend_zip.required': 'Kode pos vendor wajib diisi',
        'vend_zip.string': 'Kode pos vendor harus berupa teks',
        'vend_zip.max_length': 'Kode pos vendor maksimal 7 karakter',
        'vend_country.required': 'Negara vendor wajib diisi',
        'vend_country.string': 'Negara vendor harus berupa teks',
        'vend_country.max_length': 'Negara vendor maksimal 25 karakter'
      });

      // Ambil input data vendor yang akan diupdate
      final vendorsData = request.input();

      // Cek apakah vendor ada
      final vendor = await Vendors().query().where('vend_id', '=', id).first();

      if (vendor == null) {
        return Response.json({
          'message': 'Vendor dengan ID $id tidak ditemukan.',
        }, 404); // HTTP Status Code 404 Not Found
      }

      // Update data vendor
      await Vendors().query().where('vend_id', '=', id).update({
        'vend_name': vendorsData['vend_name'],
        'vend_address': vendorsData['vend_address'],
        'vend_city': vendorsData['vend_city'],
        'vend_state': vendorsData['vend_state'],
        'vend_zip': vendorsData['vend_zip'],
        'vend_country': vendorsData['vend_country']
      });

      // Mengembalikan response sukses dengan status 200 OK
      return Response.json({
        'message': 'Vendor berhasil diperbarui.',
        'data': vendorsData, // menampilkan data vendor yang diupdate
      }, 200);
    } catch (e) {
      // Menangani kesalahan validasi
      if (e is ValidationException) {
        final errorMessages = e.message;
        return Response.json({
          'errors': errorMessages,
        }, 400); // HTTP Status Code 400 Bad Request
      }

      // Menangani kesalahan tak terduga
      return Response.json({
        'message': 'Terjadi kesalahan di sisi server. Harap coba lagi nanti.',
        'error': e.toString(),
      }, 500); // HTTP Status Code 500 Server Error
    }
  }

  Future<Response> destroy(int id) async {
    try {
      // Cari produk berdasarkan ID
      final vendors = await Vendors().query().where('vend_id', '=', id).first();

      if (vendors == null) {
        return Response.json({
          'message': 'Produk dengan ID $id tidak ditemukan.',
        }, 404);
      }

      // Hapus produk
      await Vendors().query().where('vend_id', '=', id).delete();

      return Response.json({
        'message': 'Produk berhasil dihapus.',
      }, 200);
    } catch (e) {
      return Response.json({
        'message': 'Terjadi kesalahan saat menghapus produk.',
        'error': e.toString(),
      }, 500);
    }
  }
}

final VendorsController vendorsController = VendorsController();
