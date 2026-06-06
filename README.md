# Cattle Disease Detection Mobile App

A state-of-the-art Flutter mobile application powered by on-device computer vision and deep learning to detect cattle body parts and classify potential diseases. 

The application runs entirely offline using TFLite inference pipelines, allowing farmers and veterinarians to analyze cattle health in remote areas without an active internet connection.

---

## 🌟 Key Features

* **Custom YOLOv8 Segmentation**: Utilizes a custom-trained YOLOv8n-seg model to accurately locate and segment four key body parts:
  * **Head**
  * **Torso**
  * **Udder**
  * **Foot**
* **Targeted Disease Classification**: Performs secondary image classification (using specialized EfficientNet-B0 models) on each cropped body part to detect specific diseases.
* **On-Device Inference**: Offline, low-latency analysis using `tflite_flutter` execution.
* **Modern Material 3 UI**: Premium UI design featuring dark mode, glassmorphic widgets, loading overlays, micro-animations, and structured health reports.
* **Dynamic Model Manager**: A full-featured settings interface to download, update, and manage model files dynamically from GitHub Release assets.

---

## 🏗️ Architecture Layout

The codebase follows **Clean Architecture** principles and uses **Riverpod** for robust state management:

* **Presentation**: Clean, decoupled UI screens and controllers (Riverpod providers) for analysis, settings, and reporting.
* **Domain**: Pure business logic models (`DiseasePrediction`, `HealthReport`, `BodyPartReportItem`).
* **Data (Services)**:
  * `YoloSegmentationService` — Normalizes inputs, runs YOLOv8 segmentation, scales bounding boxes, and performs per-class Non-Maximum Suppression (NMS).
  * `CropService` — Performs rectangular bounding box cropping.
  * `TfliteClassifierService` — Runs specialized EfficientNet-B0 binary classifiers on cropped parts.
  * `ModelFileManager` — Manages manifest parsing, tracking local files, and background model downloads.

---

## 📊 YOLO Output Details
* **Output Shape**: `[1, 40, 8400]` (representing 4 box coordinates + 4 class confidence scores + 32 mask coefficients across 8400 grid anchors).
* **IoU Threshold**: `0.5` with per-class NMS to ensure overlapping detections of different body parts are successfully captured.

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (v3.18.0 or newer recommended)
* Android SDK (for building Android packages)

### Running Locally
1. Clone the repository:
   ```bash
   git clone https://github.com/OmarEraky/Cattle_Diseases_Detection_App.git
   cd Cattle_Diseases_Detection_App
   ```
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application on an emulator or connected device:
   ```bash
   flutter run
   ```

### Building the Release APK
To compile a production-ready, standalone APK:
```bash
flutter build apk --release
```
The output file will be saved in `build/app/outputs/flutter-apk/app-release.apk`.

---

## ⚙️ Model Initialization Setup
When launching the app for the first time, you must download the deep learning models:
1. Open the app and navigate to **Model Settings**.
2. Tap **Delete All** to clean up any legacy COCO/placeholder models.
3. Tap **Download Required** to download the custom-trained YOLO detector and the four body part classifier models.

---

## 🛡️ Disclaimer
This application is AI-assisted and designed for screening purposes. It is **not** a substitute for professional veterinary diagnosis. Always consult a veterinarian for official cattle health assessments.
