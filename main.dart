// lib/main.dart
import 'dart:convert';
import 'dart:typed_data';          // <-- REQUIRED for Uint8List
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const LabelWiseApp());
}

/* -------------------------
   App State (Provider)
   ------------------------- */
class AppState extends ChangeNotifier {
  int currentStep = 1;
  String diseaseProfile = '';
  List<String> healthTags = [];
  String userId = 'LOCAL_TEST_USER';
  Uint8List? selectedImageBytes;       // <-- WEB-SAFE IMAGE STORAGE
  bool loading = false;

  void setImageBytes(Uint8List bytes) {
    selectedImageBytes = bytes;
    notifyListeners();
  }

  void setStep(int step) {
    currentStep = step;
    notifyListeners();
  }

  void setDiseaseProfile(String text) {
    diseaseProfile = text;
    notifyListeners();
  }

  void setTags(List<String> tags) {
    healthTags = tags;
    notifyListeners();
  }

  void addTag(String tag) {
    if (tag.isEmpty) return;
    if (!healthTags.contains(tag)) {
      healthTags.add(tag);
      notifyListeners();
    }
  }

  void removeTag(String tag) {
    healthTags.remove(tag);
    notifyListeners();
  }

  void setLoading(bool l) {
    loading = l;
    notifyListeners();
  }

  void resetForNextScan() {
    selectedImageBytes = null;   // <-- RESET CORRECTLY
    setStep(4);
  }
}

/* -------------------------
   Main App
   ------------------------- */
class LabelWiseApp extends StatelessWidget {
  const LabelWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'LabelWise',
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
        ),
        home: const Scaffold(
          body: SafeArea(child: FlowController()),
        ),
      ),
    );
  }
}

/* -------------------------
   FlowController
   ------------------------- */
class FlowController extends StatelessWidget {
  const FlowController({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, s, _) {
      return Stack(
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(18),
            color: const Color(0xFFF0F4F8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420, minHeight: 680),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: _screenForStep(s.currentStep),
                ),
              ),
            ),
          ),
          if (s.loading)
            Container(
              color: Colors.white.withOpacity(0.85),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text("Processing...", style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _screenForStep(int step) {
    switch (step) {
      case 1: return const Step1Welcome();
      case 2: return const Step2Onboarding();
      case 3: return const Step3Confirmation();
      case 4: return const Step4ScanAnalyze();
      case 5: return const Step5Verdict();
      default: return const Center(child: Text("Unknown step"));
    }
  }
}

/* -------------------------
   Step 1: Welcome
   ------------------------- */
class Step1Welcome extends StatelessWidget {
  const Step1Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Provider.of<AppState>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 6),
        const Text("LabelWise", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text("1. Welcome & Login", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 18),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(radius: 56, backgroundColor: Colors.indigo,
                child: const Icon(Icons.lock, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 18),
              const Text("Your Health, Secured.", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                    "Your unique profile is linked. We're ready to personalize your nutrition safety checks.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54)),
              )
            ],
          ),
        ),
        Text("User ID: ${s.userId}", style: const TextStyle(fontFamily: 'monospace')),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => s.setStep(2),
          style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text("Start Application"),
        ),
      ],
    );
  }
}

/* -------------------------
   Step 2: Onboarding
   ------------------------- */
class Step2Onboarding extends StatefulWidget {
  const Step2Onboarding({super.key});

  @override
  State<Step2Onboarding> createState() => _Step2OnboardingState();
}

class _Step2OnboardingState extends State<Step2Onboarding> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<String> suggestionsFrom(String text) {
    final suggested = [
      'diabetic','diabetes','high blood pressure','cholesterol',
      'celiac disease','peanut allergy','shellfish allergy',
      'low sodium','vegan','keto','nut allergy','lactose intolerant'
    ];
    final profile = text.toLowerCase();
    final matches = suggested.where((k) => profile.contains(k)).toList();
    if (matches.isEmpty) return ['General Dietary Goals'];
    return matches.map(_titleCase).toList();
  }

  String _titleCase(String s) => s.split(' ')
      .map((w) => w[0].toUpperCase() + w.substring(1))
      .join(' ');

  @override
  Widget build(BuildContext context) {
    final s = Provider.of<AppState>(context);
    _controller.text = s.diseaseProfile;
    _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length));

    return Column(
      children: [
        const Text("LabelWise", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text("2. Profile Onboarding (Module 1)", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 14),
        const Text("Describe your health needs, allergies, or dietary goals.", style: TextStyle(fontSize: 16)),
        const SizedBox(height: 12),
        Expanded(
          child: TextField(
            controller: _controller,
            maxLines: null,
            decoration: InputDecoration(
              hintText: "e.g. 'I am diabetic and allergic to shellfish.'",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: s.setDiseaseProfile,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            final text = s.diseaseProfile.trim();
            if (text.length < 10) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text("Please provide a more detailed description.")));
              return;
            }
            s.setTags(suggestionsFrom(text));
            s.setStep(3);
          },
          style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: const Text("Submit"),
        ),
      ],
    );
  }
}

/* -------------------------
   Step 3: Confirmation
   ------------------------- */
class Step3Confirmation extends StatefulWidget {
  const Step3Confirmation({super.key});

