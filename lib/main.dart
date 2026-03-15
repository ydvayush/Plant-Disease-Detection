import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

// Use an enum for type-safe crop selection
enum Crop {
  wheat,
  rice,
  tomato,
  mustard,
  addMore,
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// A simple localization class to hold our language strings.
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'app_title': 'LeafLens',
      'pick_from_gallery': 'Pick Image from Gallery',
      'take_from_camera': 'Take Photo from Camera',
      'analyze_leaf': 'Analyze Leaf',
      'no_image_selected': 'No image selected.',
      'failed_to_pick': 'Failed to pick image: ',
      'analyze_pressed': 'Analyze button pressed!',
      'weather_title': 'Local Weather',
      'location_hint': 'Enter city or PIN code',
      'get_weather': 'Get Weather',
      'location': 'Location',
      'temperature': 'Temperature',
      'humidity': 'Humidity',
      'condition': 'Condition',
      'weather_error': 'Failed to get weather data.',
      'weather_info': 'Weather and environmental data for your location.',
      'select_crop': 'Select a Crop',
      'fertilizer_calculator': 'Fertilizer Calculator',
      'pests_and_diseases': 'Pests & Diseases',
      'cultivation_tips': 'Cultivation Tips',
      'wheat': 'Wheat',
      'rice': 'Rice',
      'tomato': 'Tomato',
      'mustard': 'Mustard',
      'add_more': 'Add More',
      'loading': 'Loading...',
      'logout': 'Logout',
      'area_hint': 'Enter field area in acres',
      'fertilizer_type': 'Select Fertilizer Type',
      'calculate': 'Calculate',
      'urea_label': 'Urea',
      'dap_label': 'DAP',
      'mop_label': 'MOP',
      'result_label': 'You need to apply:',
      'no_data_for_crop': 'No specific data for this crop yet.',
      'select_fertilizer_type': 'Please select a fertilizer type.',
      'enter_area': 'Please enter a valid area.',
      'tips_title': 'Cultivation Tips for',
      'tips_wheat': 'Wheat tips:\n\n- **Planting:** Sow seeds at the right depth (2-3 inches) in well-drained, fertile soil.\n- **Irrigation:** Maintain consistent soil moisture, especially during the crown root initiation (CRI) stage and grain filling. Avoid waterlogging.\n- **Fertilizer:** Apply a balanced fertilizer, typically a mix of Urea, DAP, and MOP, based on soil test results. Apply half of the nitrogen at sowing and the rest in two splits.\n- **Weed Control:** Control weeds early with pre-emergence herbicides to prevent competition for nutrients.',
      'tips_rice': 'Rice tips:\n\n- **Planting:** Start with healthy seedlings. For transplanting, ensure proper spacing (20cm x 20cm).\n- **Water Management:** Rice requires significant water. Maintain a consistent water level of 2-5 cm in the field. Drain the field before harvesting.\n- **Fertilizer:** Use a balanced NPK fertilizer. Apply Nitrogen in splits to maximize absorption. Incorporate organic manure for better soil health.\n- **Pest & Disease Control:** Monitor for common pests like stem borers and diseases like blast. Use appropriate pesticides and fungicides as needed.',
      'tips_tomato': 'Tomato tips:\n\n- **Soil:** Plant in a sunny location with loose, well-drained soil. Amend the soil with compost for nutrients.\n- **Watering:** Water consistently and deeply. Avoid overhead watering to prevent leaf diseases. Drip irrigation is highly recommended.\n- **Support:** Use stakes or cages to support the plant as it grows. This keeps the fruit off the ground and improves air circulation.\n- **Pruning:** Prune lower leaves to prevent soil-borne diseases. Remove suckers to direct energy to the main plant.',
      'tips_mustard': 'Mustard tips:\n\n- **Planting:** Plant in cool weather with good sunlight. Use certified seeds for better yield.\n- **Watering:** Mustard is a low-water crop. Water once at sowing and then as needed, especially at the flowering and pod formation stages.\n- **Fertilizer:** Apply a basal dose of NPK. A top dressing of Urea can be done after the first irrigation.\n- **Pest Management:** Regularly inspect for aphids, a common pest. Use neem oil or other organic insecticides for control.',
      'pnd_title': 'Pests & Diseases for',
      'pnd_wheat': 'Wheat Pests & Diseases:\n\n- **Aphids:** Small, soft-bodied insects that suck sap from leaves and stems. They can cause stunted growth. **Control:** Use a strong spray of water or apply neem oil.\n- **Rust (Fungal Disease):** Causes reddish-brown to orange pustules on leaves. **Control:** Use rust-resistant varieties and apply fungicides early in the season.\n- **Loose Smut (Fungal Disease):** Replaces grains with a black, powdery mass. **Control:** Use certified, disease-free seeds and apply seed treatment before sowing.',
      'pnd_rice': 'Rice Pests & Diseases:\n\n- **Stem Borer (Pest):** Larvae bore into the rice stem, causing "dead hearts" (withered central shoots) or "white heads" (empty grains). **Control:** Use systemic insecticides and practice field sanitation.\n- **Leaf Folder (Pest):** Larvae fold leaves and feed inside, causing white streaks. **Control:** Use contact insecticides and conserve natural predators like spiders.\n- **Rice Blast (Fungal Disease):** Causes diamond-shaped lesions on leaves and neck rot on the panicle. **Control:** Plant resistant varieties, and apply appropriate fungicides as recommended.',
      'pnd_tomato': 'Tomato Pests & Diseases:\n\n- **Whiteflies (Pest):** Tiny white insects on the underside of leaves that transmit viruses. **Control:** Use yellow sticky traps and apply insecticidal soap.\n- **Early Blight (Fungal Disease):** Causes dark spots with concentric rings on lower leaves. **Control:** Remove infected leaves and use copper-based fungicides.\n- **Bacterial Spot (Bacterial Disease):** Leads to small, water-soaked spots on leaves and fruit. **Control:** Use copper-based sprays and ensure good air circulation.',
      'pnd_mustard': 'Mustard Pests & Diseases:\n\n- **Aphids (Pest):** Common and damaging pest. They cluster on stems and pods, sucking sap. **Control:** Spray with insecticidal soap or neem oil at the first sign of infestation.\n- **Alternaria Blight (Fungal Disease):** Causes dark, concentric spots on leaves and pods. **Control:** Rotate crops, use resistant varieties, and apply fungicides as a preventative measure.\n- **White Rust (Fungal Disease):** Appears as white, raised pustules on the underside of leaves. **Control:** Remove and destroy infected plants, and apply fungicides.',
      'login_title': 'Login to LeafLens',
      'signup_title': 'Sign Up for LeafLens',
      'email_hint': 'Email',
      'password_hint': 'Password',
      'confirm_password_hint': 'Confirm Password',
      'login_button': 'Login',
      'signup_button': 'Sign Up',
      'no_account': 'Don\'t have an account?',
      'has_account': 'Already have an account?',
      'invalid_email': 'Please enter a valid email.',
      'password_too_short': 'Password must be at least 6 characters.',
      'passwords_not_match': 'Passwords do not match.',
      'login_success': 'Login successful!',
      'signup_success': 'Account created successfully!',
      'login_failed': 'Login failed. Please check your credentials.',
      'signup_failed': 'Signup failed. Please try again.',
    },
    'hi': {
      'app_title': 'लीफलेंस',
      'pick_from_gallery': 'गैलरी से छवि चुनें',
      'take_from_camera': 'कैमरे से फोटो लें',
      'analyze_leaf': 'पत्ती का विश्लेषण करें',
      'no_image_selected': 'कोई छवि नहीं चुनी गई है।',
      'failed_to_pick': 'छवि चुनने में विफल: ',
      'analyze_pressed': 'विश्लेषण बटन दबाया गया!',
      'weather_title': 'स्थानीय मौसम',
      'location_hint': 'शहर या पिन कोड दर्ज करें',
      'get_weather': 'मौसम प्राप्त करें',
      'location': 'स्थान',
      'temperature': 'तापमान',
      'humidity': 'नमी',
      'condition': 'स्थिति',
      'weather_error': 'मौसम डेटा प्राप्त करने में विफल।',
      'weather_info': 'आपके स्थान के लिए मौसम और पर्यावरणीय डेटा।',
      'select_crop': 'एक फसल चुनें',
      'fertilizer_calculator': 'उर्वरक कैलकुलेटर',
      'pests_and_diseases': 'कीट और रोग',
      'cultivation_tips': 'खेती के टिप्स',
      'wheat': 'गेहूं',
      'rice': 'चावल',
      'tomato': 'टमाटर',
      'mustard': 'सरसों',
      'add_more': 'और जोड़ें',
      'loading': 'लोड हो रहा है...',
      'logout': 'लॉग आउट',
      'area_hint': 'खेत का क्षेत्रफल एकड़ में दर्ज करें',
      'fertilizer_type': 'उर्वरक का प्रकार चुनें',
      'calculate': 'गणना करें',
      'urea_label': 'यूरिया',
      'dap_label': 'डीएपी',
      'mop_label': 'एमओपी',
      'result_label': 'आपको लागू करने की आवश्यकता है:',
      'no_data_for_crop': 'इस फसल के लिए अभी कोई विशेष डेटा नहीं है।',
      'select_fertilizer_type': 'कृपया उर्वरक का प्रकार चुनें।',
      'enter_area': 'कृपया एक वैध क्षेत्र दर्ज करें।',
      'tips_title': 'खेती के टिप्स',
      'tips_wheat': 'गेहूं की खेती के टिप्स:\n\n- **बुआई:** बीजों को सही गहराई (2-3 इंच) पर अच्छी जल निकासी वाली, उपजाऊ मिट्टी में बोएं।\n- **सिंचाई:** खासकर सीआरआई (क्राउन रूट इनिशिएशन) चरण और दाना भरने के दौरान मिट्टी की नमी को बनाए रखें। पानी जमा होने से बचें।\n- **उर्वरक:** मिट्टी परीक्षण के परिणामों के आधार पर यूरिया, डीएपी और एमओपी का संतुलित मिश्रण डालें। आधी नाइट्रोजन बुआई के समय और बाकी दो बार में डालें।\n- **खरपतवार नियंत्रण:** पोषक तत्वों के लिए प्रतिस्पर्धा को रोकने के लिए प्री-इमर्जेंस हर्बिसाइड्स का उपयोग करके खरपतवारों को जल्दी नियंत्रित करें।',
      'tips_rice': 'चावल की खेती के टिप्स:\n\n- **रोपाई:** स्वस्थ पौधों से शुरुआत करें। रोपाई के लिए उचित दूरी (20cm x 20cm) सुनिश्चित करें।\n- **जल प्रबंधन:** चावल को बहुत अधिक पानी की आवश्यकता होती है। खेत में 2-5 सेमी का जल स्तर बनाए रखें। कटाई से पहले खेत से पानी निकाल दें।\n- **उर्वरक:** संतुलित एनपीके उर्वरक का उपयोग करें। अधिकतम अवशोषण के लिए नाइट्रोजन को कई भागों में डालें। बेहतर मिट्टी स्वास्थ्य के लिए जैविक खाद का उपयोग करें।\n- **कीट और रोग नियंत्रण:** तना छेदक जैसे सामान्य कीटों और ब्लास्ट जैसे रोगों की निगरानी करें। आवश्यकतानुसार उचित कीटनाशकों और फफूंदनाशकों का उपयोग करें।',
      'tips_tomato': 'टमाटर की खेती के टिप्स:\n\n- **मिट्टी:** धूप वाली जगह पर हल्की, अच्छी जल निकासी वाली मिट्टी में लगाएं। पोषक तत्वों के लिए मिट्टी में खाद मिलाएं।\n- **पानी:** लगातार और गहराई से पानी दें। पत्तियों के ऊपर से पानी देने से बचें ताकि पत्तियों के रोग न हों। ड्रिप सिंचाई की अत्यधिक सलाह दी जाती है।\n- **सहारा:** पौधे के बढ़ने पर उसे सहारा देने के लिए डंडे या पिंजरे का उपयोग करें। यह फल को जमीन से दूर रखता है और वायु संचार को बेहतर बनाता है।\n- **छँटाई:** मिट्टी से होने वाले रोगों को रोकने के लिए निचली पत्तियों की छँटाई करें। मुख्य पौधे की ऊर्जा को निर्देशित करने के लिए चूसकों को हटा दें।',
      'tips_mustard': 'सरसों की खेती के टिप्स:\n\n- **बुआई:** अच्छी धूप वाले ठंडे मौसम में बुआई करें। बेहतर उपज के लिए प्रमाणित बीजों का उपयोग करें।\n- **पानी:** सरसों एक कम पानी वाली फसल है। बुआई के समय एक बार पानी दें और फिर आवश्यकतानुसार, खासकर फूल आने और फली बनने के चरणों में।\n- **उर्वरक:** एनपीके की एक बेसल खुराक डालें। पहली सिंचाई के बाद यूरिया की ऊपरी खुराक डाली जा सकती है।\n- **कीट प्रबंधन:** एफिड्स, एक सामान्य कीट, की नियमित रूप से जाँच करें। नियंत्रण के लिए नीम का तेल या अन्य जैविक कीटनाशकों का उपयोग करें।',
      'pnd_title': 'कीट और रोग',
      'pnd_wheat': 'गेहूं के कीट और रोग:\n\n- **एफिड्स (कीट):** छोटे, नरम शरीर वाले कीड़े जो पत्तियों और तनों से रस चूसते हैं। वे विकास को रोक सकते हैं। **नियंत्रण:** पानी की तेज धार का उपयोग करें या नीम का तेल डालें।\n- **रस्ट (फंगल रोग):** पत्तियों पर लाल-भूरे से नारंगी रंग के दाने पैदा करता है। **नियंत्रण:** रस्ट-प्रतिरोधी किस्मों का उपयोग करें और मौसम की शुरुआत में ही फफूंदनाशक डालें।\n- **लूज स्मट (फंगल रोग):** दानों को एक काले, पाउडर वाले द्रव्यमान से बदल देता है। **नियंत्रण:** प्रमाणित, रोग-मुक्त बीजों का उपयोग करें और बुआई से पहले बीज उपचार करें।',
      'pnd_rice': 'चावल के कीट और रोग:\n\n- **तना छेदक (कीट):** लार्वा चावल के तने में छेद करते हैं, जिससे "डेड हार्ट्स" (सूखे केंद्रीय अंकुर) या "व्हाइट हेड्स" (खाली दाने) होते हैं। **नियंत्रण:** प्रणालीगत कीटनाशकों का उपयोग करें और खेत की सफाई का अभ्यास करें।\n- **लीफ फोल्डर (कीट)::** लार्वा पत्तियों को मोड़कर अंदर खाते हैं, जिससे सफेद धारियां बनती हैं। **नियंत्रण:** संपर्क कीटनाशकों का उपयोग करें और मकड़ियों जैसे प्राकृतिक शिकारियों का संरक्षण करें।\n- **चावल ब्लास्ट (फंगल रोग):** पत्तियों पर हीरे के आकार के घाव और पैनिकल पर गर्दन सड़न का कारण बनता है। **नियंत्रण:** प्रतिरोधी किस्मों को लगाएं, और अनुशंसित फफूंदनाशकों का उपयोग करें।',
      'pnd_tomato': 'टमाटर के कीट और रोग:\n\n- **सफेद मक्खी (कीट):** पत्तियों के नीचे की तरफ छोटे सफेद कीड़े जो वायरस फैलाते हैं। **नियंत्रण:** पीले चिपचिपे जालों का उपयोग करें और कीटनाशक साबुन डालें।\n- **अर्ली ब्लाइट (फंगल रोग):** निचली पत्तियों पर संकेंद्रित छल्लों के साथ गहरे धब्बे होते हैं। **नियंत्रण:** संक्रमित पत्तियों को हटा दें और तांबे-आधारित फफूंदनाशकों का उपयोग करें।\n- **बैक्टीरियल स्पॉट (बैक्टीरियल रोग):** पत्तियों और फलों पर छोटे, पानी से भरे धब्बे होते हैं। **नियंत्रण:** तांबे-आधारित स्प्रे का उपयोग करें और अच्छे वायु संचार को सुनिश्चित करें।',
      'pnd_mustard': 'सरसों के कीट और रोग:\n\n- **एफिड्स (कीट):** सामान्य और हानिकारक कीट। वे तनों और फलियों पर चिपक जाते हैं और रस चूसते हैं। **नियंत्रण:** संक्रमण के पहले संकेत पर कीटनाशक साबुन या नीम का तेल स्प्रे करें।\n- **अल्टरनेरिया ब्लाइट (फंगल रोग):** पत्तियों और फलियों पर गहरे, संकेंद्रित धब्बे होते हैं। **नियंत्रण:** फसलों को घुमाकर बोएं, प्रतिरोधी किस्मों का उपयोग करें, और निवारक उपाय के रूप में फफूंदनाशक डालें।\n- **सफेद रस्ट (फंगल रोग):** पत्तियों के नीचे की तरफ सफेद, उभरे हुए दाने दिखाई देते हैं। **नियंत्रण:** संक्रमित पौधों को हटा दें और नष्ट कर दें, और फफूंदनाशकों का उपयोग करें।',
      'login_title': 'लीफलेंस में लॉग इन करें',
      'signup_title': 'लीफलेंस के लिए साइन अप करें',
      'email_hint': 'ईमेल',
      'password_hint': 'पासवर्ड',
      'confirm_password_hint': 'पासवर्ड की पुष्टि करें',
      'login_button': 'लॉग इन करें',
      'signup_button': 'साइन अप करें',
      'no_account': 'खाता नहीं है?',
      'has_account': 'पहले से खाता है?',
      'invalid_email': 'कृपया एक वैध ईमेल दर्ज करें।',
      'password_too_short': 'पासवर्ड कम से कम 6 अक्षरों का होना चाहिए।',
      'passwords_not_match': 'पासवर्ड मेल नहीं खाते।',
      'login_success': 'लॉगिन सफल!',
      'signup_success': 'खाता सफलतापूर्वक बनाया गया!',
      'login_failed': 'लॉगिन विफल। कृपया अपनी क्रेडेंशियल जांचें।',
      'signup_failed': 'साइनअप विफल। कृपया पुनः प्रयास करें।',
    },
  };

  String get appTitle => _localizedValues[locale.languageCode]!['app_title']!;
  String get pickFromGallery => _localizedValues[locale.languageCode]!['pick_from_gallery']!;
  String get takeFromCamera => _localizedValues[locale.languageCode]!['take_from_camera']!;
  String get analyzeLeaf => _localizedValues[locale.languageCode]!['analyze_leaf']!;
  String get noImageSelected => _localizedValues[locale.languageCode]!['no_image_selected']!;
  String get failedToPick => _localizedValues[locale.languageCode]!['failed_to_pick']!;
  String get analyzePressed => _localizedValues[locale.languageCode]!['analyze_pressed']!;
  String get weatherTitle => _localizedValues[locale.languageCode]!['weather_title']!;
  String get locationHint => _localizedValues[locale.languageCode]!['location_hint']!;
  String get getWeather => _localizedValues[locale.languageCode]!['get_weather']!;
  String get location => _localizedValues[locale.languageCode]!['location']!;
  String get temperature => _localizedValues[locale.languageCode]!['temperature']!;
  String get humidity => _localizedValues[locale.languageCode]!['humidity']!;
  String get condition => _localizedValues[locale.languageCode]!['condition']!;
  String get weatherError => _localizedValues[locale.languageCode]!['weather_error']!;
  String get weatherInfo => _localizedValues[locale.languageCode]!['weather_info']!;
  String get selectCrop => _localizedValues[locale.languageCode]!['select_crop']!;
  String get fertilizerCalculator => _localizedValues[locale.languageCode]!['fertilizer_calculator']!;
  String get pestsAndDiseases => _localizedValues[locale.languageCode]!['pests_and_diseases']!;
  String get cultivationTips => _localizedValues[locale.languageCode]!['cultivation_tips']!;
  String get wheat => _localizedValues[locale.languageCode]!['wheat']!;
  String get rice => _localizedValues[locale.languageCode]!['rice']!;
  String get tomato => _localizedValues[locale.languageCode]!['tomato']!;
  String get mustard => _localizedValues[locale.languageCode]!['mustard']!;
  String get addMore => _localizedValues[locale.languageCode]!['add_more']!;
  String get loading => _localizedValues[locale.languageCode]!['loading']!;
  String get logout => _localizedValues[locale.languageCode]!['logout']!;
  String get areaHint => _localizedValues[locale.languageCode]!['area_hint']!;
  String get fertilizerType => _localizedValues[locale.languageCode]!['fertilizer_type']!;
  String get calculate => _localizedValues[locale.languageCode]!['calculate']!;
  String get ureaLabel => _localizedValues[locale.languageCode]!['urea_label']!;
  String get dapLabel => _localizedValues[locale.languageCode]!['dap_label']!;
  String get mopLabel => _localizedValues[locale.languageCode]!['mop_label']!;
  String get resultLabel => _localizedValues[locale.languageCode]!['result_label']!;
  String get noDataForCrop => _localizedValues[locale.languageCode]!['no_data_for_crop']!;
  String get selectFertilizerType => _localizedValues[locale.languageCode]!['select_fertilizer_type']!;
  String get enterArea => _localizedValues[locale.languageCode]!['enter_area']!;
  String get tipsTitle => _localizedValues[locale.languageCode]!['tips_title']!;
  String get tipsWheat => _localizedValues[locale.languageCode]!['tips_wheat']!;
  String get tipsRice => _localizedValues[locale.languageCode]!['tips_rice']!;
  String get tipsTomato => _localizedValues[locale.languageCode]!['tips_tomato']!;
  String get tipsMustard => _localizedValues[locale.languageCode]!['tips_mustard']!;
  String get pndTitle => _localizedValues[locale.languageCode]!['pnd_title']!;
  String get pndWheat => _localizedValues[locale.languageCode]!['pnd_wheat']!;
  String get pndRice => _localizedValues[locale.languageCode]!['pnd_rice']!;
  String get pndTomato => _localizedValues[locale.languageCode]!['pnd_tomato']!;
  String get pndMustard => _localizedValues[locale.languageCode]!['pnd_mustard']!;
  String get loginTitle => _localizedValues[locale.languageCode]!['login_title']!;
  String get signupTitle => _localizedValues[locale.languageCode]!['signup_title']!;
  String get emailHint => _localizedValues[locale.languageCode]!['email_hint']!;
  String get passwordHint => _localizedValues[locale.languageCode]!['password_hint']!;
  String get confirmPasswordHint => _localizedValues[locale.languageCode]!['confirm_password_hint']!;
  String get loginButton => _localizedValues[locale.languageCode]!['login_button']!;
  String get signupButton => _localizedValues[locale.languageCode]!['signup_button']!;
  String get noAccount => _localizedValues[locale.languageCode]!['no_account']!;
  String get hasAccount => _localizedValues[locale.languageCode]!['has_account']!;
  String get invalidEmail => _localizedValues[locale.languageCode]!['invalid_email']!;
  String get passwordTooShort => _localizedValues[locale.languageCode]!['password_too_short']!;
  String get passwordsNotMatch => _localizedValues[locale.languageCode]!['passwords_not_match']!;
  String get loginSuccess => _localizedValues[locale.languageCode]!['login_success']!;
  String get signupSuccess => _localizedValues[locale.languageCode]!['signup_success']!;
  String get loginFailed => _localizedValues[locale.languageCode]!['login_failed']!;
  String get signupFailed => _localizedValues[locale.languageCode]!['signup_failed']!;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'hi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

