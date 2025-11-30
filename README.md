# LabelWise - PRPL (Product Risk Profile Label)

A comprehensive health and safety analysis platform that uses AI-powered image recognition to analyze product labels and provide personalized safety recommendations based on individual health profiles.

## 🎯 Project Overview

**LabelWise** is an intelligent product safety analyzer that helps users make informed purchasing decisions by scanning product labels (nutrition facts, ingredients, medication information) and comparing them against their personal health conditions and dietary restrictions.

### Key Features

- 🤖 **AI-Powered Analysis**: Uses Google's Gemini 2.0 Flash model for intelligent product categorization and safety assessment
- 🏥 **Health-Conscious**: Personalized recommendations based on user health conditions (diabetes, allergies, hypertension, etc.)
- 📷 **Image Recognition**: Analyzes nutrition facts, ingredients, and medication information from product images
- 🔒 **Secure & Private**: Firebase authentication and Firestore for secure data persistence
- 📱 **Cross-Platform**: Web interface and Flutter mobile applications
- ⚡ **Real-Time Analysis**: Instant product safety verdicts with detailed explanations

## 📋 Project Structure

```
PRPL/
├── PRPL_Backend.py                 # Flask backend API server
├── index.html                      # Web application (HTML + JavaScript)
├── milk-nutrition-facts.avif       # Sample product image
│
├── nutrition_facts_application/    # Main Flutter app
│   ├── lib/
│   │   └── main.dart
│   ├── android/                    # Android build configuration
│   ├── ios/                        # iOS build configuration
│   ├── windows/                    # Windows build configuration
│   ├── linux/                      # Linux build configuration
│   ├── macos/                      # macOS build configuration
│   ├── web/                        # Web build configuration
│   └── pubspec.yaml               # Flutter dependencies
│
├── nutrition_facts_application/labelwise_flutter/  # Alternative Flutter app
│   ├── lib/
│   │   └── main.dart
│   ├── android/
│   ├── ios/
│   ├── windows/
│   ├── linux/
│   ├── macos/
│   └── pubspec.yaml
│
└── labelwisebackend.py             # Additional backend processing
```

## 🛠️ Technology Stack

### Backend
- **Framework**: Flask (Python)
- **AI Model**: Google Gemini 2.0 Flash API
- **Image Processing**: Python Imaging Library (PIL)
- **CORS Support**: Flask-CORS

### Frontend
- **Web**: HTML5, JavaScript (ES6+), Tailwind CSS
- **Mobile**: Flutter (Dart)
- **Authentication**: Firebase Authentication
- **Database**: Firestore
- **State Management**: Provider (Flutter)

### Additional Libraries
- **HTTP Client**: Dart HTTP package
- **Image Picker**: Flutter image_picker
- **Firebase**: Firebase JS SDK, FlutterFire

## 🚀 Getting Started

### Prerequisites

- Python 3.8+
- Flutter SDK (for mobile apps)
- Node.js (optional, for frontend development)
- Google API Key (for Gemini API)
- Firebase project setup (for authentication)

### Backend Setup

1. **Install Python dependencies**:
```bash
pip install flask flask-cors google-generativeai pillow
```

2. **Configure API Key**:
Add your Google Gemini API key to `PRPL_Backend.py`:
```python
API_KEY = "YOUR_GEMINI_API_KEY"
```

3. **Run the Flask server**:
```bash
python PRPL_Backend.py
```
The backend will start on `http://localhost:5000`

### Frontend Setup (Web)

1. **Open the web application**:
Simply open `index.html` in a modern web browser (Chrome, Firefox, Safari, Edge)

2. **Configure Firebase** (Optional):
Add your Firebase config to the HTML file for persistent user profiles

### Mobile Setup (Flutter)

1. **Install Flutter dependencies**:
```bash
cd nutrition_facts_application
flutter pub get
```

2. **Run on emulator or physical device**:
```bash
flutter run
```

3. **Build for production**:
```bash
# Android
flutter build apk

# iOS
flutter build ios

# Web
flutter build web
```

## 📡 API Endpoints

### POST `/analyze`

Analyzes a product image against user health conditions.

**Request**:
- `image` (form-data): Product image file
- `diseases` (form-data): Comma-separated health conditions (e.g., "diabetes, high blood pressure")

**Response**:
```json
{
  "category": "Food/Drink | Medication | Tobacco/Nicotine | Other",
  "recommendation": "Safe | Not Safe | Caution",
  "explanation": "Brief safety assessment explanation"
}
```

