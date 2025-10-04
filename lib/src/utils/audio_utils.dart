import 'dart:math' as math;
import 'dart:typed_data';

/// Utility class for audio processing.
///
/// Provides static methods for normalizing, denormalizing,
/// applying gain, and calculating RMS of audio data.
class AudioUtils {
  static const int _i16Min = -32768;
  static const int _i16Max = 32767;
  static const double _i16Scale = 32768;

  /// Normalizes 16-bit PCM [pcmData] (values in [-32768, 32767])
  /// to [-1.0, 1.0].
  ///
  /// Each integer sample is divided by 32768.0 and returned as a [Float32List].
  static Float32List normalizeAudio(final List<int> pcmData) {
    final int n = pcmData.length;
    final Float32List normalized = Float32List(n);

    for (int i = 0; i < n; i++) {
      final int s = pcmData[i];

      // Debug-only guard: ensure input is in 16-bit signed range.
      assert(
        s >= _i16Min && s <= _i16Max,
        'PCM sample out of int16 range at index $i: $s',
      );

      normalized[i] = s / _i16Scale; // double
    }
    return normalized;
  }

  /// Convenience overload if input is already an [Int16List].
  static Float32List normalizeAudioI16(final Int16List pcmData) =>
      normalizeAudio(pcmData);

  /// Converts normalized audio back to 16-bit PCM values.
  ///
  /// Multiplies each value by 32768.0, rounds to nearest int,
  /// and clamps to [-32768, 32767].
  static List<int> denormalizeAudio(final Float32List normalizedData) {
    final int n = normalizedData.length;
    final List<int> denormalized = List<int>.filled(n, 0);

    for (int i = 0; i < n; i++) {
      final double x = normalizedData[i];
      // Debug-only guard: ensure normalized values are in [-1.0, 1.0]
      assert(
        x >= -1.0000001 && x <= 1.0000001,
        'Normalized sample out of range at index $i: $x',
      );

      // Round to nearest int16 value, then clamp with ints
      // to avoid num → int casts.
      int v = (x * _i16Scale).round();
      if (v < _i16Min) {
        v = _i16Min;
      } else if (v > _i16Max) {
        v = _i16Max;
      }
      denormalized[i] = v;
    }
    return denormalized;
  }

  /// Calculates the Root Mean Square (RMS) of [audioData].
  ///
  /// Returns 0.0 for empty input.
  static double calculateRMS(final Float32List audioData) {
    final int n = audioData.length;
    if (n == 0) {
      return 0;
    }

    double sum = 0;
    for (int i = 0; i < n; i++) {
      final double s = audioData[i];
      sum += s * s;
    }
    return math.sqrt(sum / n);
  }

  /// Applies [gain] to [audioData] and clamps output to [-1.0, 1.0].
  static Float32List applyGain(final Float32List audioData, final double gain) {
    final int n = audioData.length;
    final Float32List result = Float32List(n);

    for (int i = 0; i < n; i++) {
      final double y = audioData[i] * gain;
      // Use min/max to keep type as double (avoid num from clamp()).
      result[i] = y < -1.0 ? -1.0 : (y > 1.0 ? 1.0 : y);
      // Alternatively:
      // result[i] = math.max(-1.0, math.min(1.0, y));
    }
    return result;
  }
}
