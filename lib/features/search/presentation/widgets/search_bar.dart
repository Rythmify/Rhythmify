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
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    ref.read(searchQueryProvider.notifier).update(value);
  }

  void _onClear() {
    _controller.clear();
    ref.read(searchQueryProvider.notifier).update('');
  }

  void _onSubmitted(String value) {
    if (value.trim().isNotEmpty) {
      ref.read(searchSubmittedProvider.notifier).submit();
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.text = ref.read(searchQueryProvider);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(searchQueryProvider, (_, next) {
      if (_controller.text != next) {
        _controller.text = next;
        _controller.selection = TextSelection.collapsed(offset: next.length);
      }
    });
    final query = ref.watch(searchQueryProvider);

    return TapRegion(
      onTapOutside: (_) => _focusNode.unfocus(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 35,
          child: TextField(
            key: const Key('search_bar_field'),
            controller: _controller,
            focusNode: _focusNode,
            onSubmitted: _onSubmitted,
            decoration: InputDecoration(
              hintText: 'Search',
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: query.trim().isNotEmpty
                  ? IconButton(
                      key: const Key('search_bar_clear_button'),
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
