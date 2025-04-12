from fastapi import FastAPI
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
from translation import TranslatorModule
from azure_healthcare_bot import AzureBotThread
from enum import Enum
from dotenv import load_dotenv
import os
from starlette.concurrency import run_in_threadpool  # <-- added

# Load variables from .env file
load_dotenv()

AZURE_DIRECTLINE_SECRET = os.getenv("AZURE_DIRECTLINE_SECRET")
AZURE_DIRECTLINE_ENDPOINT = os.getenv("AZURE_DIRECTLINE_ENDPOINT")

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=[""],
    allow_credentials=True,
    allow_methods=[""],
    allow_headers=["*"],
)

class SupportedLanguages(str, Enum):
    english = "english"
    telugu = "telugu"
    hindi = "hindi"
    tamil = "tamil"

class MessageInput(BaseModel):
    message: str
    display_language: SupportedLanguages

translator = TranslatorModule()
bot = AzureBotThread()

@app.post("/get-response")
async def get_chatbot_response(input_data: MessageInput):
    user_message = input_data.message
    target_lang = input_data.display_language.lower()

    # Detect the language of the user's message
    detected_lang = await run_in_threadpool(translator.detect_language, user_message)
    print(f"[Detected Lang]: {detected_lang}")

    # Translate to English
    if detected_lang != "english":
        user_message = await run_in_threadpool(translator.translate_to_english, user_message, detected_lang)

    # Get bot response
    bot_response = await run_in_threadpool(bot.get_response, user_message)

    # Only store the requested display language, but always return in English
    original_target = target_lang
    
    # Skip translation regardless of requested language - always return English
    return {"response": bot_response, "requested_language": original_target}