import math

class FeatureExtractor:
    def __init__(self):
        pass

    def extract(self, landmarks, image_size):
        if not landmarks or len(landmarks) == 0:
            return {}

        nose = self._find(landmarks, 0)
        l_shoulder = self._find(landmarks, 11)
        r_shoulder = self._find(landmarks, 12)
        l_hip = self._find(landmarks, 23)
        r_hip = self._find(landmarks, 24)
        l_ankle = self._find(landmarks, 27)
        r_ankle = self._find(landmarks, 28)

        if not all([l_shoulder, r_shoulder, l_hip, r_hip, nose, l_ankle, r_ankle]):
            return {
                "shoulderWidthPx": 0,
                "hipWidthPx": 0,
                "torsoLengthPx": 0,
                "whtrProxy": 0,
                "shr": 0
            }

        shoulder_width = self._dist(l_shoulder, r_shoulder, image_size)
        hip_width = self._dist(l_hip, r_hip, image_size)

        mid_shoulder_x = ((l_shoulder.x + r_shoulder.x) / 2) * image_size[0]
        mid_shoulder_y = ((l_shoulder.y + r_shoulder.y) / 2) * image_size[1]

        mid_hip_x = ((l_hip.x + r_hip.x) / 2) * image_size[0]
        mid_hip_y = ((l_hip.y + r_hip.y) / 2) * image_size[1]

        torso_length = math.sqrt((mid_shoulder_x - mid_hip_x)**2 + (mid_shoulder_y - mid_hip_y)**2)

        l_leg = self._dist(l_hip, l_ankle, image_size)
        r_leg = self._dist(r_hip, r_ankle, image_size)
        leg_length = (l_leg + r_leg) / 2

        l_knee = self._find(landmarks, 25)
        r_knee = self._find(landmarks, 26)

        has_ankles = (l_ankle.visibility > 0.5 and r_ankle.visibility > 0.5)
        has_knees = (l_knee is not None and l_knee.visibility > 0.5 and r_knee is not None and r_knee.visibility > 0.5)

        height_px_proxy = 0.0
        if has_ankles:
            avg_ankle_y = ((l_ankle.y + r_ankle.y) / 2) * image_size[1]
            nose_y = nose.y * image_size[1]
            height_px_proxy = abs(avg_ankle_y - nose_y)
        elif has_knees:
            avg_knee_y = ((l_knee.y + r_knee.y) / 2) * image_size[1]
            nose_y = nose.y * image_size[1]
            height_px_proxy = abs(avg_knee_y - nose_y) * 1.3
        else:
            height_px_proxy = torso_length * 2.5

        is_height_reliable = has_ankles

        trunk_width = (shoulder_width + hip_width) / 2
        whtr = 0.0
        if height_px_proxy > 0:
            whtr = trunk_width / height_px_proxy

        shr = 0.0
        if hip_width > 0:
            shr = shoulder_width / hip_width

        ltr = 0.0
        if torso_length > 0:
            ltr = leg_length / torso_length

        waist_proxy = hip_width * 0.9

        features = {
            "shoulderWidthPx": shoulder_width,
            "hipWidthPx": hip_width,
            "torsoLengthPx": torso_length,
            "legLengthPx": leg_length,
            "whtrProxy": whtr,
            "shr": shr,
            "ltr": ltr,
            "waistProxy": waist_proxy,
            "isHeightReliable": 1.0 if is_height_reliable else 0.0,
        }
        
        print(f"AI_DEBUG: FeatureExtractor - Height Reliable: {is_height_reliable}, Proxy: {int(height_px_proxy)}")
        print(f"AI_DEBUG: FeatureExtractor - Extracted Ratios: {features}")
        return features

    def _find(self, landmarks, landmark_type):
        try:
            return landmarks[landmark_type]
        except IndexError:
            return None

    def _dist(self, p1, p2, image_size):
        x1, y1 = p1.x * image_size[0], p1.y * image_size[1]
        x2, y2 = p2.x * image_size[0], p2.y * image_size[1]
        return math.sqrt((x1 - x2)**2 + (y1 - y2)**2)
