from googletrans import Translator

class TranslatorModule:
    def __init__(self):
        self.translator = Translator()

    def translate_to_english(self, text, lang):
        if lang.lower() in ['telugu (తెలుగు)', 'hindi (हिन्दी)', 'tamil (தமிழ்)']:
            src_lang = {
                'telugu (తెలుగు)': 'te',
                'hindi (हिन्दी)': 'hi',
                'tamil (தமிழ்)': 'ta'
            }.get(lang.lower(), 'en')
            return self.translator.translate(text, src=src_lang, dest='en').text
        return text

    def translate_from_english(self, text, lang):
        if lang.lower() == 'english':
            return text  # Skip translation for English

        if lang.lower() in ['telugu (తెలుగు)', 'hindi (हिन्दी)', 'tamil (தமிழ்)']:
            dest_lang = {
                'telugu (తెలుగు)': 'te',
                'hindi (हिन्दी)': 'hi',
                'tamil (தமிழ்)': 'ta'
            }.get(lang.lower(), 'en')
            return self.translator.translate(text, src='en', dest=dest_lang).text
        return text
