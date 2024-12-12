import 'package:vania/vania.dart';
import 'package:blog/app/models/produtcnotes.dart';
import 'package:blog/app/models/product.dart';
import 'package:vania/src/exception/validation_exception.dart';

class ProdutcnotesController extends Controller {
  List<Map<String, dynamic>> product_notes = [];
  Future<Response> index() async {
    try {
      // Fetch all notes
      final notes = await Produtcnotes().query().first();
      return Response.json({
        'message': 'Data berhasil di-fetch',
        'data': notes,
      });
    } catch (e) {
      print('Error: $e');
      return Response.json({
        'message': 'Error fetching data',
        'error': e.toString(),
      }, 500);
    }
  }

  Future<Response> create() async {
    return Response.json({
      'message': 'Provide data to create a new note',
    });
  }

  Future<Response> store(Request request) async {
    try {
      // Validasi input untuk detail produk
      request.validate({
        'prod_id': 'required', // Pastikan ID produk diberikan
        'note_date':
            'required|date', // Pastikan tanggal catatan diberikan dan valid
        'note_text': 'required', // Pastikan teks catatan diberikan
      }, {
        'prod_id.required': 'ID Produk wajib diisi',
        'note_date.required': 'Tanggal catatan wajib diisi',
        'note_date.date': 'Format tanggal tidak valid',
        'note_text.required': 'Teks catatan wajib diisi',
      });

      final inputData = request.input();

      // Cek apakah produk ada di tabel produk berdasarkan prod_id
      final product = await Product()
          .query()
          .where('prod_id', inputData['prod_id'])
          .first();
      if (product == null) {
        return Response.json(
          {'message': 'ID Produk harus ada di tabel produk'},
          400,
        );
      }

      // Tentukan node_id secara manual (misalnya berdasarkan panjang data yang ada)
      final nodeId = (await Produtcnotes().query().get()).length + 1;

      // Insert catatan baru ke tabel Produtcnotes dengan node_id yang dihasilkan secara manual
      final newNote = await Produtcnotes().query().insert({
        'node_id': nodeId, // Menetapkan node_id secara manual
        'prod_id': inputData['prod_id'],
        'note_date': inputData['note_date'],
        'note_text': inputData['note_text'],
      });

      return Response.json(
        {'message': 'Catatan berhasil dibuat', 'data': newNote},
        201,
      );
    } catch (e) {
      print('Error: $e');
      if (e is ValidationException) {
        // Tangani pengecualian validasi
        return Response.json({'errors': e.message}, 400);
      } else {
        // Tangani kesalahan yang tidak terduga
        return Response.json(
          {
            'message': 'Terjadi kesalahan saat membuat catatan',
            'error': e.toString()
          },
          500,
        );
      }
    }
  }

  Future<Response> show(int id) async {
    // Ambil data pelanggan berdasarkan id dari basis data
    final product_notes = await Produtcnotes()
        .query()
        .where('node_id', '=', id) // Menggunakan id untuk mencari
        .first();
    if (product_notes == null) {
      throw Exception('Produt Notes tidak ditemukan');
    }
    return Response.json(product_notes);
  }

  Future<Response> edit(int id) async {
    return Response.json({
      'message': 'Provide updated data for the note',
    });
  }

  Future<Response> update(Request request, int id) async {
    try {
      // Validate input
      request.validate({
        'prod_id': 'required',
        'note_date': 'required|date',
        'note_text': 'required',
      }, {
        'prod_id.required': 'Product ID is required',
        'note_date.required': 'Note date is required',
        'note_date.date': 'Invalid date format',
        'note_text.required': 'Note text is required',
      });

      final inputData = request.input();

      // Check if the note exists
      final existingNote =
          await Produtcnotes().query().where('node_id', '=', id).first();

      if (existingNote == null) {
        return Response.json({
          'message': 'Note not found',
        }, 404);
      }

      // Update the note
      await Produtcnotes().query().where('node_id', '=', id).update({
        'prod_id': inputData['prod_id'],
        'note_date': inputData['note_date'],
        'note_text': inputData['note_text'],
      });

      return Response.json({
        'message': 'Note updated successfully',
        'data': inputData,
      });
    } catch (e) {
      print('Error: $e');
      if (e is ValidationException) {
        return Response.json({'errors': e.message}, 400);
      } else {
        return Response.json({
          'message': 'Error updating note',
          'error': e.toString(),
        }, 500);
      }
    }
  }

  Future<Response> destroy(int id) async {
    try {
      // Check if the note exists
      final existingNote =
          await Produtcnotes().query().where('node_id', '=', id).first();

      if (existingNote == null) {
        return Response.json({
          'message': 'Note not found',
        }, 404);
      }

      // Delete the note
      await Produtcnotes().query().where('node_id', '=', id).delete();

      return Response.json({
        'message': 'Note deleted successfully',
      });
    } catch (e) {
      print('Error: $e');
      return Response.json({
        'message': 'Error deleting note',
        'error': e.toString(),
      }, 500);
    }
  }
}

final ProdutcnotesController produtcnotesController = ProdutcnotesController();
