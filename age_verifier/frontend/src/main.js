
import { UltraHonkBackend } from "@aztec/bb.js";
import { Noir } from "@noir-lang/noir_js";
import circuit from "../../target/age_verifier.json" with { type: "json" };

import { Buffer } from "buffer";
window.Buffer = Buffer;

const noir = new Noir(circuit);
const backend = new UltraHonkBackend(circuit.bytecode);

document.addEventListener("DOMContentLoaded", () => {
  const form = document.getElementById("ageForm");

  form.addEventListener("submit", async (e) => {
    e.preventDefault();

    const yob = parseInt(document.getElementById("year_of_birth").value, 10);
    const cy = parseInt(document.getElementById("current_year").value, 10);

    console.log("Form submitted:", { yob, cy });

    try {
      const { witness } = await noir.execute({
        year_of_birth: yob,
        current_year: cy,
      });

      const proof = await backend.generateProof(witness);

      console.log("Generated Proof:", proof);
    } catch (err) {
      console.error("Error generating proof:", err);
    }
  });
});