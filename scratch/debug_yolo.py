import tflite

with open('/tmp/yolo.tflite', 'rb') as f:
    buf = f.read()

model = tflite.Model.GetRootAsModel(buf, 0)

print(f"Metadata length: {model.MetadataLength()}")
for i in range(model.MetadataLength()):
    meta = model.Metadata(i)
    name = meta.Name().decode('utf-8')
    buffer_idx = meta.Buffer()
    print(f"Metadata {i}: Name='{name}', BufferIdx={buffer_idx}")
    
    # Read buffer content
    buffer = model.Buffers(buffer_idx)
    data = buffer.DataAsNumpy()
    if data is not None:
        try:
            raw_bytes = bytes(data)
            print(f"  Raw size: {len(raw_bytes)}")
            # Write metadata file for inspection if it is zip/json
            with open(f"/tmp/metadata_{name}.bin", "wb") as f_meta:
                f_meta.write(raw_bytes)
            
            text = raw_bytes.decode('utf-8', errors='ignore')
            print("  Content snippet:")
            print(text[:500])
        except Exception as e:
            print(f"  Could not decode: {e}")
