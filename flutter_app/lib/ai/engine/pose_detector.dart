import 'dart:ui';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseDetectorWrapper {
  final _poseDetector = PoseDetector(options: PoseDetectorOptions(mode: PoseDetectionMode.single));

  Future<List<PoseLandmark>?> detect(InputImage inputImage) async {
    try {
      final List<Pose> poses = await _poseDetector.processImage(inputImage);
      if (poses.isEmpty) return null;
      
      // Return first pose landmarks
      // ML Kit returns map of type -> landmark
      final pose = poses.first;
      return pose.landmarks.values.toList(); 
    } catch (e) {
      print("Pose detection error: $e");
      return null;
    }
  }

  void close() {
    _poseDetector.close();
  }
}
