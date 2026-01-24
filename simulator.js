// backend/quantum/simulator.js
export function simulate(circuit){
  const size = 2 ** circuit.qubits;
  let state = Array(size).fill(0);
  state[0] = 1; // |000>

  // (stub – extend with matrix ops)
  return state;
}