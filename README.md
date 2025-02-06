Azure Healthcare Chatbot 🏥🤖
An AI-powered Healthcare Chatbot built using Python (PyQt5) and Microsoft Azure Healthcare Bot. This chatbot allows users to describe their symptoms and receive preliminary medical advice. It also supports multilingual translations, enabling users to communicate in English, Telugu, Hindi, and Tamil.

Features 🚀
✅ Conversational AI – Powered by Microsoft Azure's Healthcare Bot
✅ Multilingual Support – Users can interact in multiple languages
✅ Interactive UI – Developed using PyQt5 for a responsive and user-friendly experience
✅ Real-time Translation – Automatically translates user input and bot responses
✅ Button Animation – Minimalistic UI animations for better user experience
✅ Healthcare Disclaimer – Users are advised to consult professionals for final medical advice

Project Structure 📂
📁 Healthcare_Chatbot  
│── 📜 main.py                 # Entry point of the application  
│── 📜 azure_healthcare_bot.py  # Handles communication with Azure Healthcare Bot  
│── 📜 UI_components.py         # Custom UI elements (buttons, labels, etc.)  
│── 📜 translation.py           # Handles language translation  
│── 📜 config.py                # Stores API keys and endpoints  
│── 📜 requirements.txt         # Dependencies for the project  
└── 📁 assets                   # Icons and other UI resources  

Setup Instructions 🛠
1. Clone the Repository :
git clone https://github.com/your-username/azure-healthcare-chatbot.git
cd azure-healthcare-chatbot

2. Install Dependencies :
   pip install -r requirements.txt
   
3. Configure API Keys :
  Open config.py
  Add your Azure Healthcare Bot Direct Line Secret and Endpoint

4. Run the Application:
  python main.py

How It Works 🤖💬 :
  Start the chatbot
  Select a language (English, Telugu, Hindi, or Tamil)
  Type your symptoms in the input field and press "Send"
  The bot processes your query and responds with relevant healthcare information
  If a language other than English is selected, the response will be automatically translated
