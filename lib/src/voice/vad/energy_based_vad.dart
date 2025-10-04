import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:rxdart/rxdart.dart';

import 'package:flutter_ai_agent_sdk/src/voice/vad/voice_activity_detector.dart';

class EnergyBasedVAD implements VoiceActivityDetector {
  
  EnergyBasedVAD({
    this.threshold = 0.02,
    this.smoothingWindow = 3,
  });
  final double threshold;
  final int smoothingWindow;
  
  final BehaviorSubject<VADResult> _activityController = BehaviorSubject<VADResult>();
  final List<double> _energyHistory = <double>[];
  
  @override
  Stream<VADResult> get activityStream => _activityController.stream;
  
  @override
  Future<void> initialize() async {
    // No initialization needed for energy-based VAD
  }
  
  @override
  Future<VADResult> detectActivity(final Float32List audioData) async {
    final double energy = _calculateEnergy(audioData);
    _energyHistory.add(energy);
    
    if (_energyHistory.length > smoothingWindow) {
      _energyHistory.removeAt(0);
    }
    
    final double smoothedEnergy = _energyHistory.reduce((final double a, final double b) => a + b) / 
                           _energyHistory.length;
    
    final bool isSpeech = smoothedEnergy > threshold;
    final double confidence = min(smoothedEnergy / (threshold * 2), 1);
    
    final VADResult result = VADResult(
      isSpeech: isSpeech,
      confidence: confidence,
    );
    
    _activityController.add(result);
    return result;
  }
  
  double _calculateEnergy(final Float32List audioData) {
    double sum = 0;
    for (final double sample in audioData) {
      sum += sample * sample;
    }
    return sqrt(sum / audioData.length);
  }
  
  @override
  Future<void> dispose() async {
    await _activityController.close();
  }
}
