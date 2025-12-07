import 'package:flutter/material.dart';

class BackgroundAudioControl extends StatefulWidget {
  const BackgroundAudioControl({super.key});

  @override
  State<BackgroundAudioControl> createState() => _BackgroundAudioControlState();
}

class _BackgroundAudioControlState extends State<BackgroundAudioControl> {
  bool _isPlaying = false;
  // Placeholder audio player controller would go here

  void _toggleAudio() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    // Trigger audio play/pause logic
    if (_isPlaying) {
      debugPrint('Playing background music...');
    } else {
      debugPrint('Paused background music.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _toggleAudio,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isPlaying ? Icons.music_note : Icons.music_off,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _isPlaying ? 'Theme On' : 'Theme Off',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
