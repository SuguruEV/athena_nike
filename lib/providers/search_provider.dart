import 'dart:async';
import 'package:flutter/material.dart';

class SearchProvider extends ChangeNotifier {
  String _searchQuery = '';
  Timer? _debounce;

  // Getter for search query
  String get searchQuery => _searchQuery;

  // Set search query with debounce
  void setSearchQuery(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchQuery = query;
      notifyListeners();
    });
  }

  // Clear search query
  void clearSearchQuery() {
    _searchQuery = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}