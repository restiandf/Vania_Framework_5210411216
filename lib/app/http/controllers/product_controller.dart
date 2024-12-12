import 'package:vania/vania.dart';
import 'package:blog/app/models/product.dart';
import 'package:vania/src/exception/validation_exception.dart';

class ProductController extends Controller {
  List<Map<String, dynamic>> product = [];

  Future<Response> index() async {
    return Response.json({'message': 'Hello World'});
  }

  Future<Response> create(Request request) async {
    try {
      // Tambahkan validasi
      request.validate({
        'vend_id': 'required',
        'prod_name': 'required',
        'prod_price': 'required',
        'prod_desc': 'required',
      }, {
        'vend_id.required': 'Vendor tidak boleh kosong',
        'prod_name.required': 'Nama produk tidak boleh kosong',
        'prod_price.required': 'Price tidak boleh kosong',
        'prod_desc.required': 'Deskripsi tidak boleh kosong',
      });

      final requestData = request.input();
      return Response.json({
        "message": "Product berhasil ditambahkan",
        "data": requestData,
      }, 201);
    } catch (e) {
      return Response.json(
        {
          'message': "Error terjadi pada server, silahkan coba lagi",
        },
        500,
      );
    }
  }

  Future<Response> store(Request request) async {
    try {
      // Validasi input
      request.validate({
        'vend_id': 'required|string|max_length:5',
        'prod_name': 'required|string|max_length:25',
        'prod_price': 'required|numeric|min:0',
        'prod_desc': 'required|string'
      }, {
        'vend_id.required': 'ID vendor wajib diisi',
        'vend_id.string': 'ID vendor harus berupa teks',
        'vend_id.max_length': 'ID vendor maksimal 5 karakter',
        'prod_name.required': 'Nama produk wajib diisi',
        'prod_name.string': 'Nama produk harus berupa teks',
        'prod_name.max_length': 'Nama produk maksimal 25 karakter',
        'prod_price.required': 'Harga produk wajib diisi',
        'prod_price.numeric': 'Harga produk harus berupa angka',
        'prod_price.min': 'Harga produk tidak boleh kurang dari 0',
        'prod_desc.required': 'Deskripsi produk wajib diisi',
        'prod_desc.string': 'Deskripsi produk harus berupa teks'
      });

      final productData = request.input();

      // Cek produk yang sudah ada
      final existingProduct = await Product()
          .query()
          .where('prod_name', '=', productData['prod_name'])
          .first();

      if (existingProduct != null) {
        return Response.json(
            {'message': 'Produk dengan nama ini sudah ada.'}, 409);
      }

      productData['prod_id'] = product.length + 1;

      product.add(productData);
      await Product().query().insert(productData);

      return Response.json(
          {'message': 'Produk berhasil ditambahkan.', 'data': productData},
          201);
    } catch (e) {
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

  Future<Response> show([int? id]) async {
    try {
      if (id != null) {
        // Jika ada ID, ambil produk spesifik
        final product =
            await Product().query().where('prod_id', '=', id).first();

        if (product == null) {
          return Response.json({
            'message': 'Produk dengan ID $id tidak ditemukan.',
          }, 404);
        }

        return Response.json({
          'message': 'Detail produk.',
          'data': product,
        }, 200);
      }

      // Jika tidak ada ID, ambil semua produk
      final listProduct = await Product().query().get();
      return Response.json({
        'message': 'Daftar produk.',
        'data': listProduct,
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
        'vend_id': 'required|string|max_length:5',
        'prod_name': 'required|string|max_length:25',
        'prod_price': 'required|numeric|min:0',
        'prod_desc': 'required|string'
      }, {
        'vend_id.required': 'ID vendor wajib diisi',
        'vend_id.string': 'ID vendor harus berupa teks',
        'vend_id.max_length': 'ID vendor maksimal 5 karakter',
        'prod_name.required': 'Nama produk wajib diisi',
        'prod_name.string': 'Nama produk harus berupa teks',
        'prod_name.max_length': 'Nama produk maksimal 25 karakter',
        'prod_price.required': 'Harga produk wajib diisi',
        'prod_price.numeric': 'Harga produk harus berupa angka',
        'prod_price.min': 'Harga produk tidak boleh kurang dari 0',
        'prod_desc.required': 'Deskripsi produk wajib diisi',
        'prod_desc.string': 'Deskripsi produk harus berupa teks'
      });

      // Ambil input data produk yang akan diupdate
      final productData =
          request.only(['vend_id', 'prod_name', 'prod_price', 'prod_desc']);

      final product = await Product().query().where('prod_id', '=', id).first();

      if (product == null) {
        return Response.json({
          'message': 'Produk dengan ID $id tidak ditemukan.',
        }, 404); // HTTP Status Code 404 Not Found
      }

      // Update data produk
      await Product().query().where('prod_id', '=', id).update(productData);

      // Mengembalikan response sukses dengan status 200 OK
      return Response.json({
        'message': 'Produk berhasil diperbarui.',
        'data': productData, // menampilkan data produk yang diupdate
      }, 200);
    } catch (e) {
      if (e is ValidationException) {
        // Menangani kesalahan validasi
        final errorMessages = e.message;
        return Response.json({
          'errors': errorMessages,
        }, 400); // HTTP Status Code 400 Bad Request
      } else {
        // Menangani kesalahan tak terduga
        return Response.json({
          'message': 'Terjadi kesalahan di sisi server. Harap coba lagi nanti.',
          'error': e.toString(),
        }, 500); // HTTP Status Code 500 Server Error
      }
    }
  }

  Future<Response> destroy(int id) async {
    try {
      // Cari produk berdasarkan ID
      final product = await Product().query().where('prod_id', '=', id).first();

      if (product == null) {
        return Response.json({
          'message': 'Produk dengan ID $id tidak ditemukan.',
        }, 404);
      }

      // Hapus produk
      await Product().query().where('prod_id', '=', id).delete();

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

final ProductController productController = ProductController();
