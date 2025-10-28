# NER Backend API for OSINT Platform

Named Entity Recognition service using spaCy for extracting entities from text.

## Setup

### 1. Create Virtual Environment

```bash
cd ner_backend
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
python -m spacy download en_core_web_sm
```

### 3. Run the Server

```bash
python app.py
```

The server will start on `http://localhost:5000`

## API Endpoints

### Health Check
```
GET /health
```

Response:
```json
{
  "status": "healthy",
  "model_loaded": true,
  "model": "en_core_web_sm"
}
```

### Extract Entities
```
POST /ner/extract
Content-Type: application/json

{
  "text": "John Doe works at Acme Corp in New York. Contact: john@acme.com or +1-555-0123."
}
```

Response:
```json
{
  "text": "...",
  "entities": [
    {
      "text": "John Doe",
      "label": "PERSON",
      "start": 0,
      "end": 8,
      "confidence": 0.9
    },
    {
      "text": "Acme Corp",
      "label": "ORG",
      "start": 18,
      "end": 27,
      "confidence": 0.9
    },
    {
      "text": "john@acme.com",
      "label": "EMAIL",
      "start": 51,
      "end": 64,
      "confidence": 0.95
    }
  ],
  "entity_counts": {
    "PERSON": 1,
    "ORG": 1,
    "GPE": 1,
    "EMAIL": 1,
    "PHONE": 1
  },
  "model": "en_core_web_sm"
}
```

### Get Supported Types
```
GET /ner/types
```

Returns list of all supported entity types.

### Batch Processing
```
POST /ner/batch
Content-Type: application/json

{
  "texts": ["Text 1", "Text 2", "Text 3"]
}
```

## Supported Entity Types

### spaCy Standard Types
- PERSON - People
- ORG - Organizations
- GPE - Countries, cities, states
- LOC - Locations
- DATE - Dates
- TIME - Times
- MONEY - Monetary values
- And more...

### Custom Pattern-Based Types
- EMAIL - Email addresses
- PHONE - Phone numbers
- URL - Web URLs
- IP_ADDRESS - IP addresses
- CRYPTO_ADDRESS - Cryptocurrency addresses

## Development

The backend uses:
- **Flask** - Web framework
- **spaCy** - NLP and NER
- **Flask-CORS** - CORS support for Flutter app

## Production Deployment

For production, use a production WSGI server like Gunicorn:

```bash
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```
