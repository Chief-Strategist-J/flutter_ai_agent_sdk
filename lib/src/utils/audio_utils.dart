import 'dart:typed_data';
import 'dart:math';

class AudioUtils {
  static Float32List normalizeAudio(final List<int> pcmData) {
    final Float32List normalized = Float32List(pcmData.length);
    for (int i = 0; i < pcmData.length; i++) {
      normalized[i] = pcmData[i] / 32768.0;
    }
    return normalized;
  }

  static List<int> denormalizeAudio(final Float32List normalizedData) {
    final List<int> denormalized = List<int>.filled(normalizedData.length, 0);
    for (int i = 0; i < normalizedData.length; i++) {
      denormalized[i] =
          (normalizedData[i] * 32768.0).round().clamp(-32768, 32767);
    }
    return denormalized;
  }

  static double calculateRMS(final Float32List audioData) {
    double sum = 0;
    for (final double sample in audioData) {
      sum += sample * sample;
    }
    return sqrt(sum / audioData.length);
  }

  static Float32List applyGain(final Float32List audioData, final double gain) {
    final Float32List result = Float32List(audioData.length);
    for (int i = 0; i < audioData.length; i++) {
      result[i] = (audioData[i] * gain).clamp(-1.0, 1.0);
    }
    return result;
  }
}
