import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FuturisticRecorder {
  static Future<void> show(BuildContext context, String soundName, Function(String) onSave) async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permission micro refusée')));
      }
      return;
    }

    final record = AudioRecorder();
    bool isRecording = false;
    int recordDuration = 0;
    Timer? timer;
    String? tempPath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void startRecording() async {
              if (await record.hasPermission()) {
                final dir = await getApplicationDocumentsDirectory();
                tempPath = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

                await record.start(const RecordConfig(), path: tempPath!);
                setModalState(() {
                  isRecording = true;
                  recordDuration = 0;
                });

                timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
                  setModalState(() => recordDuration++);
                });
              }
            }

            void stopRecording() async {
              final path = await record.stop();
              timer?.cancel();
              setModalState(() => isRecording = false);

              if (path != null) {
                onSave(path);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Audio "$soundName" sauvegardé avec succès !'), backgroundColor: Colors.green));
                }
              }
            }

            String formatDuration(int seconds) {
              final m = (seconds / 60).floor().toString().padLeft(2, '0');
              final s = (seconds % 60).toString().padLeft(2, '0');
              return "$m:$s";
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                boxShadow: [BoxShadow(color: Colors.greenAccent.withOpacity(0.2), blurRadius: 40, spreadRadius: 10)],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Enregistrement : $soundName', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 10),
                  Text(isRecording ? 'Enregistrement en cours...' : 'Prêt à enregistrer', style: TextStyle(color: isRecording ? Colors.greenAccent : Colors.grey, fontSize: 16)),
                  const SizedBox(height: 50),
                  GestureDetector(
                    onTap: isRecording ? stopRecording : startRecording,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (isRecording)
                          Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.greenAccent, width: 2)))
                              .animate(onPlay: (controller) => controller.repeat())
                              .scale(begin: const Offset(1, 1), end: const Offset(2.5, 2.5), duration: 1500.ms)
                              .fade(begin: 1, end: 0, duration: 1500.ms),
                        if (isRecording)
                          Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.greenAccent, width: 4)))
                              .animate(onPlay: (controller) => controller.repeat())
                              .scale(begin: const Offset(1, 1), end: const Offset(2, 2), duration: 1500.ms, delay: 500.ms)
                              .fade(begin: 1, end: 0, duration: 1500.ms),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: isRecording ? 180 : 150,
                          height: isRecording ? 180 : 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: isRecording ? [Colors.redAccent, Colors.red.shade900] : [Colors.greenAccent.shade400, Colors.teal],
                              begin: Alignment.topLeft, end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(color: isRecording ? Colors.redAccent.withOpacity(0.6) : Colors.greenAccent.withOpacity(0.6), blurRadius: isRecording ? 50 : 20, spreadRadius: isRecording ? 10 : 5)
                            ],
                          ),
                          child: Icon(isRecording ? Icons.stop_rounded : Icons.mic_none_rounded, color: Colors.white, size: 80),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
                    child: Text(formatDuration(recordDuration), style: const TextStyle(color: Colors.white, fontSize: 36, fontFamily: 'monospace', fontWeight: FontWeight.bold, letterSpacing: 2)),
                  ),
                  const SizedBox(height: 40),
                  if (!isRecording)
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler', style: TextStyle(color: Colors.grey, fontSize: 18))),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
