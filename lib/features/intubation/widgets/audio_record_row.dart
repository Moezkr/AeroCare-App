import 'package:flutter/material.dart';
import 'futuristic_recorder.dart';

class AudioRecordRow extends StatelessWidget {
  final String label;
  final String? currentPath;
  final Function(String) onSave;

  const AudioRecordRow({
    super.key,
    required this.label,
    required this.currentPath,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasAudio = currentPath != null && currentPath!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => FuturisticRecorder.show(context, label, onSave),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: hasAudio ? Colors.green.shade50 : Theme.of(context).inputDecorationTheme.fillColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: hasAudio ? Colors.green : Colors.grey.shade300, width: hasAudio ? 2 : 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: hasAudio ? Colors.green : Theme.of(context).primaryColor, shape: BoxShape.circle),
                child: Icon(hasAudio ? Icons.check_rounded : Icons.mic_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Son: $label', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(hasAudio ? 'Audio prêt' : 'Appuyez pour enregistrer', style: TextStyle(color: hasAudio ? Colors.green.shade700 : Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              if (hasAudio) const Icon(Icons.play_circle_fill_rounded, color: Colors.green, size: 30),
            ],
          ),
        ),
      ),
    );
  }
}
