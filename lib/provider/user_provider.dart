import 'package:allo/data/db/supabase.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  Map<String, dynamic> _user = {};

  Map<String, dynamic> get user => _user;

  set user(Map<String, dynamic> newUser) {
    _user = newUser;
    notifyListeners();
  }

  fetchUser(int userId) async {
    _user = await SupabaseDB.selectUserById(userId);
    notifyListeners();
  }
}
