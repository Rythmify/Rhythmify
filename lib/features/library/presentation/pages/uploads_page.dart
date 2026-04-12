import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/library_providers.dart';
import '../../../track/presentation/widgets/track_card.dart';

/// Your Uploads page matching SoundCloud's layout.
///
/// Empty state: centered icon + headline + body + "Upload a track" [OutlinedButton].
/// Loaded state: search bar + [ListView] of upload tiles with status badges.
class UploadsPage extends ConsumerStatefulWidget {
  const UploadsPage({super.key});

  @override
  ConsumerState<UploadsPage> createState() => _UploadsPageState();
}

class _UploadsPageState extends ConsumerState<UploadsPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(uploadsProvider.notifier).load();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(uploadsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Your uploads'),
        centerTitle: false,
        actions: [
          IconButton(
            key: const Key('uploads_new_upload_icon_button'),
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/upload-track'),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryBrand,
        onRefresh: () => ref.read(uploadsProvider.notifier).load(refresh: true),
        child: _buildBody(context, state),
      ),
    );
  }

  Widget _buildBody(BuildContext context, UploadsState state) {
    if (state.isLoading && state.tracks.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryBrand),
      );
    }

    // ── Empty state matching SoundCloud screenshot ────────────────────────
    if (state.tracks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Purple gradient placeholder (matching the screenshot's gradient header)
              Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF4A0080), Color(0xFF1A0040)],
                  ),
                ),
                child: const Icon(
                  Icons.cloud_upload_outlined,
                  color: Colors.white54,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No tracks uploaded yet',
                key: const Key('uploads_empty_headline_text'),
                style: AppTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Tracks you\'ve uploaded will show up here',
                key: const Key('uploads_empty_body_text'),
                style: AppTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                key: const Key('uploads_empty_upload_button'),
                onPressed: () => context.push('/upload-track'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textPrimary,
                  side: const BorderSide(color: AppTheme.textSecondary),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('Upload a track'),
              ),
            ],
          ),
        ),
      );
    }

    final filtered = _query.isEmpty
        ? state.tracks
        : state.tracks
              .where(
                (t) => t.title.toLowerCase().contains(_query.toLowerCase()),
              )
              .toList();

    return Column(
      children: [
        // ── Search bar ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(21),
            ),
            child: TextField(
              key: const Key('uploads_search_text_field'),
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search in your uploads',
                hintStyle: AppTheme.bodyMedium,
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                suffixIcon: const Icon(
                  Icons.tune,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 11),
              ),
            ),
          ),
        ),

        // ── Upload list ────────────────────────────────────────────────────
        Expanded(
          child: ListView.builder(
            key: const Key('uploads_list_view'),
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 120),
            itemCount: filtered.length + 1,
            itemBuilder: (context, index) {
              if (index == filtered.length) {
                return state.isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryBrand,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : const SizedBox.shrink();
              }
              return TrackCard(track: filtered[index].track);
            },
          ),
        ),
      ],
    );
  }
}

