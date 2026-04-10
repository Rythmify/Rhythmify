import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/domain/entities/track.dart';
import '../../../../../core/presentation/pages/report_page.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../providers/track_interaction_provider.dart';
import '../../../../messaging/presentation/providers/conversations_provider.dart';

import 'bottom_sheet_container.dart';
import 'track_sheet_header.dart';

// 1. Define the modes
enum TrackModalMode { share, info }

class TrackOptionsModal extends ConsumerWidget {
  final Track track;
  final TrackModalMode mode;

  const TrackOptionsModal({
    super.key, 
    required this.track, 
    this.mode = TrackModalMode.info, // Default to info if not specified
  });

  // --- Share Methods ---
  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _shareToWhatsApp(BuildContext context) {
    final text = 'Listen Now On Rythmify: https://rythmify.com/track/${track.id}';
    final urlString = 'whatsapp://send?text=${Uri.encodeComponent(text)}';
    _launchUrl(urlString);
    Navigator.pop(context);
  }

  void _shareToSMS(BuildContext context) {
    final text = 'Listen Now On Rythmify: https://rythmify.com/track/${track.id}';
    final urlString = 'sms:?body=${Uri.encodeComponent(text)}';
    _launchUrl(urlString);
    Navigator.pop(context);
  }

  void _copyLink(BuildContext context) {
    final text = 'Listen Now On Rythmify: https://rythmify.com/track/${track.id}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied to clipboard')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convsAsync = ref.watch(conversationProvider);

    // WRAPPED IN DRAGGABLE SCROLLABLE SHEET
    return DraggableScrollableSheet(
      initialChildSize: 0.9,  // Opens to 90% of screen height
      minChildSize: 0.5,      // Closes if dragged below 50%
      maxChildSize: 0.95,     // Stops just short of the very top of the screen
      expand: false,          // MUST be false to work inside a bottom sheet
      builder: (context, scrollController) {
        return BottomSheetContainer(
          child: SingleChildScrollView(
            controller: scrollController, // LINKED THE CONTROLLER HERE
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header always shows at the top
                TrackSheetHeader(track: track),
                
                // 2. Share stuff ALWAYS shows
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'SEND TO',
                    style: AppTheme.labelSmall.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                  ),
                ),
                SizedBox(
                  height: 100,
                  child: convsAsync.when(
                    data: (convs) => ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: convs.length,
                      itemBuilder: (context, index) {
                        final conv = convs[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/home/inbox/chat/${conv.conversationId}');
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: SizedBox(
                              width: 60,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Colors.grey[800],
                                    backgroundImage: conv.participantAvatar != null
                                        ? NetworkImage(conv.participantAvatar!)
                                        : null,
                                    child: conv.participantAvatar == null
                                        ? const Icon(Icons.person, color: Colors.white)
                                        : null,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    conv.participantName,
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => const Center(child: Text('Error loading contacts', style: TextStyle(color: Colors.white))),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(
                    'SHARE',
                    style: AppTheme.labelSmall.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                  ),
                ),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _ShareIcon(
                        iconData: Icons.chat_bubble_outline,
                        color: Colors.blueAccent,
                        label: 'Message',
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/home/inbox');
                        },
                      ),
                      _ShareIcon(
                        iconData: Icons.link,
                        color: Colors.grey[700]!,
                        label: 'Copy Link',
                        onTap: () => _copyLink(context),
                      ),
                      _ShareIcon(
                        svgAsset: 'assets/icons/whatsapp.svg',
                        color: const Color(0xFF25D366),
                        label: 'WhatsApp',
                        onTap: () => _shareToWhatsApp(context),
                      ),
                      _ShareIcon(
                        iconData: Icons.sms_outlined,
                        color: Colors.orangeAccent,
                        label: 'SMS',
                        onTap: () => _shareToSMS(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // 3. Info actions ONLY show if mode is 'info'
                if (mode == TrackModalMode.info) ...[
                  const Divider(color: Colors.white24, height: 1),
                  _buildActionRow(
                    icon: track.isLiked ? Icons.favorite : Icons.favorite_border,
                    iconColor: track.isLiked ? AppTheme.primaryBrand : Colors.white,
                    label: track.isLiked ? 'Liked' : 'Like track',
                    labelColor: track.isLiked ? AppTheme.primaryBrand : Colors.white,
                    onTap: () {
                      ref.read(trackInteractionProvider).handleToggleLike(track.id, track.isLiked);
                      Navigator.pop(context);
                    },
                  ),
                  _buildActionRow(
                    icon: Icons.playlist_play,
                    label: 'Play Next',
                    onTap: () {},
                  ),
                  _buildActionRow(
                    icon: Icons.playlist_play,
                    label: 'Play Last',
                    onTap: () {},
                  ),
                  _buildActionRow(
                    icon: Icons.queue_music,
                    label: 'Add to Playlist',
                    onTap: () {},
                  ),
                  _buildActionRow(
                    icon: Icons.radio,
                    label: 'Start Station',
                    onTap: () {},
                  ),
                  const Divider(color: Colors.white24, height: 1),
                  _buildActionRow(
                    icon: Icons.person_outline,
                    label: 'Go to profile',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/profile/${track.userId}');
                    },
                  ),
                  _buildActionRow(
                    icon: Icons.chat_outlined,
                    label: 'View comments',
                    onTap: () {
                      Navigator.pop(context);
                      context.pushNamed('comments', pathParameters: {'trackId': track.id}, extra: track);
                    },
                  ),
                  _buildActionRow(
                    icon: Icons.repeat,
                    iconColor: track.isReposted ? AppTheme.primaryBrand : Colors.white,
                    label: track.isReposted ? 'Reposted' : 'Repost on Rythmify',
                    labelColor: track.isReposted ? AppTheme.primaryBrand : Colors.white,
                    onTap: () {
                      ref.read(trackInteractionProvider).handleToggleRepost(track.id, track.isReposted);
                      Navigator.pop(context);
                    },
                  ),
                  _buildActionRow(
                    icon: Icons.music_note,
                    label: 'Behind This Track',
                    onTap: () {
                      Navigator.pop(context);
                      context.pushNamed('behindTheTrack', pathParameters: {'trackId': track.id});
                    },
                  ),
                  _buildActionRow(
                    icon: Icons.flag_outlined,
                    label: 'Report Track',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (context) => ReportPage(reportedContentId: track.id),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
    Color labelColor = Colors.white,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        highlightColor: Colors.white.withValues(alpha: 0.1),
        splashColor: Colors.white.withValues(alpha: 0.2),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: AppTheme.bodyNormal.copyWith(
                    color: labelColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareIcon extends StatelessWidget {
  final IconData? iconData;
  final String? svgAsset;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _ShareIcon({
    this.iconData,
    this.svgAsset,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: SizedBox(
          width: 60,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
                alignment: Alignment.center,
                child: svgAsset != null
                    ? SvgPicture.asset(
                        svgAsset!,
                        width: 28,
                        height: 28,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      )
                    : Icon(iconData, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}