import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_tip.dart';

class TipsService {
  static const String tipsKey = 'daily_tips';
  static const String lastTipDateKey = 'last_tip_date';

  // Singleton pattern
  static final TipsService _instance = TipsService._internal();
  factory TipsService() => _instance;
  TipsService._internal();

  // Get today's tip based on pregnancy week and current date
  Future<DailyTip> getTodaysTip({int pregnancyWeek = 0}) async {
    final allTips = await getAllTips();
    final today = DateTime.now();
    
    // Filter tips suitable for current pregnancy week or general tips
    final suitableTips = allTips.where((tip) => 
        tip.pregnancyWeek <= pregnancyWeek + 2 && 
        tip.pregnancyWeek >= pregnancyWeek - 2
    ).toList();
    
    if (suitableTips.isEmpty) {
      // Fallback to general tips if no week-specific tips
      final generalTips = allTips.where((tip) => tip.pregnancyWeek == 0).toList();
      if (generalTips.isNotEmpty) {
        return generalTips[today.day % generalTips.length];
      }
      // Last fallback - return first tip
      return allTips.isNotEmpty ? allTips[0] : _getDefaultTip();
    }
    
    // Use day of year to rotate through suitable tips
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
    return suitableTips[dayOfYear % suitableTips.length];
  }

  // Get all tips for a specific pregnancy week
  Future<List<DailyTip>> getTipsForWeek(int pregnancyWeek) async {
    final allTips = await getAllTips();
    return allTips.where((tip) => 
        tip.pregnancyWeek == pregnancyWeek || tip.pregnancyWeek == 0
    ).toList();
  }

  // Get tips by category
  Future<List<DailyTip>> getTipsByCategory(String category) async {
    final allTips = await getAllTips();
    return allTips.where((tip) => tip.category == category).toList();
  }

  // Get all available tips
  Future<List<DailyTip>> getAllTips() async {
    final prefs = await SharedPreferences.getInstance();
    final tipsData = prefs.getString(tipsKey);
    
    if (tipsData == null) {
      // Initialize with default tips if none exist
      await _initializeDefaultTips();
      return await getAllTips();
    }
    
    final List<dynamic> json = jsonDecode(tipsData);
    return json.map((tipMap) => DailyTip.fromMap(tipMap)).toList();
  }