**Example**:
```bash
curl -X POST http://localhost:5000/analyze \
  -F "image=@product.jpg" \
  -F "diseases=diabetes, high blood pressure"
```

## 🔄 How It Works

1. **User Authentication**: Users sign in via Firebase (web) or Flutter app
2. **Profile Creation**: Users input their health conditions and dietary restrictions
3. **Tag Generation**: AI extracts relevant health tags from user profile
4. **Product Scanning**: User captures or uploads a product image
5. **Image Analysis**: Gemini API analyzes the image for:
   - Product category identification
   - Ingredient/nutritional content extraction
   - Health risk assessment
6. **Safety Verdict**: App provides Safe/Caution/Not Safe recommendation with explanation
7. **Profile Persistence**: User profiles saved to Firestore for future sessions

## 🔐 Security & Privacy

- **Firebase Authentication**: Secure user identification
- **Firestore Security Rules**: User data isolation and protection
- **HTTPS**: All API communications should use HTTPS in production
- **API Key Protection**: Gemini API key should be protected using environment variables in production
- **No Personal Health Records**: Health information stored only for analysis context

## 📦 Files to Upload to GitHub

### Essential Files (Required)
```
✅ PRPL_Backend.py              # Backend API server
✅ index.html                   # Web application
✅ nutrition_facts_application/ # Main Flutter app (entire directory)
✅ labelwise_flutter/           # Alternative Flutter app (entire directory)
✅ labelwisebackend.py          # Additional backend logic
✅ README.md                    # Project documentation
✅ .gitignore                   # Git ignore rules
```

### Optional Files (Recommended)
```
✅ milk-nutrition-facts.avif    # Sample/test image
✅ pubspec.yaml (if root level) # Root-level dependencies
```

### Files to EXCLUDE from GitHub
```
❌ build/                       # Build artifacts and cache
❌ .gradle/                     # Gradle cache
❌ .dart_tool/                  # Flutter/Dart tool cache
❌ __pycache__/                 # Python cache
❌ .env                         # Environment variables (API keys)
❌ local.properties             # Local Android configuration
❌ *.apk / *.ipa               # Build outputs
❌ node_modules/                # Node dependencies (if any)
❌ .flutter-plugins-dependencies
❌ .packages
❌ pubspec.lock (per best practices, optional)
```

## 📝 Recommended .gitignore

Create a `.gitignore` file in the root:

```
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Flask
instance/
.webassets-cache

# Flutter
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
pubspec.lock
build/
ios/Pods/
ios/Podfile.lock
android/.gradle/
android/local.properties
android/.classpath
android/.project
android/.settings/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store

# Environment
.env
.env.local

# Firebase
firebase-debug.log
.firebaserc
```

## 🔧 Environment Variables

Create a `.env` file (do NOT commit to GitHub):

```
GEMINI_API_KEY=your_gemini_api_key_here
FLASK_ENV=development
FLASK_DEBUG=True
```

For production, set these as environment variables on your server.

## 📱 Demo & Testing

### Test the Web App Locally
1. Start Flask backend: `python PRPL_Backend.py`
2. Open `index.html` in browser
3. Create profile with test conditions: "diabetes, high blood pressure"
4. Upload `milk-nutrition-facts.avif` for analysis

### Test the API
```bash
curl -X POST http://localhost:5000/analyze \
  -F "image=@milk-nutrition-facts.avif" \
  -F "diseases=diabetes, high blood pressure"
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see LICENSE file for details.

## 👥 Authors

- **Omar Ariawan** - Lead Developer

## 🙏 Acknowledgments

- Google Gemini API for AI-powered product analysis
- Firebase for secure authentication and data storage
- Flutter team for cross-platform mobile development
- Tailwind CSS for responsive UI design

## 📧 Contact & Support

For issues, questions, or suggestions:
- GitHub Issues: [Create an issue](https://github.com/omarariawan/PRPL/issues)
- Email: your-email@example.com

## 🗺️ Roadmap

- [ ] Advanced nutrition tracking dashboard
- [ ] User health history and analytics
- [ ] Integration with popular health apps
- [ ] Offline mode for mobile apps
- [ ] Multi-language support
- [ ] Barcode/QR code scanning
- [ ] Prescription drug interaction checker
- [ ] Recipe analysis based on health profile
- [ ] Community sharing and reviews
- [ ] Machine learning model for improved accuracy

---

**Last Updated**: November 2025  
**Status**: Active Development
