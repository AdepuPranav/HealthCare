from googletrans import Translator

class TranslatorModule:
    def __init__(self):
        self.translator = Translator()

    def detect_language(self, text):
        detection = self.translator.detect(text)
        lang_code = detection.lang

        mapping = {
            'en': 'english',
            'hi': 'hindi',
            'te': 'telugu',
            'ta': 'tamil'
        }

        return mapping.get(lang_code, 'english')

    def translate_to_english(self, text, src_lang):
        lang_map = {
            'english': 'en',
            'hindi': 'hi',
            'telugu': 'te',
            'tamil': 'ta'
        }
        src_code = lang_map.get(src_lang.lower(), 'en')
        if src_code == 'en':
            return text
        return self.translator.translate(text, src=src_code, dest='en').text

    def translate_from_english(self, text, target_lang):
        lang_map = {
            'english': 'en',
            'hindi': 'hi',
            'telugu': 'te',
            'tamil': 'ta'
        }
        dest_code = lang_map.get(target_lang.lower(), 'en')
        if dest_code == 'en':
            return text
        return self.translator.translate(text, src='en', dest=dest_code).text
