import 'package:blog/app/models/user.dart';

Map<String, dynamic> authConfig = {
  'defaults': {
    'guard': 'default',
  },
  'guards': {
    'default': {
      'driver': 'jwt', // specify the authentication driver
      'provider': User(), // your user model
      'model': User, // specify the user model class
      'table': 'users', // database table name for users
    }
  },
  'tokens': {
    'access_token': {
      'expires_in': 3600, // token expiration in seconds
    },
    'refresh_token': {
      'expires_in': 604800, // refresh token expiration (e.g., 1 week)
    }
  }
};