  @override
  State<Step3Confirmation> createState() => _Step3ConfirmationState();
}

class _Step3ConfirmationState extends State<Step3Confirmation> {
  final TextEditingController _manualCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final s = Provider.of<AppState>(context);
    return Column(
      children: [
        const Text("Confirmation", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text("3. Profile Confirmation (Module 2)", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          children: s.healthTags.map((tag) {
            return Chip(
              label: Text(tag),
              backgroundColor: Colors.green[50],
              deleteIconColor: Colors.red,
              onDeleted: () => s.removeTag(tag),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _manualCtrl,
          decoration: InputDecoration(
            hintText: "+ Add Tag",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () {
            final t = _manualCtrl.text.trim();
            if (t.isNotEmpty) {
              s.addTag(t[0].toUpperCase() + t.substring(1).toLowerCase());
              _manualCtrl.clear();
            }
          },
          child: const Text("Add Tag"),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            if (s.healthTags.isEmpty) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text("Add at least one tag.")));
              return;
            }
            s.setStep(4);
          },
          style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: const Text("Confirm & Start Scanning"),
        ),
      ],
    );
  }
}

/* -------------------------
   Step 4: Scan & Analyze
   ------------------------- */
class Step4ScanAnalyze extends StatefulWidget {
  const Step4ScanAnalyze({super.key});

  @override
  State<Step4ScanAnalyze> createState() => _Step4ScanAnalyzeState();
}

class _Step4ScanAnalyzeState extends State<Step4ScanAnalyze> {
  final ImagePicker _picker = ImagePicker();
  final String analyzeUrl = 'http://127.0.0.1:5000/analyze';

  Future<void> _pickImage(AppState s) async {
    final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80);

    if (file != null) {
      final bytes = await file.readAsBytes();   // <-- WEB SAFE
      s.setImageBytes(bytes);
    }
  }

  Future<void> _analyze(AppState s) async {
    if (s.selectedImageBytes == null) {
      _showMessage("Please select an image first.");
      return;
    }

    s.setLoading(true);

    try {
      final uri = Uri.parse(analyzeUrl);
      final request = http.MultipartRequest('POST', uri);

      // <-- WEB SAFE UPLOAD
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        s.selectedImageBytes!,
        filename: "upload.jpg",
      ));

      request.fields['diseases'] = s.healthTags.join(", ");

      final streamed = await request.send();
      final resp = await http.Response.fromStream(streamed);

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);

        final rec = (data['recommendation'] ?? 'Error');
        final verdict = {
          'Safe': 'OK',
          'Not Safe': 'AVOID',
          'Caution': 'CAUTION',
        }[rec] ?? 'ERROR';

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Step5Verdict(
              verdict: verdict,
              explanation: data['explanation'] ?? "",
              category: data['category'] ?? "Unknown",
            ),
          ),
        );
      } else {
        _showMessage("Server error: ${resp.statusCode}");
      }
    } catch (e) {
      _showMessage("API error: $e");
    } finally {
      s.setLoading(false);
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final s = Provider.of<AppState>(context);

    return Column(
      children: [
        const Text("Scan & Analyze", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const Text("4. Scan & Analyze (Module 3)", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => _pickImage(s),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 3),
              ),
              child: s.selectedImageBytes == null
                  ? const Center(
                      child: Text(
                        "Fit the ingredient list and nutrition\ninside the box",
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: Image.memory(
                        s.selectedImageBytes!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => _analyze(s),
          style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: const Text("Analyze"),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => _pickImage(s),
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: const Text("Select Image"),
        ),
      ],
    );
  }
}

/* -------------------------
   Step 5: Verdict
   ------------------------- */
class Step5Verdict extends StatelessWidget {
  final String verdict;
  final String explanation;
  final String category;

  const Step5Verdict({
    super.key,
    this.verdict = 'OK',
    this.explanation = '',
    this.category = 'Unknown',
  });

  @override
  Widget build(BuildContext context) {
    String bigText = verdict.toUpperCase();
    Color bgColor = Colors.grey.shade200;
    Color circleColor = Colors.grey;
    Icon icon = const Icon(Icons.error, size: 48);

    if (bigText == 'AVOID') {
      bgColor = Colors.red.shade50;
      circleColor = Colors.red.shade700;
      icon = const Icon(Icons.close, size: 48, color: Colors.white);
    } else if (bigText == 'OK') {
      bgColor = Colors.green.shade50;
      circleColor = Colors.green.shade700;
      icon = const Icon(Icons.check, size: 48, color: Colors.white);
    } else if (bigText == 'CAUTION') {
      bgColor = Colors.yellow.shade50;
      circleColor = Colors.orange.shade700;
      icon = const Icon(Icons.report, size: 48, color: Colors.white);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Verdict")),
      body: Container(
        color: const Color(0xFFF7F9FB),
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Verdict", style: TextStyle(fontSize: 20, color: Colors.grey.shade700)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        children: [
                          CircleAvatar(radius: 36, backgroundColor: circleColor, child: icon),
                          const SizedBox(height: 12),
                          Text(bigText, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text("Product Category: $category", style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 12),
                    Text(explanation, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                        final s = Provider.of<AppState>(context, listen: false);
                        s.resetForNextScan();
                      },
                      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                      child: const Text("Scan Next Item"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
