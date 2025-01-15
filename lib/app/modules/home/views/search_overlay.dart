// lib/app/widgets/search_overlay.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchOverlay extends StatelessWidget {
  final TextEditingController searchController;
  final bool isLoading;
  final VoidCallback onClose;
  final List<Map<String, dynamic>> searchResults;
  final Function(Map<String, dynamic>) onResultTap;

  const SearchOverlay({
    Key? key,
    required this.searchController,
    required this.isLoading,
    required this.onClose,
    required this.searchResults,
    required this.onResultTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Column(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClose,
            ),
            title: TextField(
              controller: searchController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'searchHint'.tr,
                hintStyle: const TextStyle(color: Colors.white70),
                border: InputBorder.none,
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final result = searchResults[index];
                      return ListTile(
                        title: Text(
                          result['title'] ?? '',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          result['subtitle'] ?? '',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        leading: Icon(
                          _getIconForType(result['type']),
                          color: Colors.white70,
                        ),
                        onTap: () => onResultTap(result),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'city':
        return Icons.location_city;
      case 'customer':
        return Icons.person;
      case 'phone':
        return Icons.phone;
      default:
        return Icons.search;
    }
  }
}