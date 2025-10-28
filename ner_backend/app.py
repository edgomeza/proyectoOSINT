#!/usr/bin/env python3
"""
NER (Named Entity Recognition) Backend API for OSINT Platform
Uses spaCy for entity extraction from text
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import spacy
import re
from typing import List, Dict, Any

app = Flask(__name__)
CORS(app)

# Load spaCy model (install with: python -m spacy download en_core_web_sm)
try:
    nlp = spacy.load("en_core_web_sm")
except OSError:
    print("Error: spaCy model 'en_core_web_sm' not found")
    print("Please install it with: python -m spacy download en_core_web_sm")
    nlp = None


class EntityExtractor:
    """Handles entity extraction from text"""

    def __init__(self, nlp_model):
        self.nlp = nlp_model

    def extract_entities(self, text: str) -> Dict[str, Any]:
        """Extract named entities from text"""

        if not self.nlp:
            return {
                "text": text,
                "entities": [],
                "entity_counts": {},
                "model": "none",
                "error": "spaCy model not loaded"
            }

        # Process text with spaCy
        doc = self.nlp(text)

        # Extract spaCy entities
        entities = []
        entity_counts = {}

        for ent in doc.ents:
            entity_data = {
                "text": ent.text,
                "label": ent.label_,
                "start": ent.start_char,
                "end": ent.end_char,
                "confidence": 0.9  # spaCy doesn't provide confidence scores by default
            }
            entities.append(entity_data)

            # Count entity types
            entity_counts[ent.label_] = entity_counts.get(ent.label_, 0) + 1

        # Extract additional patterns (emails, phones, URLs, IPs)
        pattern_entities = self._extract_patterns(text)
        entities.extend(pattern_entities)

        # Update counts
        for entity in pattern_entities:
            label = entity["label"]
            entity_counts[label] = entity_counts.get(label, 0) + 1

        return {
            "text": text,
            "entities": entities,
            "entity_counts": entity_counts,
            "model": "en_core_web_sm"
        }

    def _extract_patterns(self, text: str) -> List[Dict[str, Any]]:
        """Extract entities using regex patterns"""
        entities = []

        # Email pattern
        email_pattern = r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'
        for match in re.finditer(email_pattern, text):
            entities.append({
                "text": match.group(),
                "label": "EMAIL",
                "start": match.start(),
                "end": match.end(),
                "confidence": 0.95
            })

        # Phone pattern (various formats)
        phone_pattern = r'\b(?:\+?1[-.]?)?\(?([0-9]{3})\)?[-.]?([0-9]{3})[-.]?([0-9]{4})\b'
        for match in re.finditer(phone_pattern, text):
            entities.append({
                "text": match.group(),
                "label": "PHONE",
                "start": match.start(),
                "end": match.end(),
                "confidence": 0.9
            })

        # URL pattern
        url_pattern = r'https?://(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&/=]*)'
        for match in re.finditer(url_pattern, text):
            entities.append({
                "text": match.group(),
                "label": "URL",
                "start": match.start(),
                "end": match.end(),
                "confidence": 0.95
            })

        # IP address pattern
        ip_pattern = r'\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b'
        for match in re.finditer(ip_pattern, text):
            # Simple validation (not perfect but catches obvious IPs)
            ip = match.group()
            parts = ip.split('.')
            if all(0 <= int(part) <= 255 for part in parts):
                entities.append({
                    "text": ip,
                    "label": "IP_ADDRESS",
                    "start": match.start(),
                    "end": match.end(),
                    "confidence": 0.9
                })

        # Cryptocurrency addresses (Bitcoin example)
        crypto_pattern = r'\b[13][a-km-zA-HJ-NP-Z1-9]{25,34}\b'
        for match in re.finditer(crypto_pattern, text):
            entities.append({
                "text": match.group(),
                "label": "CRYPTO_ADDRESS",
                "start": match.start(),
                "end": match.end(),
                "confidence": 0.8
            })

        return entities


# Initialize extractor
extractor = EntityExtractor(nlp)


@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "model_loaded": nlp is not None,
        "model": "en_core_web_sm" if nlp else "none"
    }), 200


@app.route('/ner/extract', methods=['POST'])
def extract_entities():
    """Extract entities from text"""
    try:
        data = request.get_json()

        if not data or 'text' not in data:
            return jsonify({
                "error": "Missing 'text' field in request body"
            }), 400

        text = data['text']

        if not isinstance(text, str) or len(text) == 0:
            return jsonify({
                "error": "Text must be a non-empty string"
            }), 400

        # Extract entities
        result = extractor.extract_entities(text)

        return jsonify(result), 200

    except Exception as e:
        return jsonify({
            "error": str(e)
        }), 500


@app.route('/ner/types', methods=['GET'])
def get_entity_types():
    """Get supported entity types"""
    types = [
        "PERSON",       # People, including fictional
        "NORP",         # Nationalities or religious or political groups
        "FAC",          # Buildings, airports, highways, bridges, etc.
        "ORG",          # Companies, agencies, institutions, etc.
        "GPE",          # Countries, cities, states
        "LOC",          # Non-GPE locations, mountain ranges, bodies of water
        "PRODUCT",      # Objects, vehicles, foods, etc. (not services)
        "EVENT",        # Named hurricanes, battles, wars, sports events, etc.
        "WORK_OF_ART",  # Titles of books, songs, etc.
        "LAW",          # Named documents made into laws
        "LANGUAGE",     # Any named language
        "DATE",         # Absolute or relative dates or periods
        "TIME",         # Times smaller than a day
        "PERCENT",      # Percentage (including "%")
        "MONEY",        # Monetary values, including unit
        "QUANTITY",     # Measurements, as of weight or distance
        "ORDINAL",      # "first", "second", etc.
        "CARDINAL",     # Numerals that do not fall under another type
        "EMAIL",        # Email addresses (custom)
        "PHONE",        # Phone numbers (custom)
        "URL",          # URLs (custom)
        "IP_ADDRESS",   # IP addresses (custom)
        "CRYPTO_ADDRESS"  # Cryptocurrency addresses (custom)
    ]

    return jsonify({
        "types": types
    }), 200


@app.route('/ner/batch', methods=['POST'])
def extract_batch():
    """Extract entities from multiple texts"""
    try:
        data = request.get_json()

        if not data or 'texts' not in data:
            return jsonify({
                "error": "Missing 'texts' field in request body"
            }), 400

        texts = data['texts']

        if not isinstance(texts, list):
            return jsonify({
                "error": "'texts' must be a list of strings"
            }), 400

        results = []
        for text in texts:
            if isinstance(text, str) and len(text) > 0:
                result = extractor.extract_entities(text)
                results.append(result)
            else:
                results.append({
                    "text": text,
                    "entities": [],
                    "entity_counts": {},
                    "model": "none",
                    "error": "Invalid text"
                })

        return jsonify({
            "results": results,
            "count": len(results)
        }), 200

    except Exception as e:
        return jsonify({
            "error": str(e)
        }), 500


if __name__ == '__main__':
    print("=" * 60)
    print("NER Backend API for OSINT Platform")
    print("=" * 60)

    if nlp:
        print("✓ spaCy model loaded successfully")
    else:
        print("✗ spaCy model not loaded")
        print("  Install with: python -m spacy download en_core_web_sm")

    print("\nStarting server on http://localhost:5000")
    print("=" * 60)

    app.run(host='0.0.0.0', port=5000, debug=True)
