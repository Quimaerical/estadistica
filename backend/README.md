# Statistical Inference Backend

This backend uses FastAPI and SymPy to perform symbolic statistical inference.

## Setup

1.  **Install Python:** Ensure you have Python 3.8+ installed.
2.  **Install Dependencies:**
    ```bash
    pip install -r requirements.txt
    ```

## Running the Server

Run the following command in the `backend/` directory:

```bash
uvicorn main:app --reload
```

The API will be available at `http://127.0.0.1:8000`.
You can view the documentation at `http://127.0.0.1:8000/docs`.

## Flutter Integration

The Flutter app expects the backend to be running on `http://127.0.0.1:8000`.
Use `flutter run -d windows` (or your preferred device) to start the app.
