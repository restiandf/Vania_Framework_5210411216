import 'dart:io';

import 'package:vania/vania.dart';
import 'package:blog/app/models/user.dart';
import 'package:blog/config/auth.dart'; // Pastikan file auth_config.dart ada dan diimpor dengan benar

class AuthController extends Controller {
  Future<Response> register(Request request) async {
    request.validate({
      'name': 'required',
      'email': 'required|email',
      'password': 'required|min_length:6|confirmed',
    }, {
      'name.required': 'nama tidak boleh kosong',
      'email.required': 'email tidak boleh kosong',
      'email.email': 'email tidak valid',
      'password.required': 'password tidak boleh kosong',
      'password.min_length': 'password harus terdiri dari minimal 6 karakter',
      'password.confirmed': 'konfirmasi password tidak sesuai',
    });

    final name = request.input('name');
    final email = request.input('email');
    var password = request.input('password');

    var user = await User().query().where('email', '=', email).first();
    if (user != null) {
      return Response.json({
        "message": "user sudah ada",
      }, 409);
    }

    password = Hash().make(password);
    await User().query().insert({
      "name": name,
      "email": email,
      "password": password,
      "created_at": DateTime.now().toIso8601String(),
    });

    return Response.json({"message": "berhasil mendaftarkan user"}, 201);
  }

  Future<Response> login(Request request) async {
    try {
      request.validate({
        'email': 'required|email',
        'password': 'required',
      }, {
        'email.required': 'email tidak boleh kosong',
        'email.email': 'email tidak valid',
        'password.required': 'password tidak boleh kosong',
      });

      final email = request.input('email');
      var password = request.input('password').toString();

      var user = await User().query().where('email', '=', email).first();
      if (user == null) {
        return Response.json({
          "message": "user belum terdaftar",
        }, 409);
      }

      if (!Hash().verify(password, user['password'])) {
        return Response.json({
          "message": "kata sandi yang anda masukan salah",
        }, 401);
      }

      // Remove the previous print statement
      // print('Auth Config: ${Auth.config}');

      // Try this method for token creation
      final token = await Auth()
          .login(user)
          .createToken(expiresIn: Duration(days: 30), withRefreshToken: true);

      return Response.json({
        "message": "berhasil login",
        "token": token,
      });
    } catch (e, stackTrace) {
      print('Login Error: $e');
      print('Stack Trace: $stackTrace');
      return Response.json({
        "message": "Terjadi kesalahan dalam proses login",
        "error": e.toString()
      }, 500);
    }
  }
}

final AuthController authController = AuthController();
