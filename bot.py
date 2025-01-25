import sys
import requests
import json
from PyQt5.QtWidgets import QApplication, QMainWindow, QVBoxLayout, QTextEdit, QLineEdit, QPushButton, QWidget
from PyQt5.QtCore import QThread, pyqtSignal

# Configuration (replace with your actual Direct Line details)
AZURE_DIRECTLINE_SECRET = "2EEFI5Abj0WbAcKH5x77tjuqNaYddBc9I9IynapvJ0FlSJVs0fegJQQJ99BAACHYHv6AArohAAABAZBS27hs.9ZXl4UvXbGqi2Y129x90yfrnjp70IbplFOoqNOibKkF84yZA74oCJQQJ99BAACHYHv6AArohAAABAZBS1Wxk"
AZURE_DIRECTLINE_ENDPOINT = "https://directline.botframework.com/v3/directline"

# Worker Thread for Bot Communication
class BotThread(QThread):
    message_received = pyqtSignal(str)

    def __init__(self):
        super().__init__()
        self.running = True
        self.headers = {
            'Authorization': f'Bearer {AZURE_DIRECTLINE_SECRET}',
            'Content-Type': 'application/json'
        }
        self.conversation_id = self.start_conversation()

    def start_conversation(self):
        try:
            print("Starting conversation...")
            response = requests.post(f"{AZURE_DIRECTLINE_ENDPOINT}/conversations", headers=self.headers)
            print(f"Start Conversation Response: {response.status_code}, {response.text}")
            if response.status_code == 201:
                return response.json().get('conversationId')
            else:
                raise Exception(f"Failed to start conversation: {response.status_code}, {response.text}")
        except Exception as e:
            print(f"Error starting conversation: {e}")
            sys.exit(1)

    def send_message(self, message):
        try:
            print(f"Sending message: {message}")
            url = f"{AZURE_DIRECTLINE_ENDPOINT}/conversations/{self.conversation_id}/activities"
            payload = {'type': 'message', 'from': {'id': 'user'}, 'text': message}
            response = requests.post(url, headers=self.headers, data=json.dumps(payload))
            print(f"Send Message Response: {response.status_code}, {response.text}")
            if response.status_code not in [200, 201]:
                raise Exception(f"Failed to send message: {response.status_code}, {response.text}")
        except Exception as e:
            print(f"Error sending message: {e}")

    def run(self):
        watermark = ""
        while self.running:
            try:
                url = f"{AZURE_DIRECTLINE_ENDPOINT}/conversations/{self.conversation_id}/activities"
                if watermark:
                    url += f"?watermark={watermark}"
                print(f"Polling bot for messages at {url}")
                response = requests.get(url, headers=self.headers)
                print(f"Poll Response: {response.status_code}, {response.text}")
                if response.status_code == 200:
                    data = response.json()
                    watermark = data.get('watermark', '')
                    activities = data.get('activities', [])
                    for activity in activities:
                        if activity.get('from', {}).get('role') == 'bot' and activity.get('text'):
                            print(f"Bot Message: {activity['text']}")
                            self.message_received.emit(activity['text'])
                else:
                    print(f"Error polling bot: {response.status_code}, {response.text}")
            except Exception as e:
                print(f"Error in bot communication: {e}")
            self.msleep(2000)


    def stop(self):
        self.running = False


# Main Application Window
class ChatBotApp(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Healthcare Chatbot")
        self.setGeometry(100, 100, 600, 400)

        self.bot_thread = BotThread()
        self.bot_thread.message_received.connect(self.display_bot_message)
        self.bot_thread.start()

        self.init_ui()

    def init_ui(self):
        central_widget = QWidget()
        self.setCentralWidget(central_widget)

        layout = QVBoxLayout()

        # Chat display area
        self.chat_display = QTextEdit()
        self.chat_display.setReadOnly(True)
        layout.addWidget(self.chat_display)

        # Input area
        self.input_field = QLineEdit()
        self.input_field.setPlaceholderText("Type your message here...")
        layout.addWidget(self.input_field)

        # Send button
        send_button = QPushButton("Send")
        send_button.clicked.connect(self.send_message)
        layout.addWidget(send_button)

        central_widget.setLayout(layout)

    def send_message(self):
        user_message = self.input_field.text().strip()
        if user_message:
            self.chat_display.append(f"You: {user_message}")
            self.input_field.clear()
            self.bot_thread.send_message(user_message)

    def display_bot_message(self, message):
        self.chat_display.append(f"Bot: {message}")

    def closeEvent(self, event):
        self.bot_thread.stop()
        self.bot_thread.wait()
        event.accept()


# Main entry point
if __name__ == "__main__":
    app = QApplication(sys.argv)
    chatbot_app = ChatBotApp()
    chatbot_app.show()
    sys.exit(app.exec_())