class AuthService {
  static String? _currentUserEmail;
  static final Map<String, String> _users = {
    'test@example.com': 'password123',
  };

  static Stream<String?> get userChanges => _userController.stream;
  static final _userController = StreamController<String?>.broadcast();

  static Future<String?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (_users.containsKey(email) && _users[email] == password) {
      _currentUserEmail = email;
      _userController.add(_currentUserEmail);
      return email;
    }
    return null;
  }

  static Future<String?> signup(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (_users.containsKey(email)) {
      return null;
    }
    _users[email] = password;
    _currentUserEmail = email;
    _userController.add(_currentUserEmail);
    return email;
  }

  static Future<void> logout() async {
    _currentUserEmail = null;
    _userController.add(null);
  }

  static String? getCurrentUser() {
    return _currentUserEmail;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en', '');

  void setLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LeafLens',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      locale: _locale,
      supportedLocales: const [
        Locale('en', ''),
        Locale('hi', ''),
      ],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();

    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 3));
    String? user = AuthService.getCurrentUser();
    if (mounted) {
      if (user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeScreen(setLocale: MyApp.of(context)!.setLocale),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginScreen(setLocale: MyApp.of(context)!.setLocale),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[900],
      body: Center(
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.eco,
                size: 100,
                color: Colors.green[50],
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.appTitle,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[50],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                AppLocalizations.of(context)!.loading,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green[50],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  final void Function(Locale) setLocale;
  const LoginScreen({super.key, required this.setLocale});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final String? userEmail = await AuthService.login(
        _emailController.text,
        _passwordController.text,
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        if (userEmail != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.loginSuccess)),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => HomeScreen(setLocale: widget.setLocale),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.loginFailed)),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(appLocalizations.loginTitle),
        backgroundColor: Colors.green,
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'en') {
                widget.setLocale(const Locale('en', ''));
              } else if (result == 'hi') {
                widget.setLocale(const Locale('hi', ''));
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'en',
                child: Text('English'),
              ),
              const PopupMenuItem<String>(
                value: 'hi',
                child: Text('हिन्दी'),
              ),
            ],
            icon: const Icon(Icons.language, color: Colors.white),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.eco, size: 80, color: Colors.green[700]),
                const SizedBox(height: 30),
                Text(
                  appLocalizations.loginTitle,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: appLocalizations.emailHint,
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty || !value.contains('@')) {
                      return appLocalizations.invalidEmail;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: appLocalizations.passwordHint,
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 6) {
                      return appLocalizations.passwordTooShort;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                _isLoading
                    ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                )
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: _login,
                  child: Text(
                    appLocalizations.loginButton,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SignupScreen(setLocale: widget.setLocale)),
                    );
                  },
                  child: Text(
                    '${appLocalizations.noAccount} ${appLocalizations.signupButton}',
                    style: TextStyle(color: Colors.green[700]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SignupScreen extends StatefulWidget {
  final void Function(Locale) setLocale;
  const SignupScreen({super.key, required this.setLocale});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final String? userEmail = await AuthService.signup(
        _emailController.text,
        _passwordController.text,
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        if (userEmail != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.signupSuccess)),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.signupFailed)),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(appLocalizations.signupTitle),
        backgroundColor: Colors.green,
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'en') {
                widget.setLocale(const Locale('en', ''));
              } else if (result == 'hi') {
                widget.setLocale(const Locale('hi', ''));
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'en',
                child: Text('English'),
              ),
              const PopupMenuItem<String>(
                value: 'hi',
                child: Text('हिन्दी'),
              ),
            ],
            icon: const Icon(Icons.language, color: Colors.white),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.app_registration, size: 80, color: Colors.green[700]),
                const SizedBox(height: 30),
                Text(
                  appLocalizations.signupTitle,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: appLocalizations.emailHint,
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty || !value.contains('@')) {
                      return appLocalizations.invalidEmail;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: appLocalizations.passwordHint,
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 6) {
                      return appLocalizations.passwordTooShort;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: appLocalizations.confirmPasswordHint,
                    prefixIcon: const Icon(Icons.lock_reset),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return appLocalizations.passwordTooShort;
                    }
                    if (value != _passwordController.text) {
                      return appLocalizations.passwordsNotMatch;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                _isLoading
                    ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                )
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: _signup,
                  child: Text(
                    appLocalizations.signupButton,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    '${appLocalizations.hasAccount} ${appLocalizations.loginButton}',
                    style: TextStyle(color: Colors.green[700]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final void Function(Locale) setLocale;
  const HomeScreen({super.key, required this.setLocale});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  File? _image;
  final _picker = ImagePicker();
  Crop? _selectedCrop;

  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fabAnimation =
        CurvedAnimation(parent: _fabController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context)!.failedToPick + e.toString()),
        ),
      );
    }
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
                icon: const Icon(Icons.photo_library),
                label: Text(AppLocalizations.of(context)!.pickFromGallery),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
                icon: const Icon(Icons.camera_alt),
                label: Text(AppLocalizations.of(context)!.takeFromCamera),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getLocalizedCropName(Crop crop, AppLocalizations appLocalizations) {
    switch (crop) {
      case Crop.wheat:
        return appLocalizations.wheat;
      case Crop.rice:
        return appLocalizations.rice;
      case Crop.tomato:
        return appLocalizations.tomato;
      case Crop.mustard:
        return appLocalizations.mustard;
      case Crop.addMore:
        return appLocalizations.addMore;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        backgroundColor: Colors.green,
        leading: _selectedCrop != null
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            setState(() {
              _selectedCrop = null;
              _image = null;
            });
          },
        )
            : Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.account_circle, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: 'Profile',
            );
          },
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'en') {
                widget.setLocale(const Locale('en', ''));
              } else if (result == 'hi') {
                widget.setLocale(const Locale('hi', ''));
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'en',
                child: Text('English'),
              ),
              const PopupMenuItem<String>(
                value: 'hi',
                child: Text('हिन्दी'),
              ),
            ],
            icon: const Icon(Icons.language, color: Colors.white),
          ),
          IconButton(
            icon: const Icon(Icons.cloud, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WeatherScreen(
                    appLocalizations: appLocalizations, // Correctly pass the appLocalizations object
                    weatherInfo: appLocalizations.weatherInfo,
                    getWeatherText: appLocalizations.getWeather,
                    locationHint: appLocalizations.locationHint,
                    weatherError: appLocalizations.weatherError,
                    locationLabel: appLocalizations.location,
                    temperatureLabel: appLocalizations.temperature,
                    humidityLabel: appLocalizations.humidity,
                    conditionLabel: appLocalizations.condition,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await AuthService.logout();
            },
            tooltip: appLocalizations.logout,
          ),
        ],
      ),
      drawer: MyProfileDrawer(),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_selectedCrop == null) ...[
                Text(
                  appLocalizations.selectCrop,
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
                const SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  children: [
                    _buildCropCard(context, 'assets/images/animated_wheat.png', Crop.wheat),
                    _buildCropCard(context, 'assets/images/animated_rice.png', Crop.rice),
                    _buildCropCard(context, 'assets/images/animated_tomato.png', Crop.tomato),
                    _buildCropCard(context, 'assets/images/animated_mustard.png', Crop.mustard),
                    _buildCropCard(context, 'assets/images/add_more.png', Crop.addMore),
                  ],
                ),
              ] else ...[
                Text(
                  _getLocalizedCropName(_selectedCrop!, appLocalizations),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
                const SizedBox(height: 20),
                if (_image != null)
                  Container(
                    padding: const EdgeInsets.all(20),
                    height: 300,
                    child: Image.file(_image!),
                  )
                else
                  Text(
                    appLocalizations.noImageSelected,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                const SizedBox(height: 20),
                _buildFeatureGrid(context, _selectedCrop!, appLocalizations),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: _selectedCrop != null
          ? FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: _showImageSourceOptions,
        child: const Icon(Icons.add_a_photo, color: Colors.white),
      )
          : null,
    );
  }

  Widget _buildCropCard(BuildContext context, String imagePath, Crop crop) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCrop = crop;
          _image = null;
        });
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            CircleAvatar(
              radius: 70,
              backgroundColor: Colors.green[50],
              child: ClipOval(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: 100,
                  height: 100,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(_getLocalizedCropName(crop, AppLocalizations.of(context)!), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context, Crop selectedCrop, AppLocalizations appLocalizations) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.2,
        children: [
          _buildFeatureCard(
              context,
              Icons.yard,
              appLocalizations.fertilizerCalculator,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FertilizerCalculatorScreen(
                      crop: selectedCrop,
                      appLocalizations: appLocalizations,
                    ),
                  ),
                );
              }),
          _buildFeatureCard(
              context,
              Icons.bug_report,
              appLocalizations.pestsAndDiseases,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PestsAndDiseasesScreen(
                      crop: selectedCrop,
                      appLocalizations: appLocalizations,
                    ),
                  ),
                );
              }),
          _buildFeatureCard(
              context,
              Icons.lightbulb,
              appLocalizations.cultivationTips,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CultivationTipsScreen(
                      crop: selectedCrop,
                      appLocalizations: appLocalizations,
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, IconData icon, String text,
      {VoidCallback? onTap}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.green),
              const SizedBox(height: 10),
              Text(text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

class MyProfileDrawer extends StatefulWidget {
  const MyProfileDrawer({super.key});

  @override
  State<MyProfileDrawer> createState() => _MyProfileDrawerState();
}

class _MyProfileDrawerState extends State<MyProfileDrawer> {
  final List<String> savedCrops = ['Wheat', 'Rice', 'Tomato'];
  final List<String> analysisHistory = [
    'Wheat - Healthy',
    'Tomato - Early Blight',
    'Mustard - Aphids'
  ];

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(AuthService.getCurrentUser() ?? "Guest"),
            accountEmail: const Text(''),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 50, color: Colors.green),
            ),
            decoration: const BoxDecoration(
              color: Colors.green,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.grass),
            title: Text(appLocalizations.selectCrop),
            onTap: () {
              Navigator.pop(context);
              // You can add a SavedCropsScreen here if needed
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: Text('Analysis History'), // Localize this
            onTap: () {
              Navigator.pop(context);
              // You can add an AnalysisHistoryScreen here if needed
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(appLocalizations.logout),
            onTap: () async {
              Navigator.pop(context);
              await AuthService.logout();
            },
          ),
        ],
      ),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  final AppLocalizations appLocalizations;
  final String weatherInfo;
  final String getWeatherText;
  final String locationHint;
  final String weatherError;
  final String locationLabel;
  final String temperatureLabel;
  final String humidityLabel;
  final String conditionLabel;

  const WeatherScreen({
    super.key,
    required this.appLocalizations,
    required this.weatherInfo,
    required this.getWeatherText,
    required this.locationHint,
    required this.weatherError,
    required this.locationLabel,
    required this.temperatureLabel,
    required this.humidityLabel,
    required this.conditionLabel,
  });

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? _weatherData;
  bool _isLoading = false;
  String? _error;

  final String _apiKey = "U9Gr7A3B7G50d5Yauds2AFo1Qf2YaOaT";

  Future<void> _getWeatherData() async {
    if (_controller.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _weatherData = null;
    });

    try {
      final String location = _controller.text;

      final url =
          'https://api.tomorrow.io/v4/weather/realtime?location=$location&apikey=$_apiKey&units=metric';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final values = data['data']['values'];

        setState(() {
          _weatherData = {
            'location': location,
            'temperature': values['temperature'],
            'humidity': values['humidity'],
            'condition': _getTomorrowIoCondition(values['weatherCode']),
            'timestamp': DateTime.now(),
          };
        });
      } else {
        setState(() {
          _error = widget.weatherError;
        });
      }
    } catch (e) {
      setState(() {
        _error =
        'Failed to get weather data. Check your API key or location.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getTomorrowIoCondition(int code) {
    switch (code) {
      case 1000:
        return 'Clear';
      case 1100:
        return 'Mostly Clear';
      case 1101:
        return 'Partly Cloudy';
      case 1102:
        return 'Mostly Cloudy';
      case 1001:
        return 'Cloudy';
      case 2000:
        return 'Fog';
      case 2100:
        return 'Light Fog';
      case 4000:
        return 'Drizzle';
      case 4001:
        return 'Rain';
      case 4200:
        return 'Light Rain';
      case 4201:
        return 'Heavy Rain';
      case 5000:
        return 'Snow';
      case 5001:
        return 'Flurries';
      case 5100:
        return 'Light Snow';
      case 5101:
        return 'Heavy Snow';
      case 6000:
        return 'Freezing Drizzle';
      case 6001:
        return 'Freezing Rain';
      case 6200:
        return 'Light Freezing Rain';
      case 6201:
        return 'Heavy Freezing Rain';
      case 7000:
        return 'Ice Pellets';
      case 7101:
        return 'Heavy Ice Pellets';
      case 7102:
        return 'Light Ice Pellets';
      case 8000:
        return 'Thunderstorm';
      default:
        return 'Unknown';
    }
  }

  /// Map condition → background color
  Color _getBackgroundColor(String condition) {
    switch (condition) {
      case 'Clear':
      case 'Mostly Clear':
        return Colors.lightBlue.shade300;
      case 'Partly Cloudy':
      case 'Mostly Cloudy':
      case 'Cloudy':
        return Colors.grey.shade400;
      case 'Rain':
      case 'Light Rain':
      case 'Heavy Rain':
      case 'Drizzle':
        return Colors.blueGrey.shade600;
      case 'Snow':
      case 'Light Snow':
      case 'Heavy Snow':
      case 'Flurries':
        return Colors.blue.shade100;
      case 'Thunderstorm':
        return Colors.deepPurple.shade400;
      case 'Fog':
      case 'Light Fog':
        return Colors.grey.shade300;
      default:
        return Colors.green.shade100;
    }
  }

  /// Map condition → icon
  IconData _getWeatherIcon(String condition) {
    switch (condition) {
      case 'Clear':
      case 'Mostly Clear':
        return Icons.wb_sunny;
      case 'Partly Cloudy':
      case 'Mostly Cloudy':
      case 'Cloudy':
        return Icons.cloud;
      case 'Rain':
      case 'Light Rain':
      case 'Heavy Rain':
      case 'Drizzle':
        return Icons.grain; // raindrop-like
      case 'Snow':
      case 'Light Snow':
      case 'Heavy Snow':
      case 'Flurries':
        return Icons.ac_unit; // snowflake
      case 'Thunderstorm':
        return Icons.flash_on;
      case 'Fog':
      case 'Light Fog':
        return Icons.blur_on;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? condition = _weatherData?['condition'];
    final Color backgroundColor =
    condition != null ? _getBackgroundColor(condition) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.weatherInfo),
        backgroundColor: Colors.green,
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: backgroundColor,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: widget.locationHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[900],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              onPressed: _isLoading ? null : _getWeatherData,
              child: _isLoading
                  ? const CircularProgressIndicator(
                valueColor:
                AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : Text(widget.getWeatherText),
            ),
            const SizedBox(height: 40),
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              )
            else if (_weatherData != null)
              Card(
                color: Colors.white.withOpacity(0.85),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        _getWeatherIcon(_weatherData!['condition']),
                        size: 56,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _weatherData!['location'],
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Updated: ${DateFormat('hh:mm a').format(_weatherData!['timestamp'])}",
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black54),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${widget.temperatureLabel}: ${_weatherData!['temperature']}°C',
                              style: const TextStyle(fontSize: 18),
                            ),
                            Text(
                              '${widget.humidityLabel}: ${_weatherData!['humidity']}%',
                              style: const TextStyle(fontSize: 18),
                            ),
                            Text(
                              '${widget.conditionLabel}: ${_weatherData!['condition']}',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}

// FERTILIZER CALCULATOR SCREEN
class FertilizerCalculatorScreen extends StatefulWidget {
  final Crop crop;
  final AppLocalizations appLocalizations;

  const FertilizerCalculatorScreen({
    super.key,
    required this.crop,
    required this.appLocalizations,
  });

  @override
  _FertilizerCalculatorScreenState createState() =>
      _FertilizerCalculatorScreenState();
}

class _FertilizerCalculatorScreenState
    extends State<FertilizerCalculatorScreen> {
  final TextEditingController _areaController = TextEditingController();
  String? _selectedFertilizerType;
  double _calculatedResult = 0.0;
  String _resultUnit = 'kg';
  String? _selectedGrowthStage;
  final TextEditingController _phController = TextEditingController();

  final Map<Crop, Map<String, Map<String, double>>> _fertilizerRates = {
    Crop.wheat: {
      'Sowing': {'Urea': 40, 'DAP': 20, 'MOP': 5},
      'Vegetative': {'Urea': 30, 'DAP': 10, 'MOP': 5},
      'Flowering': {'Urea': 20, 'DAP': 5, 'MOP': 10},
    },
    Crop.rice: {
      'Sowing': {'Urea': 50, 'DAP': 25, 'MOP': 10},
      'Vegetative': {'Urea': 40, 'DAP': 15, 'MOP': 10},
      'Flowering': {'Urea': 30, 'DAP': 10, 'MOP': 15},
    },
    Crop.tomato: {
      'Sowing': {'Urea': 30, 'DAP': 25, 'MOP': 15},
      'Vegetative': {'Urea': 20, 'DAP': 15, 'MOP': 10},
      'Flowering': {'Urea': 10, 'DAP': 10, 'MOP': 20},
    },
    Crop.mustard: {
      'Sowing': {'Urea': 35, 'DAP': 18, 'MOP': 8},
      'Vegetative': {'Urea': 25, 'DAP': 10, 'MOP': 5},
      'Flowering': {'Urea': 15, 'DAP': 8, 'MOP': 3},
    },
  };

  String _getLocalizedCropName(Crop crop, AppLocalizations appLocalizations) {
    switch (crop) {
      case Crop.wheat:
        return appLocalizations.wheat;
      case Crop.rice:
        return appLocalizations.rice;
      case Crop.tomato:
        return appLocalizations.tomato;
      case Crop.mustard:
        return appLocalizations.mustard;
      case Crop.addMore:
        return appLocalizations.noDataForCrop;
    }
  }

  void _calculateFertilizer() {
    FocusScope.of(context).unfocus();

    double? area = double.tryParse(_areaController.text);
    double? phLevel = double.tryParse(_phController.text);

    if (area == null || area <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.appLocalizations.enterArea)));
      return;
    }

    if (_selectedFertilizerType == null || _selectedGrowthStage == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select a fertilizer type and growth stage.')));
      return;
    }

    if (phLevel == null || phLevel <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a valid pH level.')));
      return;
    }

    Map<String, double>? rates = _fertilizerRates[widget.crop]?[_selectedGrowthStage];

    if (rates == null || !rates.containsKey(_selectedFertilizerType)) {
      setState(() { _calculatedResult = 0.0; });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.appLocalizations.noDataForCrop)));
      return;
    }

    double ratePerAcre = rates[_selectedFertilizerType]!;

    if (phLevel < 6.0) {
      ratePerAcre *= 1.1;
    } else if (phLevel > 7.5) {
      ratePerAcre *= 1.05;
    }

    setState(() {
      _calculatedResult = ratePerAcre * area;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = widget.appLocalizations;
    return Scaffold(
      appBar: AppBar(
        title: Text('${appLocalizations.fertilizerCalculator} - ${_getLocalizedCropName(widget.crop, appLocalizations)}'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${appLocalizations.selectCrop}: ${_getLocalizedCropName(widget.crop, appLocalizations)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green[900],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _areaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: appLocalizations.areaHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Select Growth Stage', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedGrowthStage,
              hint: const Text('Select Growth Stage'),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: <String>['Sowing', 'Vegetative', 'Flowering'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGrowthStage = newValue;
                  _calculatedResult = 0.0;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _phController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter Soil pH Level',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              appLocalizations.fertilizerType,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedFertilizerType,
              hint: Text(appLocalizations.selectFertilizerType),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: <String>['Urea', 'DAP', 'MOP'].map((String value) {
                String localizedValue;
                if (value == 'Urea') {
                  localizedValue = appLocalizations.ureaLabel;
                } else if (value == 'DAP') {
                  localizedValue = appLocalizations.dapLabel;
                } else if (value == 'MOP') {
                  localizedValue = appLocalizations.mopLabel;
                } else {
                  localizedValue = value;
                }
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(localizedValue),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFertilizerType = newValue;
                  _calculatedResult = 0.0;
                });
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[900],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: _calculateFertilizer,
              child: Text(appLocalizations.calculate,
                  style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 30),
            if (_calculatedResult > 0)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        appLocalizations.resultLabel,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[900],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '$_selectedFertilizerType: ${_calculatedResult.toStringAsFixed(2)} $_resultUnit',
                        style: const TextStyle(fontSize: 22, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// CULTIVATION TIPS SCREEN
class CultivationTipsScreen extends StatelessWidget {
  final Crop crop;
  final AppLocalizations appLocalizations;

  const CultivationTipsScreen({
    super.key,
    required this.crop,
    required this.appLocalizations,
  });

  @override
  Widget build(BuildContext context) {
    String tips = '';
    String cropName = '';

    switch (crop) {
      case Crop.wheat:
        tips = appLocalizations.tipsWheat;
        cropName = appLocalizations.wheat;
        break;
      case Crop.rice:
        tips = appLocalizations.tipsRice;
        cropName = appLocalizations.rice;
        break;
      case Crop.tomato:
        tips = appLocalizations.tipsTomato;
        cropName = appLocalizations.tomato;
        break;
      case Crop.mustard:
        tips = appLocalizations.tipsMustard;
        cropName = appLocalizations.mustard;
        break;
      case Crop.addMore:
        tips = appLocalizations.noDataForCrop;
        cropName = appLocalizations.addMore;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${appLocalizations.tipsTitle} ${cropName}'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              tips,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

// PESTS AND DISEASES SCREEN
class PestsAndDiseasesScreen extends StatelessWidget {
  final Crop crop;
  final AppLocalizations appLocalizations;

  const PestsAndDiseasesScreen({
    super.key,
    required this.crop,
    required this.appLocalizations,
  });

  @override
  Widget build(BuildContext context) {
    String pndInfo = '';
    String cropName = '';

    switch (crop) {
      case Crop.wheat:
        pndInfo = appLocalizations.pndWheat;
        cropName = appLocalizations.wheat;
        break;
      case Crop.rice:
        pndInfo = appLocalizations.pndRice;
        cropName = appLocalizations.rice;
        break;
      case Crop.tomato:
        pndInfo = appLocalizations.pndTomato;
        cropName = appLocalizations.tomato;
        break;
      case Crop.mustard:
        pndInfo = appLocalizations.pndMustard;
        cropName = appLocalizations.mustard;
        break;
      case Crop.addMore:
        pndInfo = appLocalizations.noDataForCrop;
        cropName = appLocalizations.addMore;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${appLocalizations.pndTitle} ${cropName}'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pndInfo,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

// New screen for Saved Crops
class SavedCropsScreen extends StatelessWidget {
  final List<String> savedCrops;

  const SavedCropsScreen({super.key, required this.savedCrops});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Crops'),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        itemCount: savedCrops.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.grass),
            title: Text(savedCrops[index]),
          );
        },
      ),
    );
  }
}

// New screen for Analysis History
class AnalysisHistoryScreen extends StatelessWidget {
  final List<String> history;

  const AnalysisHistoryScreen({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis History'),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.photo_album),
            title: Text(history[index]),
          );
        },
      ),
    );
  }
}