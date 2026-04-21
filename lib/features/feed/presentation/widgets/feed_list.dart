import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/feed_providers.dart';
import 'feed_card.dart';

enum FeedTab { discover, following }

class FeedList extends ConsumerWidget {
  final FeedTab tab;

  const FeedList({super.key, required this.tab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = tab == FeedTab.following
        ? followingFeedProvider
        : discoverFeedProvider;

    final async = ref.watch(provider);

    return async.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: Colors.orange)),
      error: (e, _) => Center(
        child: Text(
          e.toString(),
          style: const TextStyle(color: Colors.white54),
        ),
      ),
      data: (items) => PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: items.length,
        itemBuilder: (context, index) => FeedCard(item: items[index], tab: tab),
      ),
    );
  }
}
