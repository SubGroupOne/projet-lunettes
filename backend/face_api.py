"""
Smart Vision - Face API v3
Compatible mediapipe 0.10.32+
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import cv2
import numpy as np
import base64
import requests
import os
import re

app = Flask(__name__)
CORS(app)

NODE_BACKEND = "http://localhost:3000"
GLASSES_ASSETS_PATH = "/home/eddy/projet-lunettes-1/frontend/assets/glasses/3D/"

# ─── Import MediaPipe nouvelle API ─────────────────────────
try:
    import mediapipe as mp
    from mediapipe.tasks import python as mp_python
    from mediapipe.tasks.python import vision as mp_vision

    BaseOptions = mp_python.BaseOptions
    FaceLandmarker = mp_vision.FaceLandmarker
    FaceLandmarkerOptions = mp_vision.FaceLandmarkerOptions
    VisionRunningMode = mp_vision.RunningMode

    MODEL_PATH = "face_landmarker.task"
    if not os.path.exists(MODEL_PATH):
        import urllib.request
        print("Téléchargement du modèle MediaPipe...")
        urllib.request.urlretrieve(
            "https://storage.googleapis.com/mediapipe-models/face_landmarker/face_landmarker/float16/1/face_landmarker.task",
            MODEL_PATH
        )
        print("Modèle téléchargé ✅")

    options = FaceLandmarkerOptions(
        base_options=BaseOptions(model_asset_path=MODEL_PATH),
        running_mode=VisionRunningMode.IMAGE,
        num_faces=1,
        min_face_detection_confidence=0.5,
    )
    landmarker = FaceLandmarker.create_from_options(options)
    MEDIAPIPE_AVAILABLE = True
    print("✅ MediaPipe chargé (nouvelle API)")

except Exception as e:
    print(f"⚠️  MediaPipe non disponible ({e}), fallback OpenCV")
    MEDIAPIPE_AVAILABLE = False

# ─── Import Tesseract OCR ───────────────────────────────────
try:
    import pytesseract
    from PIL import Image as PILImage
    TESSERACT_AVAILABLE = True
    print("✅ Tesseract OCR chargé")
except Exception as e:
    TESSERACT_AVAILABLE = False
    print(f"⚠️  Tesseract non disponible ({e})")

# ─── Fallback OpenCV ────────────────────────────────────────
face_cascade = cv2.CascadeClassifier(
    cv2.data.haarcascades + "haarcascade_frontalface_default.xml"
)

# ─── Catalogue (tes fichiers GLB) ──────────────────────────
LOCAL_CATALOG = [
    {"id": "1",  "name": "Black Classic", "brand": "Smart", "mainImage": "black_eyeglasses.glb",                      "price": 145},
    {"id": "2",  "name": "Eyeglasses",    "brand": "Smart", "mainImage": "eyeglasses.glb",                            "price": 120},
    {"id": "3",  "name": "Modele A01",    "brand": "Smart", "mainImage": "eyeglasses_a01.glb",                        "price": 110},
    {"id": "4",  "name": "Black V5",      "brand": "Smart", "mainImage": "eyeglasses_black_v5.glb",                   "price": 160},
    {"id": "5",  "name": "Specs",         "brand": "Smart", "mainImage": "eyeglasses_specs.glb",                      "price": 135},
    {"id": "6",  "name": "Eyewear",       "brand": "Smart", "mainImage": "eyewear_specs.glb",                         "price": 125},
    {"id": "7",  "name": "Glasses",       "brand": "Smart", "mainImage": "glasses.glb",                               "price": 130},
    {"id": "8",  "name": "Ray-Ban",       "brand": "Smart", "mainImage": "ray_ban_glasses.glb",                       "price": 140},
    {"id": "9",  "name": "Rounded",       "brand": "Smart", "mainImage": "rounded_rectangle_eyeglasses.glb",          "price": 115},
    {"id": "10", "name": "Wayfarer",      "brand": "Smart", "mainImage": "wayfarer_sunglasses_-_eyeglasses_rims.glb", "price": 155},
    {"id": "11", "name": "Wayfarer V2",   "brand": "Smart", "mainImage": "wayfarer_sunglasses_eyeglasses_rims.glb",   "price": 170},
]

SHAPE_RECOMMENDATIONS = {
    "ovale":     {"emoji": "😊", "description": "Visage ovale — Compatible avec presque toutes les montures !", "frames": ["Aviator", "Wayfarer", "Rondes", "Rectangulaires"], "avoid": ["Trop grandes"], "glasses_ids": ["1", "2", "3"]},
    "rond":      {"emoji": "🔵", "description": "Visage rond — Des montures qui allongent et structurent.", "frames": ["Wayfarer", "Rectangulaires", "Geometriques"], "avoid": ["Rondes", "Petites"], "glasses_ids": ["2", "4"]},
    "carre":     {"emoji": "⬜", "description": "Visage carre — Des courbes douces pour adoucir vos traits.", "frames": ["Rondes", "Aviator", "Cat-Eye", "Ovales"], "avoid": ["Carrees", "Angulaires"], "glasses_ids": ["1", "3"]},
    "rectangle": {"emoji": "📱", "description": "Visage rectangle — Des montures larges pour equilibrer.", "frames": ["Rondes", "Aviator", "Cat-Eye", "Oversized"], "avoid": ["Tres etroites"], "glasses_ids": ["1", "3"]},
    "allonge":   {"emoji": "🥚", "description": "Visage allonge — Des montures hautes et larges.", "frames": ["Rondes larges", "Carrees hautes", "Clubmaster"], "avoid": ["Fines", "Petites"], "glasses_ids": ["3", "4"]},
}

LEFT_EYE_OUTER  = 33
LEFT_EYE_INNER  = 133
RIGHT_EYE_INNER = 362
RIGHT_EYE_OUTER = 263


# ═══════════════════════════════════════════
# UTILITAIRES
# ═══════════════════════════════════════════

def decode_base64_image(b64_str):
    if "," in b64_str:
        b64_str = b64_str.split(",")[1]
    raw = base64.b64decode(b64_str)
    arr = np.frombuffer(raw, np.uint8)
    return cv2.imdecode(arr, cv2.IMREAD_COLOR)


def encode_image_to_base64(img, quality=88):
    _, buf = cv2.imencode(".jpg", img, [cv2.IMWRITE_JPEG_QUALITY, quality])
    return "data:image/jpeg;base64," + base64.b64encode(buf).decode()


def remove_white_background(img_bgr, threshold=230):
    bgra = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2BGRA)
    gray = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2GRAY)
    _, mask = cv2.threshold(gray, threshold, 255, cv2.THRESH_BINARY)
    mask_inv = cv2.bitwise_not(mask)
    kernel = np.ones((3, 3), np.uint8)
    mask_inv = cv2.morphologyEx(mask_inv, cv2.MORPH_CLOSE, kernel)
    mask_inv = cv2.GaussianBlur(mask_inv, (3, 3), 0)
    bgra[:, :, 3] = mask_inv
    return bgra


def get_eye_points_mediapipe(image_bgr):
    if not MEDIAPIPE_AVAILABLE:
        return None
    try:
        image_rgb = cv2.cvtColor(image_bgr, cv2.COLOR_BGR2RGB)
        mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=image_rgb)
        result = landmarker.detect(mp_image)
        if not result.face_landmarks:
            return None
        h, w = image_bgr.shape[:2]
        lm = result.face_landmarks[0]
        return {
            "left_outer":  (int(lm[LEFT_EYE_OUTER].x  * w), int(lm[LEFT_EYE_OUTER].y  * h)),
            "left_inner":  (int(lm[LEFT_EYE_INNER].x  * w), int(lm[LEFT_EYE_INNER].y  * h)),
            "right_inner": (int(lm[RIGHT_EYE_INNER].x * w), int(lm[RIGHT_EYE_INNER].y * h)),
            "right_outer": (int(lm[RIGHT_EYE_OUTER].x * w), int(lm[RIGHT_EYE_OUTER].y * h)),
        }
    except Exception as e:
        print(f"MediaPipe erreur: {e}")
        return None


def get_eye_points_opencv(image_bgr):
    gray = cv2.cvtColor(image_bgr, cv2.COLOR_BGR2GRAY)
    faces = face_cascade.detectMultiScale(gray, 1.1, 5, minSize=(80, 80))
    if len(faces) == 0:
        return None
    x, y, w, h = faces[0]
    left_outer  = (x + int(w * 0.1), y + int(h * 0.38))
    right_outer = (x + int(w * 0.9), y + int(h * 0.38))
    return {
        "left_outer":  left_outer,
        "right_outer": right_outer,
        "face": (x, y, w, h),
    }


def overlay_glasses(image, eye_points, glasses_path):
    if not os.path.exists(glasses_path):
        return None
    if glasses_path.endswith('.glb'):
        return None
    glasses_img = cv2.imread(glasses_path)
    if glasses_img is None:
        return None
    left_outer  = eye_points["left_outer"]
    right_outer = eye_points["right_outer"]
    glasses_width = int(abs(right_outer[0] - left_outer[0]) * 1.35)
    if glasses_width < 10:
        return None
    orig_h, orig_w = glasses_img.shape[:2]
    glasses_height = int(glasses_width * (orig_h / orig_w))
    dx = right_outer[0] - left_outer[0]
    dy = right_outer[1] - left_outer[1]
    angle = np.degrees(np.arctan2(dy, dx))
    cx = (left_outer[0] + right_outer[0]) // 2
    cy = (left_outer[1] + right_outer[1]) // 2
    cy = int(cy - glasses_height * 0.08)
    glasses_rgba = remove_white_background(glasses_img)
    glasses_resized = cv2.resize(glasses_rgba, (glasses_width, glasses_height))
    if abs(angle) > 0.5:
        M = cv2.getRotationMatrix2D((glasses_width // 2, glasses_height // 2), angle, 1.0)
        glasses_resized = cv2.warpAffine(glasses_resized, M, (glasses_width, glasses_height),
            flags=cv2.INTER_LINEAR, borderMode=cv2.BORDER_CONSTANT, borderValue=(0, 0, 0, 0))
    result = image.copy()
    x1 = max(0, cx - glasses_width // 2)
    y1 = max(0, cy - glasses_height // 2)
    x2 = min(result.shape[1], x1 + glasses_width)
    y2 = min(result.shape[0], y1 + glasses_height)
    gx1 = x1 - (cx - glasses_width // 2)
    gy1 = y1 - (cy - glasses_height // 2)
    gx2 = gx1 + (x2 - x1)
    gy2 = gy1 + (y2 - y1)
    if gx2 <= gx1 or gy2 <= gy1 or gx1 < 0 or gy1 < 0:
        return result
    glasses_crop = glasses_resized[gy1:gy2, gx1:gx2]
    if glasses_crop.shape[2] < 4:
        return result
    alpha = glasses_crop[:, :, 3:4] / 255.0
    blended = (glasses_crop[:, :, :3] * alpha + result[y1:y2, x1:x2] * (1 - alpha)).astype(np.uint8)
    result[y1:y2, x1:x2] = blended
    return result


def apply_glasses(image, glasses_path):
    eye_points = get_eye_points_mediapipe(image)
    if eye_points is None:
        eye_points = get_eye_points_opencv(image)
    if eye_points is None:
        return None
    return overlay_glasses(image, eye_points, glasses_path)


def get_face_shape(image_bgr):
    if MEDIAPIPE_AVAILABLE:
        try:
            image_rgb = cv2.cvtColor(image_bgr, cv2.COLOR_BGR2RGB)
            mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=image_rgb)
            result = landmarker.detect(mp_image)
            if result.face_landmarks:
                h, w = image_bgr.shape[:2]
                lm = result.face_landmarks[0]
                face_width  = abs(lm[454].x - lm[234].x) * w
                face_height = abs(lm[152].y - lm[10].y)  * h
                ratio = face_width / face_height if face_height > 0 else 1.0
                if ratio < 0.75:   return "ovale"
                elif ratio < 0.85: return "allonge"
                elif ratio < 0.95: return "rectangle"
                elif ratio < 1.05: return "carre"
                else:              return "rond"
        except Exception:
            pass
    gray = cv2.cvtColor(image_bgr, cv2.COLOR_BGR2GRAY)
    faces = face_cascade.detectMultiScale(gray, 1.1, 5, minSize=(80, 80))
    if len(faces) == 0:
        return None
    x, y, w, h = faces[0]
    ratio = w / h
    if ratio < 0.75:   return "ovale"
    elif ratio < 0.85: return "allonge"
    elif ratio < 0.95: return "rectangle"
    elif ratio < 1.05: return "carre"
    else:              return "rond"


# ─── Parser ordonnance ──────────────────────────────────────
def parse_ordonnance(text):
    lines = text.lower().split('\n')
    result = {
        "od_sph": "-", "od_cyl": "-", "od_axe": "-",
        "og_sph": "-", "og_cyl": "-", "og_axe": "-",
        "ecart_pupillaire": "-"
    }

    def extract_number(s):
        m = re.search(r'([+-]?\d+[.,]\d+)', s)
        return m.group(1).replace(',', '.') if m else None

    def extract_after(line, keywords):
        for kw in keywords:
            idx = line.find(kw)
            if idx != -1:
                after = line[idx + len(kw):]
                m = re.search(r'[:\s]*([+-]?\d+[.,]?\d*)', after)
                if m:
                    return m.group(1).replace(',', '.')
        return None

    for line in lines:
        if re.search(r'\bod\b|oeil droit|droit', line):
            result["od_sph"] = extract_after(line, ['sph', 'sphere']) or extract_number(line) or "-"
            result["od_cyl"] = extract_after(line, ['cyl', 'cylindre']) or "-"
            result["od_axe"] = extract_after(line, ['axe', 'ax', 'axis']) or "-"
        if re.search(r'\bog\b|oeil gauche|gauche', line):
            result["og_sph"] = extract_after(line, ['sph', 'sphere']) or extract_number(line) or "-"
            result["og_cyl"] = extract_after(line, ['cyl', 'cylindre']) or "-"
            result["og_axe"] = extract_after(line, ['axe', 'ax', 'axis']) or "-"
        if re.search(r'\bep\b|\bpd\b|ecart|pupillaire', line):
            n = extract_number(line)
            if n:
                result["ecart_pupillaire"] = f"{n} mm"

    full = text.lower()
    if result["od_sph"] == "-":
        m = re.search(r'(?:od|droit)[:\s]*([+-]?\d+[.,]\d+)', full)
        if m: result["od_sph"] = m.group(1).replace(',', '.')
    if result["og_sph"] == "-":
        m = re.search(r'(?:og|gauche)[:\s]*([+-]?\d+[.,]\d+)', full)
        if m: result["og_sph"] = m.group(1).replace(',', '.')
    if result["ecart_pupillaire"] == "-":
        m = re.search(r'(?:ep|pd)[:\s]*(\d{2})', full)
        if m: result["ecart_pupillaire"] = f"{m.group(1)} mm"

    return result


# ═══════════════════════════════════════════
# ROUTES
# ═══════════════════════════════════════════

@app.route("/health", methods=["GET"])
def health():
    available = [g["mainImage"] for g in LOCAL_CATALOG
                 if os.path.exists(os.path.join(GLASSES_ASSETS_PATH, g["mainImage"]))]
    return jsonify({
        "status": "ok",
        "service": "Smart Vision Face API v3",
        "mediapipe": MEDIAPIPE_AVAILABLE,
        "tesseract": TESSERACT_AVAILABLE,
        "images_available": available,
        "total": len(available)
    })


@app.route("/glasses", methods=["GET"])
def get_glasses():
    token = request.headers.get("Authorization", "")
    try:
        res = requests.get(f"{NODE_BACKEND}/glasses",
                           headers={"Authorization": token}, timeout=3)
        if res.status_code == 200:
            return jsonify({"success": True, "source": "sql", "catalog": res.json()})
    except Exception:
        pass
    return jsonify({"success": True, "source": "local", "catalog": LOCAL_CATALOG})


@app.route("/analyze", methods=["POST"])
def analyze():
    try:
        data = request.get_json()
        image = decode_base64_image(data["image"])
        shape = get_face_shape(image)
        if shape is None:
            return jsonify({"success": False, "error": "Aucun visage detecte. Soyez face a la camera."})
        reco = SHAPE_RECOMMENDATIONS.get(shape, SHAPE_RECOMMENDATIONS["ovale"])
        preview = image.copy()
        eye_points = get_eye_points_mediapipe(image) or get_eye_points_opencv(image)
        if eye_points:
            for key in ["left_outer", "right_outer"]:
                if key in eye_points:
                    cv2.circle(preview, eye_points[key], 6, (99, 102, 241), -1)
        return jsonify({
            "success": True,
            "face_shape": shape,
            "recommendation": reco,
            "preview_image": encode_image_to_base64(preview),
        })
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@app.route("/try-on", methods=["POST"])
def try_on():
    try:
        data = request.get_json()
        image = decode_base64_image(data["image"])
        glasses_filename = data.get("glasses_image", "eyeglasses.glb")
        glasses_path = os.path.join(GLASSES_ASSETS_PATH, glasses_filename)
        if glasses_filename.endswith('.glb'):
            return jsonify({
                "success": False,
                "error": "Fichier GLB détecté. Utilisez l'Essai 3D pour les modèles GLB.",
                "redirect_3d": True
            })
        result = apply_glasses(image, glasses_path)
        if result is None:
            return jsonify({"success": False, "error": "Visage non detecte ou image introuvable."})
        return jsonify({"success": True, "result_image": encode_image_to_base64(result)})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@app.route("/try-on-live", methods=["POST"])
def try_on_live():
    try:
        data = request.get_json()
        image = decode_base64_image(data["frame"])
        glasses_filename = data.get("glasses_image", "eyeglasses.glb")
        glasses_path = os.path.join(GLASSES_ASSETS_PATH, glasses_filename)
        result = apply_glasses(image, glasses_path)
        face_detected = result is not None
        if result is None:
            result = image
        return jsonify({
            "success": True,
            "result_frame": encode_image_to_base64(result, quality=72),
            "face_detected": face_detected,
        })
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@app.route("/scan-ordonnance", methods=["POST"])
def scan_ordonnance():
    if not TESSERACT_AVAILABLE:
        return jsonify({"success": False, "error": "Tesseract OCR non disponible."}), 503
    try:
        data = request.get_json()
        if not data or "image" not in data:
            return jsonify({"success": False, "error": "Image manquante."}), 400

        image_bgr = decode_base64_image(data["image"])
        if image_bgr is None:
            return jsonify({"success": False, "error": "Image invalide."}), 400

        # Prétraitement pour améliorer l'OCR
        gray = cv2.cvtColor(image_bgr, cv2.COLOR_BGR2GRAY)
        gray = cv2.resize(gray, None, fx=2, fy=2, interpolation=cv2.INTER_LINEAR)
        gray = cv2.GaussianBlur(gray, (1, 1), 0)
        _, gray = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)

        pil_image = PILImage.fromarray(gray)
        config = '--oem 3 --psm 6 -l fra+eng'
        raw_text = pytesseract.image_to_string(pil_image, config=config)

        if not raw_text.strip():
            return jsonify({"success": False, "error": "Aucun texte détecté. Vérifiez la qualité de l'image."}), 400

        parsed = parse_ordonnance(raw_text)
        return jsonify({
            "success":          True,
            "raw_text":         raw_text.strip(),
            "od_sph":           parsed["od_sph"],
            "od_cyl":           parsed["od_cyl"],
            "od_axe":           parsed["od_axe"],
            "og_sph":           parsed["og_sph"],
            "og_cyl":           parsed["og_cyl"],
            "og_axe":           parsed["og_axe"],
            "ecart_pupillaire": parsed["ecart_pupillaire"],
        })
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


if __name__ == "__main__":
    print("=" * 55)
    print("  Smart Vision - Face API v3")
    print(f"  MediaPipe disponible : {MEDIAPIPE_AVAILABLE}")
    print(f"  Tesseract disponible : {TESSERACT_AVAILABLE}")
    print(f"  Images : {GLASSES_ASSETS_PATH}")
    print("  http://localhost:5001")
    print("=" * 55)
    found = 0
    for g in LOCAL_CATALOG:
        path = os.path.join(GLASSES_ASSETS_PATH, g["mainImage"])
        status = "OK" if os.path.exists(path) else "MANQUANT"
        print(f"  [{status}] {g['mainImage']}")
        if os.path.exists(path):
            found += 1
    print(f"\n  {found}/{len(LOCAL_CATALOG)} images trouvees")
    print("=" * 55)
    app.run(host="0.0.0.0", port=5001, debug=True)