  // Save tips to storage
  Future<bool> _saveTips(List<DailyTip> tips) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tipsData = jsonEncode(tips.map((tip) => tip.toMap()).toList());
      await prefs.setString(tipsKey, tipsData);
      return true;
    } catch (e) {

      return false;
    }
  }

  // Initialize default tips
  Future<void> _initializeDefaultTips() async {
    final defaultTips = [
      // General tips (week 0)
      DailyTip(
        id: 1,
        title: 'Stay Hydrated',
        description: 'Drink at least 8 glasses of water today to support your health and baby\'s development.',
        category: 'Health',
        pregnancyWeek: 0,
        imageAsset: 'assets/tip.png',
        keyPoints: [
          'Aim for 8-10 glasses of water daily',
          'Add lemon or cucumber for variety',
          'Monitor your urine color - pale yellow is ideal',
          'Increase intake during hot weather or exercise'
        ],
        fullContent: '''
Staying properly hydrated during pregnancy is crucial for both you and your baby's health. Water helps form the amniotic fluid that surrounds your baby, aids in nutrient transport, and helps prevent common pregnancy discomforts like constipation and swelling.

**Benefits of Proper Hydration:**
• Supports increased blood volume during pregnancy
• Helps prevent urinary tract infections
• Reduces morning sickness symptoms
• Prevents overheating and fatigue
• Supports healthy amniotic fluid levels

**Tips for Staying Hydrated:**
• Keep a water bottle with you at all times
• Set reminders on your phone to drink water
• Eat water-rich foods like watermelon, cucumber, and oranges
• Limit caffeine as it can be dehydrating
• If plain water is unappealing, try herbal teas or infused water

Remember, if you're experiencing excessive thirst, frequent urination, or signs of dehydration, consult your healthcare provider immediately.
        ''',
        createdAt: DateTime.now(),
      ),

      DailyTip(
        id: 2,
        title: 'Prenatal Vitamins',
        description: 'Take your prenatal vitamins with food to reduce nausea and maximize absorption.',
        category: 'Nutrition',
        pregnancyWeek: 0,
        imageAsset: 'assets/tip.png',
        keyPoints: [
          'Take with food to reduce stomach upset',
          'Folic acid prevents birth defects',
          'Iron supports increased blood volume',
          'Consistency is key - take daily'
        ],
        fullContent: '''
Prenatal vitamins are essential supplements that help fill nutritional gaps during pregnancy. They provide crucial nutrients that support your baby's development and maintain your health throughout pregnancy.

**Key Nutrients in Prenatal Vitamins:**
• **Folic Acid (400-800 mcg):** Prevents neural tube defects
• **Iron (27 mg):** Supports increased blood volume and prevents anemia
• **Calcium (1000 mg):** Essential for baby's bone and tooth development
• **DHA:** Supports brain and eye development
• **Vitamin D:** Helps calcium absorption and bone health

**Best Practices:**
• Take with a meal to improve absorption and reduce nausea
• If iron causes constipation, increase fiber and water intake
• Don't double up if you miss a dose
• Store in a cool, dry place away from children
• Continue throughout breastfeeding

Talk to your healthcare provider about the best prenatal vitamin for your specific needs, especially if you have dietary restrictions or allergies.
        ''',
        createdAt: DateTime.now(),
      ),

      // First trimester tips (weeks 4-12)
      DailyTip(
        id: 3,
        title: 'Managing Morning Sickness',
        description: 'Try eating small, frequent meals and keep crackers by your bedside to help with nausea.',
        category: 'Health',
        pregnancyWeek: 8,
        imageAsset: 'assets/tip.png',
        keyPoints: [
          'Eat small, frequent meals every 2-3 hours',
          'Keep crackers or dry toast nearby',
          'Try ginger tea or ginger candies',
          'Avoid strong smells and triggers'
        ],
        fullContent: '''
Morning sickness affects up to 80% of pregnant women, typically starting around week 6 and improving by week 12-14. Despite its name, nausea can occur at any time of day.

**Natural Remedies:**
• **Ginger:** Tea, candies, or supplements (consult your doctor first)
• **Vitamin B6:** May help reduce nausea (with medical approval)
• **Acupressure:** P6 point on wrists (sea-sickness bands)
• **Fresh air:** Step outside or open windows
• **Rest:** Fatigue can worsen nausea

**Dietary Strategies:**
• Eat before you feel hungry
• Choose bland, easy-to-digest foods
• Cold foods may be better tolerated than hot foods
• Separate liquids from solids
• Avoid greasy, spicy, or strong-smelling foods

**When to Call Your Doctor:**
• Vomiting more than 3-4 times per day
• Unable to keep food or fluids down for 24 hours
• Signs of dehydration (dark urine, dizziness, dry mouth)
• Weight loss of more than 2 pounds

Remember, morning sickness is usually a sign of a healthy pregnancy due to rising hormone levels.
        ''',
        createdAt: DateTime.now(),
      ),

      DailyTip(
        id: 4,
        title: 'First Prenatal Visit',
        description: 'Schedule your first prenatal appointment between 8-10 weeks to confirm pregnancy and start proper care.',
        category: 'Medical',
        pregnancyWeek: 8,
        imageAsset: 'assets/tip.png',
        keyPoints: [
          'Schedule between weeks 8-10',
          'Bring list of medications and supplements',
          'Prepare family medical history',
          'Write down questions beforehand'
        ],
        fullContent: '''
Your first prenatal visit is an important milestone that establishes your pregnancy care plan. This comprehensive appointment typically lasts 45-60 minutes and covers many important topics.

**What to Expect:**
• **Medical History:** Current health, past pregnancies, family history
• **Physical Exam:** Blood pressure, weight, pelvic exam
• **Blood Tests:** Blood type, Rh factor, hemoglobin, STD screening
• **Urine Test:** Protein, glucose, bacteria screening
• **Dating Ultrasound:** Confirm due date and check baby's development

**What to Bring:**
• List of current medications and supplements
• Insurance cards and identification
• Partner or support person if desired
• List of questions and concerns
• Menstrual history and previous pregnancy records

**Questions to Ask:**
• What foods should I avoid?
• Is my current exercise routine safe?
• What symptoms should I be concerned about?
• How often will I have appointments?
• What prenatal testing options are available?

**Important Discussions:**
• Nutrition and weight gain goals
• Prenatal vitamin recommendations
• Lifestyle modifications (smoking, alcohol, caffeine)
• Work and travel considerations
• Warning signs to watch for

This visit establishes the foundation for your prenatal care, so don't hesitate to ask questions or express concerns.
        ''',
        createdAt: DateTime.now(),
      ),

      // Second trimester tips (weeks 13-27)
      DailyTip(
        id: 5,
        title: 'Gentle Exercise',
        description: 'Light exercise like walking or prenatal yoga can boost energy and prepare your body for delivery.',
        category: 'Fitness',
        pregnancyWeek: 16,
        imageAsset: 'assets/tip.png',
        keyPoints: [
          'Aim for 30 minutes of moderate activity daily',
          'Walking is safe and beneficial',
          'Try prenatal yoga or swimming',
          'Listen to your body and rest when needed'
        ],
        fullContent: '''
Regular exercise during pregnancy offers numerous benefits for both you and your baby. The second trimester is often the best time to establish or maintain an exercise routine.

**Benefits of Prenatal Exercise:**
• Improved mood and energy levels
• Better sleep quality
• Reduced back pain and constipation
• Lower risk of gestational diabetes
• Easier labor and delivery
• Faster postpartum recovery

**Safe Exercise Options:**
• **Walking:** Low-impact, easy to adjust intensity
• **Swimming:** Supports body weight, reduces joint stress
• **Prenatal Yoga:** Improves flexibility and relaxation
• **Stationary Cycling:** Good cardio with back support
• **Light Weight Training:** Maintains muscle strength

**Exercise Guidelines:**
• Get clearance from your healthcare provider first
• Start slowly if you're new to exercise
• Stay hydrated and avoid overheating
• Wear supportive shoes and clothing
• Avoid contact sports and high-risk activities

**Warning Signs to Stop:**
• Chest pain or shortness of breath
• Dizziness or fainting
• Headache or muscle weakness
• Calf pain or swelling
• Decreased fetal movement
• Preterm labor signs

**Activities to Avoid:**
• High-altitude activities (above 6,000 feet)
• Contact sports (soccer, basketball, hockey)
• Activities with fall risk (skiing, horseback riding)
• Hot yoga or exercising in high heat
• Lying flat on your back after first trimester

Remember, pregnancy is not the time to start intense new workouts, but maintaining fitness can greatly benefit your pregnancy journey.
        ''',
        createdAt: DateTime.now(),
      ),

      DailyTip(
        id: 6,
        title: 'Baby Movement',
        description: 'You might start feeling your baby move between 16-25 weeks. These first movements feel like flutters or bubbles.',
        category: 'Development',
        pregnancyWeek: 20,
        imageAsset: 'assets/baby.png',
        keyPoints: [
          'First movements feel like flutters or gas bubbles',
          'More noticeable when you\'re still and quiet',
          'Frequency increases as baby grows',
          'Each baby has their own movement pattern'
        ],
        fullContent: '''
Feeling your baby move for the first time is one of pregnancy's most exciting milestones. These first movements, called "quickening," typically occur between 16-25 weeks.

**Timeline of Movement:**
• **16-20 weeks:** First-time moms may feel movement
• **18-22 weeks:** Movements become more regular
• **24-28 weeks:** Distinct kicks and punches
• **28+ weeks:** Strong, regular movement patterns

**What Movements Feel Like:**
• **Early:** Flutters, bubbles, or popping sensations
• **Later:** Distinct kicks, rolls, and stretches
• **Third Trimester:** Strong movements that may be visible

**When You're Most Likely to Feel Movement:**
• When lying down or sitting quietly
• After eating or drinking something sweet
• In the evening when you're relaxed
• During the night (babies are often more active)

**Factors Affecting Movement Perception:**
• **Placenta location:** Front-placed placenta may muffle movements
• **Body weight:** May affect how easily movements are felt
• **Activity level:** You may miss movements when busy
• **First vs. subsequent pregnancies:** Experience helps recognition

**What's Normal:**
• Gradual increase in movement frequency and strength
• Periods of activity followed by quiet periods
• Different movement patterns for each baby
• Less space for big movements in third trimester

**When to Contact Your Provider:**
• Significant decrease in movement after 28 weeks
• No movement for 24 hours after usually feeling regular movement
• Sudden, dramatic change in movement pattern
• Concerns about your baby's well-being

Remember, every baby is different, and movement patterns vary greatly between pregnancies.
        ''',
        createdAt: DateTime.now(),
      ),

      // Third trimester tips (weeks 28-40)
      DailyTip(
        id: 7,
        title: 'Birth Plan Preparation',
        description: 'Start thinking about your birth preferences and discuss them with your healthcare provider.',
        category: 'Preparation',
        pregnancyWeek: 32,
        imageAsset: 'assets/tip.png',
        keyPoints: [
          'Consider your pain management preferences',
          'Think about who you want present',
          'Discuss options with your healthcare team',
          'Remember to stay flexible'
        ],
        fullContent: '''
A birth plan is a document that outlines your preferences for labor and delivery. While you can't control everything about birth, having a plan helps communicate your wishes to your healthcare team.

**Key Areas to Consider:**

**Labor Environment:**
• Where do you want to give birth? (hospital, birth center, home)
• Who do you want present during labor and delivery?
• What atmosphere would you prefer? (lighting, music, aromatherapy)
• Do you want freedom to move around during labor?

**Pain Management:**
• Do you want to try natural pain relief first?
• Are you open to epidural or other medications?
• Would you like to use alternative methods? (massage, hydrotherapy, breathing techniques)
• What's your backup plan if your first choice isn't available?

**Medical Interventions:**
• Under what circumstances would you accept interventions?
• How do you feel about continuous fetal monitoring?
• What are your preferences regarding episiotomy?
• How do you feel about assisted delivery (forceps, vacuum)?

**Delivery Preferences:**
• What positions would you like to try for pushing?
• Do you want to see the birth or touch baby's head?
• Who would you like to cut the umbilical cord?
• Do you want immediate skin-to-skin contact?

**Postpartum Care:**
• Do you want to try breastfeeding immediately?
• How do you feel about routine newborn procedures?
• Do you want the baby to room-in with you?
• Are there any religious or cultural considerations?

**Emergency Situations:**
• What are your preferences if a C-section becomes necessary?
• Who should make decisions if you're unable to?
• What are your wishes for baby care if complications arise?

**Tips for Creating Your Birth Plan:**
• Keep it concise (1-2 pages maximum)
• Use positive language ("I would like..." instead of "I don't want...")
• Discuss with your healthcare provider and hospital staff
• Bring copies to all appointments and pack extras in your hospital bag
• Remember that flexibility is important - birth can be unpredictable

**Remember:** Birth plans are guides, not contracts. The most important outcome is the health and safety of you and your baby. Stay open to changes if medical circumstances require different approaches.
        ''',
        createdAt: DateTime.now(),
      ),

      DailyTip(
        id: 8,
        title: 'Hospital Bag Packing',
        description: 'Pack your hospital bag by 36 weeks with essentials for you, your partner, and your baby.',
        category: 'Preparation',
        pregnancyWeek: 36,
        imageAsset: 'assets/tip.png',
        keyPoints: [
          'Pack by 36 weeks in case of early labor',
          'Include comfortable going-home outfits',
          'Don\'t forget phone chargers and snacks',
          'Pack baby\'s going-home outfit in newborn and 0-3 month sizes'
        ],
        fullContent: '''
Having your hospital bag packed and ready gives you peace of mind as you approach your due date. Aim to have everything ready by 36 weeks.

**For Mom - Labor and Delivery:**
• Comfortable nightgowns or labor gowns (front-opening for breastfeeding)
• Robe and slippers with good grip
• Comfortable underwear you don't mind discarding (or disposable)
• Nursing bras (2-3, one size larger than current)
• Hair ties and headband
• Lip balm and basic toiletries
• Glasses/contacts and case
• Any medications you take regularly

**For Mom - Recovery:**
• Comfortable going-home outfit (maternity size)
• Extra nursing bras and breast pads
• Comfortable pajamas or nightgowns
• Maternity pads (though hospital usually provides)
• Stool softener (if recommended by doctor)
• Nipple cream for breastfeeding
• Comfortable, supportive shoes

**For Baby:**
• Going-home outfit in newborn AND 0-3 month sizes
• Receiving blankets (2-3)
• Newborn diapers (though hospital provides)
• Burp cloths
• Infant car seat (properly installed!)
• Hat and mittens
• Swaddle blankets

**For Partner/Support Person:**
• Change of clothes for 2-3 days
• Comfortable shoes
• Toiletries and medications
• Pillow with colored pillowcase (so it doesn't get mixed up)
• Snacks and drinks
• Phone charger
• Camera or video camera
• List of people to call with birth announcement

**Important Documents and Items:**
• Hospital pre-registration paperwork
• Insurance cards and ID
• Birth plan copies
• Pediatrician contact information
• Phone and charger with extra-long cord
• Cash for parking and vending machines

**Comfort Items:**
• Your own pillow (with colored case)
• Favorite blanket
• Music playlist and speaker
• Essential oils or aromatherapy (check hospital policy)
• Massage oils or tools
• Books or magazines
• Snacks for after delivery

**Don't Forget:**
• Car seat installation inspection
• Know the route to the hospital and where to park
• Have backup childcare arranged for other children
• Prepare frozen meals for when you return home

**Hospital Usually Provides:**
• Basic toiletries
• Mesh underwear and pads
• Baby diapers and wipes
• Receiving blankets
• Basic baby clothes
• Breast pump (if needed)

Pack your bag in a wheeled suitcase or large tote bag, and keep it easily accessible. Let your partner know where everything is located so they can grab it quickly when labor begins.
        ''',
        createdAt: DateTime.now(),
      ),

      // Nutrition tips
      DailyTip(
        id: 9,
        title: 'Healthy Pregnancy Snacks',
        description: 'Choose nutrient-dense snacks like nuts, yogurt, fruits, and whole grains to fuel your pregnancy.',
        category: 'Nutrition',
        pregnancyWeek: 0,
        imageAsset: 'assets/tip.png',
        keyPoints: [
          'Combine protein with complex carbs',
          'Include healthy fats for baby\'s brain development',
          'Choose whole, unprocessed foods',
          'Keep healthy snacks easily accessible'
        ],
        fullContent: '''
Healthy snacking during pregnancy helps maintain steady blood sugar levels, provides essential nutrients, and can help manage pregnancy symptoms like nausea and heartburn.

**Protein-Rich Snacks:**
• Greek yogurt with berries and granola
• Hard-boiled eggs with whole grain crackers
• Cheese and apple slices
• Hummus with vegetables
• Nuts and seeds (almonds, walnuts, sunflower seeds)
• Cottage cheese with fruit

**Iron-Rich Options:**
• Dried fruits (apricots, raisins) with nuts
• Spinach and cheese quesadilla
• Beef jerky (low sodium)
• Fortified cereals with milk
• Dark chocolate with nuts

**Calcium-Rich Choices:**
• Yogurt parfait with granola
• Cheese and whole grain crackers
• Smoothie with milk and leafy greens
• Sesame seed snacks
• Sardines on toast

**Folate-Rich Snacks:**
• Avocado toast on whole grain bread
• Orange slices with yogurt
• Asparagus wrapped in turkey
• Fortified cereals
• Edamame

**Healthy Fats for Brain Development:**
• Avocado with lime and sea salt
• Trail mix with nuts and seeds
• Nut butter with apple slices
• Olives and cheese
• Chia seed pudding

**Energy-Boosting Combinations:**
• Banana with almond butter
• Date stuffed with cream cheese and walnuts
• Whole grain toast with avocado and egg
• Smoothie with spinach, banana, and protein powder
• Oatmeal with nuts and fruit

**For Morning Sickness:**
• Plain crackers or pretzels
• Ginger snaps or ginger tea
• Peppermint tea with honey
• Bland fruits like bananas or applesauce
• Cold foods that don't have strong smells

**For Heartburn:**
• Small portions throughout the day
• Avoid spicy, fatty, or acidic foods
• Try cold milk or yogurt
• Eat slowly and chew thoroughly
• Avoid lying down immediately after eating

**Snacking Tips:**
• Keep healthy snacks visible and accessible
• Prepare snacks in advance when you have energy
• Listen to your hunger cues
• Stay hydrated - sometimes thirst feels like hunger
• Choose whole foods over processed when possible

**Foods to Limit or Avoid:**
• High-mercury fish
• Raw or undercooked meats and eggs
• Unpasteurized dairy products
• Excessive caffeine
• Alcohol
• High-sugar, low-nutrient snacks

Remember, pregnancy is not the time for restrictive dieting. Focus on nourishing yourself and your baby with a variety of healthy, delicious foods.
        ''',
        createdAt: DateTime.now(),
      ),

      DailyTip(
        id: 10,
        title: 'Sleep Comfort Tips',
        description: 'Use pillows to support your growing belly and try sleeping on your left side for better circulation.',
        category: 'Health',
        pregnancyWeek: 24,
        imageAsset: 'assets/tip.png',
        keyPoints: [
          'Sleep on your left side when possible',
          'Use pregnancy pillow for support',
          'Elevate your head if experiencing heartburn',
          'Create a relaxing bedtime routine'
        ],
        fullContent: '''
Getting quality sleep during pregnancy can be challenging as your body changes and grows. These strategies can help improve your sleep comfort and quality.

**Best Sleep Positions:**
• **Left side sleeping:** Improves blood flow to baby and reduces swelling
• **Avoid back sleeping:** Especially after 20 weeks, can reduce blood flow
• **Use pillows for support:** Between knees, under belly, behind back

**Pregnancy Pillow Options:**
• **Wedge pillow:** Small, portable support for belly or back
• **Full-body pillow:** C-shaped or U-shaped for total body support
• **Between-the-legs pillow:** Keeps hips aligned and reduces back pain
• **Multiple regular pillows:** Budget-friendly option for support

**Managing Common Sleep Disruptors:**

**Heartburn:**
• Eat dinner 2-3 hours before bedtime
• Sleep with head elevated 6-8 inches
• Avoid spicy, fatty, or acidic foods
• Try sleeping on your left side

**Frequent Urination:**
• Drink plenty of water during the day
• Reduce fluid intake 2 hours before bed
• Empty bladder completely before sleep
• Use a nightlight to avoid fully waking up

**Leg Cramps:**
• Stretch calves before bed
• Stay hydrated throughout the day
• Consider magnesium supplement (with doctor approval)
• Wear support stockings during the day

**Restless Legs:**
• Gentle leg stretches before bed
• Warm bath or heating pad on legs
• Avoid caffeine, especially in afternoon
• Iron deficiency screening if severe

**Anxiety and Racing Thoughts:**
• Practice relaxation techniques
• Keep a journal by bedside for worries
• Try prenatal meditation or yoga
• Discuss concerns with healthcare provider

**Creating a Sleep-Friendly Environment:**
• Keep bedroom cool (65-68°F)
• Use blackout curtains or eye mask
• White noise machine or earplugs
• Comfortable, supportive mattress
• Remove electronic devices from bedroom

**Bedtime Routine Ideas:**
• Warm (not hot) bath with Epsom salts
• Gentle prenatal yoga or stretching
• Reading or listening to calming music
• Herbal tea (pregnancy-safe varieties)
• Progressive muscle relaxation
• Prenatal massage from partner

**When to Seek Help:**
• Persistent insomnia affecting daily function
• Sleep apnea symptoms (snoring, gasping)
• Severe restless leg syndrome
• Depression or anxiety affecting sleep
• Concerns about sleep position and baby's health

**Sleep Safety Tips:**
• Avoid sleep medications unless approved by doctor
• Don't use heating pads on high heat
• Be cautious with essential oils - some aren't pregnancy-safe
• If you wake up on your back, don't panic - just roll to your side

Remember, some sleep disruption is normal during pregnancy. Focus on rest when possible, and don't hesitate to nap during the day if needed.
        ''',
        createdAt: DateTime.now(),
      ),
    ];

    await _saveTips(defaultTips);
  }

  // Get a default tip if none are available
  DailyTip _getDefaultTip() {
    return DailyTip(
      id: 0,
      title: 'Welcome to Your Pregnancy Journey',
      description: 'Take care of yourself and your growing baby with proper nutrition, rest, and regular prenatal care.',
      category: 'General',
      pregnancyWeek: 0,
      imageAsset: 'assets/tip.png',
      keyPoints: [
        'Schedule regular prenatal appointments',
        'Take prenatal vitamins daily',
        'Eat a balanced, nutritious diet',
        'Stay active with doctor-approved exercise'
      ],
      fullContent: 'Welcome to your pregnancy journey! This is an exciting time filled with growth and changes. Remember to take care of yourself with proper nutrition, regular prenatal care, and adequate rest.',
      createdAt: DateTime.now(),
    );
  }

  // Add a custom tip
  Future<bool> addTip(DailyTip tip) async {
    try {
      final tips = await getAllTips();
      final newTip = tip.copyWith(id: tips.length + 1);
      tips.add(newTip);
      return await _saveTips(tips);
    } catch (e) {

      return false;
    }
  }

  // Get tip categories
  Future<List<String>> getCategories() async {
    final tips = await getAllTips();
    final categories = tips.map((tip) => tip.category).toSet().toList();
    categories.sort();
    return categories;
  }
}
