# Voice Live — Python Backend

FastAPI WebSocket server that bridges a browser frontend with Azure Voice Live SDK.

## Architecture

```
Frontend (React+Vite) → WebSocket → app.py → voice_handler.py → Azure Voice Live SDK
```

The Python backend follows SDK-idiomatic patterns using a `@dataclass SessionConfig` with typed
builder methods that return SDK objects directly:

- `SessionConfig.get_voice()` → `AzureStandardVoice`
- `SessionConfig.get_turn_detection()` → `AzureSemanticVad` / `ServerVad` / etc.
- `SessionConfig.get_transcription_options()` → `AudioInputTranscriptionOptions`
- `SessionConfig.get_interim_response_config()` → `LlmInterimResponseConfig` / `StaticInterimResponseConfig`
- `SessionConfig.build_model_session()` → `RequestSession`
- `SessionConfig.build_agent_session()` → `RequestSession`

## Quick Start

### 1. Set up the environment

```bash
# Configure environment
cp example.env .env
# Edit .env with your Azure Voice Live credentials

# Create and activate virtual environment
python -m venv .venv
.venv\Scripts\activate        # Windows
# source .venv/bin/activate   # macOS/Linux

# Install backend dependencies
pip install -r requirements.txt

# Install frontend dependencies
npm install --prefix ./frontend
```

### 2. Run the application

This project has a Python backend and a React frontend that need to run simultaneously.

**Option 1: Using run.sh (Recommended)**

The easiest way to start both the backend and frontend together:

```bash
./run.sh
```

This script will:

1. Verify that a `.env` file exists
2. Start the backend server in the background
3. Start the frontend dev server
4. Automatically stop the backend when the frontend exits

**Option 2: Running manually**

Start the backend:

```bash
uvicorn app:app --host localhost --port 8000 --reload
```

Start the frontend (in a separate terminal):

```bash
cd frontend
npm run dev
```

The frontend will be available at `http://localhost:5173` and will connect to the backend at `http://localhost:8000`.

## Connection Modes

Set `VOICELIVE_MODE` in `.env`:

| Mode    | Description                                                |
| ------- | ---------------------------------------------------------- |
| `model` | Connects directly to a model (e.g. gpt-realtime) — default |
| `agent` | Connects via Foundry Agent Service                         |

## Settings

All settings are configurable from the frontend UI. Default values can be set via `.env`:

| Setting      | Env Variable                 | Default                          |
| ------------ | ---------------------------- | -------------------------------- |
| Model        | `VOICELIVE_MODEL`            | `gpt-realtime`                   |
| Voice        | `VOICELIVE_VOICE`            | `en-US-Ava:DragonHDLatestNeural` |
| Temperature  | `VOICELIVE_TEMPERATURE`      | `0.7`                            |
| VAD Type     | `VOICELIVE_VAD_TYPE`         | `azure_semantic`                 |
| Instructions | `VOICELIVE_INSTRUCTIONS`     | _(empty)_                        |
| Agent Name   | `AZURE_VOICELIVE_AGENT_NAME` | _(required for agent mode)_      |
| Project      | `AZURE_VOICELIVE_PROJECT`    | _(required for agent mode)_      |

## Running Tests

```bash
pip install pytest
python -m pytest tests/ -v
```

## Notes

No Python-specific limitations at this time. All frontend features are supported.

## WebSocket Protocol

Connect to `ws://localhost:8000/ws/{client_id}` and exchange JSON messages:

**Client → Server:**

- `{ "type": "start_session", "mode": "model", "model": "gpt-realtime", ... }` — start voice session
- `{ "type": "audio_chunk", "data": "<base64 PCM16>" }` — stream microphone audio
- `{ "type": "interrupt" }` — cancel current response
- `{ "type": "stop_session" }` — end session

**Server → Client:**

- `{ "type": "session_started", "config": { ... } }`
- `{ "type": "audio_data", "data": "<base64 PCM16>", "sampleRate": 24000 }`
- `{ "type": "transcript", "role": "user"|"assistant", "text": "...", "isFinal": bool }`
- `{ "type": "status", "state": "listening"|"thinking"|"speaking" }`
- `{ "type": "stop_playback" }`
- `{ "type": "session_stopped" }`
- `{ "type": "error", "message": "..." }`
