import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_providers.dart';

class SearchBarWidget extends ConsumerStatefulWidget {
  const SearchBarWidget({super.key});

  @override
  ConsumerState<SearchBarWidget> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<SearchBarWidget> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose(); // ← before super.dispose()
    super.dispose();
  }

  void _onChanged(String value) {
    ref.read(searchQueryProvider.notifier).update(value);
  }

  void _onClear() {
    _controller.clear();
    ref.read(searchQueryProvider.notifier).update('');
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);

    return TapRegion(
      onTapOutside: (_) => _focusNode.unfocus(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 35,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'Search',
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: query.trim().isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _onClear,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              filled: true,
            ),
            onChanged: _onChanged,
          ),
        ),
      ),
    );
  }
}
