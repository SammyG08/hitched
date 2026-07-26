import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'guest_model.dart';

final guestListProvider = FutureProvider<List<Guest>>((ref) async {
  final response = await http.get(Uri.parse('http://localhost:8080/guests'));
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => Guest.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load guests');
  }
});
