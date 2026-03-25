class Recommender:
    def recommend(self, age, gender, weight_kg, height_cm, goal, risk_level, body_fat_pct=None, lean_mass_kg=None):
        # 1. BMR (Mifflin-St Jeor)
        base_bmr = (10 * weight_kg) + (6.25 * height_cm) - (5 * age)
        if gender.lower() == 'male':
            base_bmr += 5
        else:
            base_bmr -= 161

        # 2. TDEE
        tdee = base_bmr * 1.35

        # 3. Target Calories
        target_calories = tdee
        if goal == 'lose':
            deficit = 600 if (weight_kg / ((height_cm / 100)**2) > 30) else 400
            target_calories -= deficit
        elif goal == 'gain':
            target_calories += 300
            
        if target_calories < 1200: target_calories = 1200

        # 4. Macros
        lean_mass = lean_mass_kg if lean_mass_kg is not None else (weight_kg * 0.85)

        protein_per_kg_lean = 2.0
        if goal == 'lose': protein_per_kg_lean = 2.8
        elif goal == 'gain': protein_per_kg_lean = 2.4

        protein_g = round(lean_mass * protein_per_kg_lean)
        protein_kcal = protein_g * 4

        remaining_kcal = round(target_calories) - protein_kcal

        if goal == 'gain':
            carbs_kcal = round(remaining_kcal * 0.65)
            fats_kcal = remaining_kcal - carbs_kcal
            macros = {'protein_g': protein_g, 'carbs_g': round(carbs_kcal / 4), 'fat_g': round(fats_kcal / 9)}
        elif goal == 'lose':
            carbs_kcal = round(remaining_kcal * 0.40)
            fats_kcal = remaining_kcal - carbs_kcal
            macros = {'protein_g': protein_g, 'carbs_g': round(carbs_kcal / 4), 'fat_g': round(fats_kcal / 9)}
        else:
            carbs_kcal = round(remaining_kcal * 0.50)
            fats_kcal = remaining_kcal - carbs_kcal
            macros = {'protein_g': protein_g, 'carbs_g': round(carbs_kcal / 4), 'fat_g': round(fats_kcal / 9)}

        # 5. Diet Plan
        diet_plan = self._get_dynamic_diet_plan(goal, round(target_calories), risk_level, body_fat_pct or 20.0, lean_mass, age, gender)

        # 6. Workout Plan
        workout_plan = self._get_dynamic_workout_plan(goal, risk_level, body_fat_pct or 20.0, lean_mass, age, gender)

        print(f"AI_DEBUG: Recommender - Goal: {goal} | Calories: {round(target_calories)}")
        print(f"AI_DEBUG: Recommender - Macros: P:{macros['protein_g']}g / C:{macros['carbs_g']}g / F:{macros['fat_g']}g")
        print(f"AI_DEBUG: Recommender - Diet Plan: {diet_plan}")
        print(f"AI_DEBUG: Recommender - Workout Plan: {workout_plan}")

        return {
            "dailyCalories": round(target_calories),
            "macros": macros,
            "dietPlan": diet_plan,
            "workoutPlan": workout_plan
        }

    def bmi_helper(self, fat, is_male):
        return 1.0

    def _get_dynamic_diet_plan(self, goal, calories, risk_level, body_fat_pct, lean_mass, age, gender):
        is_male = gender.lower() == 'male'
        is_high_fat = (body_fat_pct > 25.0) if is_male else (body_fat_pct > 32.0)
        is_low_fat = (body_fat_pct < 15.0) if is_male else (body_fat_pct < 22.0)
        
        # logic check only per flutter
        is_skinny_fat = is_high_fat and (calories < 2000)

        plan = []

        if goal == 'lose' and is_skinny_fat:
            plan = [
                "Sabah: 3 yulaflı omlet (Yüksek protein, ılımlı karbonhidrat)",
                "Öğle: Izgara tavuk/balık ve büyük porsiyon salata",
                "Ara: 1 avuç badem, şekersiz yeşil çay (Metabolizma destekleyici)",
                "Akşam: Fırınlanmış et ve zeytinyağlı sebze yemeği"
            ]
        elif goal == 'lose' and is_high_fat:
            plan = [
                "Sabah: Yüksek proteinli yumurta beyazı omleti, bol yeşillik",
                "Öğle: Sadece ızgara protein (Tavuk/Hindi) ve brokoli/kuşkonmaz",
                "Ara: Yoğurt veya kefir",
                "Akşam: Izgara balık ve bol limonlu mevsim salata"
            ]
        elif goal == 'lose':
            plan = [
                "Sabah: Yulaf ezmesi, protein tozu/organik yumurta, orman meyvesi",
                "Öğle: Izgara tavuk göğsü, lifli sebze, az miktar kinoa",
                "Ara: Lor peyniri veya yoğurt",
                "Akşam: Izgara balık ve fırınlanmış ızgara sebze"
            ]
        elif goal == 'gain' and is_high_fat:
            plan = [
                "Sabah: 2 tam yumurta, 2 beyaz, karabuğday, peynir",
                "Öğle: Et/Tavuk, esmer pirinç veya bulgur (Kontrollü Porsiyon)",
                "Ara: Protein shake",
                "Akşam: Kırmızı et, büyük kase yeşil salata"
            ]
        elif goal == 'gain' and is_low_fat:
            plan = [
                "Sabah: 3 yumurtalı omlet, yulaf, fıstık ezmesi, muz",
                "Öğle: Bol porsiyon et/tavuk, beyaz pirinç pilavı, sebze",
                "Ara: Yüksek kalorili protein shake, avuç kuruyemiş",
                "Akşam: Kırmızı et, patates püresi veya makarna"
            ]
        elif goal == 'gain':
            plan = [
                "Sabah: Yulaf, chia tohumu, 2 tam yumurta",
                "Öğle: Izgara tavuk, bulgur pilavı, yeşillik",
                "Ara: Mevsim meyvesi ve ceviz",
                "Akşam: Yağsız kıyma veya tavuk, tam buğday makarna"
            ]
        else:
            plan = [
                "Sabah: Dengeli kahvaltı (Yumurta, az yağlı beyaz peynir, yeşillik)",
                "Öğle: Dengeli tabak (1/4 Karbonhidrat, 1/4 Protein, 1/2 Sebze)",
                "Ara: Taze meyve veya bir avuç çiğ kuruyemiş",
                "Akşam: Izgara protein ve bol zeytinyağlı mevsim salata"
            ]

        if risk_level == 'Yüksek Risk':
            plan.append("NOT: Şeker, işlenmiş gıda ve trans yağlardan tıbbi sebeplerle tamamen kaçının.")
        elif age > 50:
            plan.append("NOT: Kemik sağlığı için diyetinize fazladan kalsiyum ve D vitamini kaynakları ekleyin.")

        return plan

    def _get_dynamic_workout_plan(self, goal, risk_level, body_fat_pct, lean_mass, age, gender):
        is_male = gender.lower() == 'male'
        is_high_fat = (body_fat_pct > 25.0) if is_male else (body_fat_pct > 32.0)
        is_low_fat = (body_fat_pct < 15.0) if is_male else (body_fat_pct < 22.0)

        if risk_level == 'Yüksek Risk' or age > 65:
            return [
                "Açık Alan Tempolu Yürüyüş|30-40 dk",
                "Yüzme veya Su Jimnastiği|45 dk",
                "Oturarak Eklem ve Mobilite Esnetme|15 dk"
            ]

        if goal == 'lose' and is_high_fat:
            return [
                "Düşük Tempolu Eliptik/Kardiyo (LISS)|45 dk",
                "Tüm Vücut Fonksiyonel Vücut Ağırlığı|30 dk",
                "Tempolu Doğa Yürüyüşü|10.000 adım"
            ]
        elif goal == 'lose':
            return [
                "HIIT (Yüksek Yoğunluklu) Kardiyo|20 dk",
                "Ağırlık - Üst Vücut İtme/Çekme Blokajı|45 dk",
                "Ağırlık - Alt Vücut İzole Egzersizleri|45 dk"
            ]
        elif goal == 'gain' and is_high_fat:
            return [
                "Ağırlık Antrenmanı + Hafif Kardiyo Bitişi|60 dk",
                "Bileşik (Compound) Kaldırışlara Odaklanma|4x8 Set",
                "Aktif Dinlenme ve Bölgesel Kardiyo|2 Gün"
            ]
        elif goal == 'gain' and is_low_fat:
            return [
                "Ağır Squat/Deadlift Odaklı Çalışma|5x5 Set",
                "Hipertrofi (Kas Büyütme) Üst Vücut|45-60 dk",
                "Bölgesel İzole Ağırlık Antrenmanı|4 Gün Şiddetli"
            ]
        elif goal == 'gain':
            return [
                "Tüm Vücut Orta Yoğunluk Ağırlık Antrenmanı|3 Gün",
                "Düşük Tempolu Kardiyo (Kalp Sağlığı)|20 dk",
                "Esneklik ve Mobilite Setleri|15 dk"
            ]
        else:
            return [
                "Fonksiyonel Fitness (Crossfit tarzı karma)|45 dk",
                "Dengeli Koşu veya Orta Tempo Bisiklet|30-40 dk",
                "Haftalık Yoga veya Pilates Stabilizasyonu|45 dk"
            ]
