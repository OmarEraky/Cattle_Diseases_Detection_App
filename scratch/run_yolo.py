import numpy as np
import onnxruntime as ort
from PIL import Image

# 1. Load and inspect ONNX model session
session = ort.InferenceSession('/tmp/yolo.onnx')
input_name = session.get_inputs()[0].name
input_shape = session.get_inputs()[0].shape
print(f"ONNX Model Input: name='{input_name}', shape={input_shape}")

# 2. Preprocess image
img = Image.open('/tmp/cow.jpg').convert('RGB')
img = img.resize((640, 640))
img_data = np.array(img).astype(np.float32) / 255.0

# If input shape is NCHW [1, 3, 640, 640], transpose the image
if input_shape[1] == 3:
    img_data = np.transpose(img_data, (2, 0, 1)) # HWC to CHW
img_data = np.expand_dims(img_data, axis=0) # Add batch dimension

print(f"Preprocessed image shape: {img_data.shape}")

# 3. Run inference
outputs = session.run(None, {input_name: img_data})
output0 = outputs[0]
output1 = outputs[1]

print(f"Output 0 shape: {output0.shape}")
print(f"Output 1 shape: {output1.shape}")

# 4. Print stats about Output 0 (shape [1, 116, 8400])
# We want to find the columns with high scores.
# Let's check all columns:
print("\nTop detections:")
num_classes_to_check = 80 # check all 80 classes to see where the signals are!
detections = []
for col in range(8400):
    # Search for max class score among all 80 classes (indices 4 to 83)
    scores = output0[0, 4:4+num_classes_to_check, col]
    max_idx = np.argmax(scores)
    max_score = scores[max_idx]
    if max_score > 0.1: # lower threshold to capture signals
        detections.append((max_score, max_idx, col, output0[0, :4, col]))

# Sort by score descending
detections.sort(key=lambda x: x[0], reverse=True)

# Print top 15 detections
for i, det in enumerate(detections[:15]):
    score, class_idx, col_idx, box = det
    print(f"Rank {i}: Score={score:.4f}, ClassIndex={class_idx} (AttrIndex={4+class_idx}), Col={col_idx}, Box={box}")
