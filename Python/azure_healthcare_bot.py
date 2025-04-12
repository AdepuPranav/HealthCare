import requests
import json
from PyQt5.QtCore import QThread, pyqtSignal

import time
from dotenv import load_dotenv
import os

# Load variables from .env file
load_dotenv()

AZURE_DIRECTLINE_SECRET = os.getenv("AZURE_DIRECTLINE_SECRET")
AZURE_DIRECTLINE_ENDPOINT = os.getenv("AZURE_DIRECTLINE_ENDPOINT")


class AzureBotThread(QThread):
    message_received = pyqtSignal(str)

    def __init__(self):
        super().__init__()
        self.directline_secret = AZURE_DIRECTLINE_SECRET
        self.directline_endpoint = AZURE_DIRECTLINE_ENDPOINT
        self.running = True


        self.headers = {
            'Authorization': f'Bearer {self.directline_secret}',
            'Content-Type': 'application/json'
        }

        self.conversation_id = self.start_conversation()

    def start_conversation(self):
        start_url = f'{self.directline_endpoint}/conversations'
        print(f"Start Conversation URL: {start_url}")  # Debugging
        try:
            response = requests.post(start_url, headers=self.headers)
            print(f"Start Conversation Response: {response.status_code}, {response.text}")  # Debugging
            if response.status_code == 201:
                conversation_id = response.json().get('conversationId')
                print(f"Conversation ID: {conversation_id}")  # Debugging
                return conversation_id
            else:
                raise Exception(f"Failed to start conversation: {response.status_code}, {response.text}")
        except requests.exceptions.RequestException as e:
            raise Exception(f"Error in start_conversation: {e}")
        
    def get_response(self, message):
        conversation_id = self.start_conversation()
        if not conversation_id:
            return "Unable to start conversation."

        send_url = f'{self.directline_endpoint}/conversations/{conversation_id}/activities'
        payload = {
        'type': 'message',
        'from': {'id': 'user'},
        'text': message
        }

        try:
            send_response = requests.post(send_url, headers=self.headers, json=payload)
            print(f"Send Message Response: {send_response.status_code}, {send_response.text}")
            if send_response.status_code not in [200, 201]:
                return "Error sending message to bot."
        except Exception as e:
            return f"Exception during message send: {e}"

    # Retry up to 5 times to get a response
        receive_url = f'{self.directline_endpoint}/conversations/{conversation_id}/activities'
        for i in range(10):  # try 10 times
            print(f"Polling attempt {i + 1}...")
            time.sleep(2)

            try:
                reply = requests.get(receive_url, headers=self.headers)
                activities = reply.json().get('activities', [])
                for activity in activities:
                    if activity.get('from', {}).get('id') != 'user':
                        response_text = self.extract_text_from_activity(activity)
                        if response_text:
                            return response_text
            except Exception as e:
                return f"Error retrieving message: {e}"

        return "No response from bot after multiple attempts."


    def send_message_to_bot(self, message):
        try:
            print(f"Sending message to Direct Line: {message}")  # Debugging
            send_url = f'{self.directline_endpoint}/conversations/{self.conversation_id}/activities'
            print(f"Send Message URL: {send_url}")  # Debugging
            payload = {
                'type': 'message',
                'from': {'id': 'user'},
                'text': message
            }
            print(f"Payload: {json.dumps(payload, indent=2)}")  # Debugging
            response = requests.post(send_url, headers=self.headers, data=json.dumps(payload))
            print(f"Send Message Response: {response.status_code}, {response.text}")  # Debugging
            if response.status_code not in [200, 201]:
                print(f"Message send failed: {response.status_code}, {response.text}")
        except Exception as e:
            print(f"Error sending message: {e}")

    def run(self):
        watermark = ''
        while self.running:
            try:
                response_url = f'{self.directline_endpoint}/conversations/{self.conversation_id}/activities'
                if watermark:
                    response_url += f"?watermark={watermark}"
                print(f"Polling URL: {response_url}")  # Debugging

                response = requests.get(response_url, headers=self.headers)
                print(f"Polling Response: {response.status_code}")  # Debugging
                if response.status_code == 200:
                    data = response.json()
                    print("Full Response Data:", json.dumps(data, indent=2))  # Debugging
                    activities = data.get('activities', [])
                    watermark = data.get('watermark', '')

                    for activity in activities:
                        print("Activity Details:", json.dumps(activity, indent=2))  # Debugging
                        if activity.get('type') == 'message' and activity.get('from', {}).get('id') == 'healthbot-jptfn7u':
                            bot_text = self.extract_text_from_activity(activity)
                            if bot_text:
                                print(f"Emittin.g Bot Message: {bot_text}")  # Debugging
                                self.message_received.emit(bot_text)
                else:
                    print(f"Error retrieving messages: {response.status_code}, {response.text}")
            except Exception as e:
                print(f"Error in run loop: {e}")
                import traceback
                traceback.print_exc()
            
            self.msleep(2000)
            

    def extract_text_from_activity(self, activity):
        """Extracts the main text from an activity, including Adaptive Card content."""
        try:
            if 'attachments' in activity:
                for attachment in activity['attachments']:
                    if attachment.get('contentType') == 'application/vnd.microsoft.card.adaptive':
                        content = attachment.get('content', {})
                        if 'body' in content:
                            for item in content['body']:
                                if item.get('type') == 'Container' and 'items' in item:
                                    for sub_item in item['items']:
                                        if sub_item.get('id') == 'generativeText' and 'text' in sub_item:
                                            print(f"Extracted Adaptive Card Text: {sub_item['text']}")  # Debugging
                                            return sub_item['text']
            plain_text = activity.get('text')
            print(f"Extracted Plain Text: {plain_text}")  # Debugging
            return plain_text
        except Exception as e:
            print(f"Error extracting text from activity: {e}")
            return None

    def stop(self):
        print("Stopping AzureBotThread...")  # Debugging
        self.running = False
