import 'package:flutter/material.dart';

class GenreProfileCard extends StatelessWidget {
  const GenreProfileCard({super.key, required this.profile});
  final Map<String, String> profile;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[800],
            backgroundImage: profile['avatarUrl'] != null
                ? AssetImage(profile['avatarUrl']!)
                : null,
            child: profile['avatarUrl'] == null
                ? const Icon(Icons.person, size: 36, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 6),
          Text(
            profile['username'] ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 6),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              backgroundColor: Color(0xffffffff),
              foregroundColor: Color.fromARGB(255, 0, 0, 0),
              minimumSize: const Size(0, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: const TextStyle(fontSize: 13),
            ),
            child: const Text('Follow'),
          ),
        ],
      ),
    );
  }
}
