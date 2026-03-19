import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({
    super.key
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller =TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Message'),
        centerTitle: false,
      ),
      body:Column(
        children: [
          SearchBar(
            key: const Key('search_screen_new_message_search_bar'),
            controller: controller,onChanged:(value) {
            
            },
          ),
          // Expanded(
          //   child: ,
          // )
        ],
      )
    );
  }
}