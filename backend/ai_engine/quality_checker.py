import math

class QualityChecker:
    def __init__(self):
        pass

    def check(self, landmarks, image_size):
        if not landmarks or len(landmarks) == 0:
            return {'fullBodyVisible': False, 'poseOk': False, 'lightingOk': False, 'messages': ["No landmarks detected"]}

        nose = self._find(landmarks, 0)
        l_shoulder = self._find(landmarks, 11)
        r_shoulder = self._find(landmarks, 12)
        l_hip = self._find(landmarks, 23)
        r_hip = self._find(landmarks, 24)
        l_ankle = self._find(landmarks, 27)
        r_ankle = self._find(landmarks, 28)

        missing = []
        if not self._is_visible(nose): missing.append("Head")
        if not self._is_visible(l_shoulder) or not self._is_visible(r_shoulder): missing.append("Shoulders")
        if not self._is_visible(l_hip) or not self._is_visible(r_hip): missing.append("Hips")
        if not self._is_visible(l_ankle) or not self._is_visible(r_ankle): missing.append("Feet")

        full_body_visible = len(missing) == 0

        pose_ok = True
        pose_messages = []

        if full_body_visible:
            shoulder_slope = abs((l_shoulder.y * image_size[1]) - (r_shoulder.y * image_size[1]))
            # 40 pixels was the heuristic, we assume image_size = (width, height) in pixels
            if shoulder_slope > 40:
                pose_ok = False
                pose_messages.append("Shoulders not level")
        else:
            pose_ok = False
            pose_messages.append("Body parts missing")

        lighting_ok = True

        essential_types = [11, 12, 23, 24]
        
        essential_visible = True
        for type_enum in essential_types:
            lm = self._find(landmarks, type_enum)
            if not lm or lm.visibility <= 0.5:
                essential_visible = False
                break

        messages = []
        if len(missing) > 0:
            messages.append(f"Vücudun bazı bölümleri (ör: {', '.join(missing)}) tam görünmüyor.")
        if not essential_visible:
            messages.append("Gövde net seçilemiyor, sonuçlar sadece tahminidir.")
        
        messages.extend(pose_messages)

        confidence = 1.0
        
        if len(missing) > 0:
            confidence -= 0.15 * len(missing)
        
        if not essential_visible:
            confidence -= 0.35

        avg_likelihood = sum([lm.visibility for lm in landmarks]) / len(landmarks)
        confidence *= avg_likelihood

        l_wrist = self._find(landmarks, 15)
        r_wrist = self._find(landmarks, 16)
        hands_in_pockets = False

        if l_wrist and r_wrist and l_hip and r_hip:
            # We must multiply by dimensions or just use normalized distance if both are normalized.
            # In Flutter, ML Kit gives absolute pixel coordinates. MediaPipe gives normalized [0.0, 1.0].
            # We must un-normalize for pixel distance.
            l_dist = self._dist(l_wrist, l_hip, image_size)
            r_dist = self._dist(r_wrist, r_hip, image_size)
            if l_dist < 0.1 * image_size[1] and r_dist < 0.1 * image_size[1]:
                hands_in_pockets = True
                confidence -= 0.1
                messages.append("Daha iyi analiz için ellerinizi görünür tutun.")

        if confidence < 0.05:
            confidence = 0.05

        return {
            'fullBodyVisible': full_body_visible,
            'essentialVisible': essential_visible,
            'poseOk': pose_messages == [], # True if empty
            'lightingOk': lighting_ok,
            'confidenceScore': confidence,
            'handsInPockets': hands_in_pockets,
            'messages': messages,
            'missingParts': missing,
        }

    def _dist(self, p1, p2, image_size):
        # MediaPipe returns normalized coordinates
        x1, y1 = p1.x * image_size[0], p1.y * image_size[1]
        x2, y2 = p2.x * image_size[0], p2.y * image_size[1]
        return math.sqrt((x1 - x2)**2 + (y1 - y2)**2)

    def _find(self, landmarks, landmark_type):
        try:
            return landmarks[landmark_type]
        except IndexError:
            return None

    def _is_visible(self, landmark):
        return landmark is not None and landmark.visibility > 0.5
