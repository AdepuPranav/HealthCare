# Azure Healthcare Chatbot 🏥🤖

An AI-powered **Healthcare Chatbot** using **Flutter** for the Android frontend and **Microsoft Azure Healthcare Bot** as the backend. This app enables users to describe their symptoms and receive preliminary medical advice, with support for real-time translation in **English, Telugu, Hindi, and Tamil**.

---

## ✨ Features

- ✅ **Conversational AI** – Integrated with Microsoft Azure Healthcare Bot  
- ✅ **Multilingual Support** – Chat in English, Telugu, Hindi, or Tamil  
- ✅ **Real-time Translation** – Automatic translation of user inputs and bot replies  
- ✅ **Flutter Android App** – Clean, responsive UI with animated chat interface  
- ✅ **Persistent Chat History** – Messages are saved locally using SharedPreferences  
- ✅ **Typing Indicators & Avatar Styling** – Improved conversational experience  
- ✅ **Language Slider & Dropdown UI** – Easy language selection  
- ✅ **Healthcare Disclaimer** – Encourages users to seek professional medical advice  

---

## 📂 Project Structure
📁 azure_healthcare_flutter_app │── 
📁 lib │ ├──
📜 main.dart # App entry point 
│ ├── 📜 chat_screen.dart # Chat UI and messaging logic 
│ ├── 📜 log_service.dart # Save/read/clear chat logs
│ ├── 📜 language_selector.dart # Language slider/dropdown UI 
│ ├── 📜 health_tips_screen.dart # Expandable categorized health tips 
│ └── 📜 api_service.dart # Communicates with Azure backend 
│ │── 📁 assets # Icons and translation strings 
     │── 📁 android # Android-specific code
     │── 📜 pubspec.yaml # Flutter dependencies


2. Open in Android Studio
Launch Android Studio
Click "Open" and select the cloned folder (flutter_android_app)


3. Install Dependencies
Open pubspec.yaml
Click "Pub get" to install required packages

4. Configure Backend
Ensure your backend (FastAPI + Azure Bot) is deployed and publicly accessible. Update the api_service.dart with your backend endpoint and Direct Line secret if needed.

5. Run the App
IMPORTANT :
RUN the main.py (it will run a local server to use the backend python files) and then run the frontend app in android studio(flutter_android_app).
Connect your Android device or launch an emulator

Click Run ▶️ to start the app

💬 How It Works
1.Open the app and select your preferred language.
2.Enter your symptoms and press Send.
3.The app sends the message to the backend, which communicates with Azure Healthcare Bot.
4.Responses are returned, translated (if needed), and displayed in the chat.
5.Health tips are available in the sidebar and support translation as well.

📌 Disclaimer
This chatbot is for informational purposes only. It is not a substitute for professional medical advice, diagnosis, or treatment. Always consult a qualified healthcare provider.
