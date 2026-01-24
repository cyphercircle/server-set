# backend/neural/onnx_runner.py
import onnxruntime as ort
import numpy as np

def run_onnx(model_path, input_data):
    sess = ort.InferenceSession(model_path)
    input_name = sess.get_inputs()[0].name
    return sess.run(None, {input_name: input_data})