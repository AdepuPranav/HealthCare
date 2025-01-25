import sys
from PyQt5.QtWidgets import (QApplication, QMainWindow, QVBoxLayout, QHBoxLayout, 
                             QLabel, QComboBox, QTextEdit, QLineEdit, QPushButton, QWidget)
from azure_healthcare_bot import AzureBotThread
from translation import TranslatorModule

class HealthcareChatbot(QMainWindow):
    def __init__(self):
        super().__init__()

        # UI Setup
        self.setWindowTitle("Azure Healthcare Chatbot")
        self.setGeometry(100, 100, 600, 500)

        # Central widget and layout
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        main_layout = QVBoxLayout()
        central_widget.setLayout(main_layout)

        # Language Selection
        lang_layout = QHBoxLayout()
        lang_label = QLabel("Select Language:")
        self.language_combo = QComboBox()
        self.language_combo.addItems([
            "English", "Telugu (తెలుగు)", "Hindi (हिन्दी)", "Tamil (தமிழ்)"
        ])
        lang_layout.addWidget(lang_label)
        lang_layout.addWidget(self.language_combo)
        main_layout.addLayout(lang_layout)

        # Chat Display
        self.chat_display = QTextEdit()
        self.chat_display.setReadOnly(True)
        main_layout.addWidget(self.chat_display)

        # Message Input
        input_layout = QHBoxLayout()
        self.message_input = QLineEdit()
        self.message_input.setPlaceholderText("Enter your symptoms in...")
        self.send_button = QPushButton("Send")
        self.send_button.clicked.connect(self.send_message)  # Connect the button's clicked signal to send_message
        input_layout.addWidget(self.message_input)
        input_layout.addWidget(self.send_button)
        main_layout.addLayout(input_layout)

        # Disclaimer
        disclaimer = QLabel("Disclaimer: This is preliminary advice. Always consult a healthcare professional.")
        main_layout.addWidget(disclaimer)

        # Translator setup
        self.translator = TranslatorModule()

        # Azure Healthcare Bot setup
        self.bot_thread = AzureBotThread()
        self.bot_thread.message_received.connect(self.display_bot_message)
        self.bot_thread.start()
    

    def send_message(self):
        message = self.message_input.text()
        if not message:
            return

        # Detect language and translate if necessary
        selected_lang = self.language_combo.currentText().lower()
        translated_message = self.translator.translate_to_english(message, selected_lang)

        # Display user message
        self.chat_display.append(f"You: {message}")

        # Send translated message to Azure Healthcare Bot via AzureBotThread
        self.bot_thread.send_message_to_bot(translated_message)

        # Clear input
        self.message_input.clear()

    def display_bot_message(self, message):
        """Display bot's response with appropriate translation"""
        print(f"Bot message received: {message}")  # Debugging output

        selected_lang = self.language_combo.currentText().lower()

        # Skip translation if no language is selected or if the selected language is English
        if not selected_lang or selected_lang == "english":
            translated_message = message
        else:
            # Translate the message from English to the selected language
            translated_message = self.translator.translate_from_english(message, selected_lang)
            print(f"Translated message: {translated_message}")  # Debugging output

        # Append the translated or original message to the chat display
        self.chat_display.append(f"Bot: {translated_message}")

        # Ensure the chat display scrolls to the latest message
        cursor = self.chat_display.textCursor()
        cursor.movePosition(cursor.End)
        self.chat_display.setTextCursor(cursor)
        return 'testing!'
        

    def closeEvent(self, event):
        """Stop thread when window closes"""
        self.bot_thread.stop()
        self.bot_thread.wait()
        event.accept()


def main():
    app = QApplication(sys.argv)
    chatbot = HealthcareChatbot()
    chatbot.show()
    sys.exit(app.exec_())

if __name__ == "__main__":
    main()
