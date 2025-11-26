import os
import google.generativeai as genai
from flask import Flask, request, jsonify, abort
from PIL import Image
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

API_KEY = "AIzaSyAuaLHm8oaDfSgtiKD_M0amQ70bVTfZ888"
genai.configure(api_key=API_KEY)

model = genai.GenerativeModel('gemini-2.0-flash')

def build_multimodal_prompt(diseases):
    """
    Builds the prompt for Gemini, designed to work with both text and an image.
    The image itself will be passed as a separate part of the content.
    """
    disease_string = ", ".join(diseases)

    return f"""
    You are a universal health and safety AI assistant. Your goal is to give a simple 'Safe', 'Not Safe', or 'Caution' recommendation for a user based on their health conditions and a scanned product image.

    User's Health Conditions:
    {disease_string}

    ---
    YOUR TASKS:
    ---

    1.  **Step 1: Categorize Product.**
        First, analyze the *image* of the product to determine its category.
        Is it 'Food/Drink', 'Medication', 'Tobacco/Nicotine', or 'Other'?
        Identify text directly from the image.

    2.  **Step 2: Analyze Based on Category.**
        Now, analyze the product (from the image) against the user's conditions using the correct rules for that category.

        * **If 'Food/Drink':**
            Analyze the nutritional facts (e.g., high sugar, high sodium, high saturated fat, ingredients) visible in the image and how they impact the user's conditions.

        * **If 'Medication':**
            Analyze visible Active Ingredients, dosages, and Warnings. Check for known contraindications or interactions with the user's conditions (e.g., "Do not use if you have high blood pressure").

        * **If 'Tobacco/Nicotine':**
            Identify if it's a tobacco or nicotine product. The recommendation should almost always be 'Not Safe'. Explain *why* it's bad for their specific conditions (e.g., "Nicotine constricts blood vessels, which is extremely dangerous for high blood pressure.").

        * **If 'Other':**
            Use your best judgment to determine if there is a health risk based on visual information.

    3.  **Step 3: Respond.**
        Respond in this EXACT JSON format ONLY. Provide a 'recommendation' and a brief 'explanation' for your reasoning. Include the 'category' you identified.

    ```json
    {{
      "category": "Food/Drink" | "Medication" | "Tobacco/Nicotine" | "Other",
      "recommendation": "Safe" | "Not Safe" | "Caution",
      "explanation": "A single, brief sentence explaining your reasoning."
    }}
    ```
    """

# --- API Endpoint ---

@app.route("/analyze", methods=["POST"])
def analyze_nutrition():
    """
    API endpoint to analyze an uploaded product IMAGE using Gemini's vision capabilities.
    """

    if 'image' not in request.files:
        abort(400, description="No 'image' file part in the request.")

    file = request.files['image']

    if 'diseases' not in request.form:
        abort(400, description="No 'diseases' field in the form.")

    diseases_str = request.form['diseases']
    diseases_list = [d.strip() for d in diseases_str.split(',')]

    if not file or not diseases_list:
        abort(400, description="Missing image or disease data.")

    # --- End Validation ---

    try:
            # 1. Open the image file from the request stream using PIL
            img = Image.open(file.stream)

            # 2. The 'image_part' is just the PIL.Image object itself.
            image_part = img

            # Build the text part of the prompt
            text_prompt = build_multimodal_prompt(diseases_list)

            # Send both the text prompt and the image part to the model
            response = model.generate_content(
                [text_prompt, image_part],
                generation_config=genai.GenerationConfig(
                    response_mime_type="application/json"
                )
            )

            return response.text, 200

    except Exception as e:
        print(f"Error calling Gemini API: {e}")
        abort(500, description="Error processing your request.")

if __name__ == "__main__":

    app.run(host='0.0.0.0', port=5000, debug=True)