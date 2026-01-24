# devbox/python/neural_job.py
import numpy as np

def train():
    W = np.random.rand(64,128)
    return W.sum()

print("NN result:", train())