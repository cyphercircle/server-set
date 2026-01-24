import React, { useState, useEffect } from "react";
import Editor from "@monaco-editor/react";
import axios from "axios";

const CodeEditor = ({ userId, language, artifactId }) => {
  const [code, setCode] = useState("");

  // Load existing code if editing an artifact
  useEffect(() => {
    if (artifactId) {
      axios
        .get(`http://localhost:8000/devbox/artifact/${artifactId}`)
        .then((res) => setCode(res.data.content))
        .catch((err) => console.error(err));
    }
  }, [artifactId]);

  const saveArtifact = async () => {
    try {
      await axios.post("http://localhost:8000/devbox/create", {
        user: userId,
        language: language,
        type: "file",
        name: artifactId ? `Artifact-${artifactId}` : "NewArtifact",
        content: code,
      });
      alert("Saved to DevBox!");
    } catch (err) {
      console.error(err);
      alert("Save failed.");
    }
  };

  const runArtifact = async () => {
    try {
      const res = await axios.post("http://localhost:8000/devbox/run", {
        language,
        content: code,
      });
      alert(`Output:\n${res.data.output}`);
    } catch (err) {
      console.error(err);
      alert("Execution failed.");
    }
  };

  return (
    <div style={{ height: "80vh", display: "flex", flexDirection: "column" }}>
      <Editor
        height="70%"
        defaultLanguage={language}
        value={code}
        onChange={(value) => setCode(value)}
        theme="vs-dark"
      />
      <div style={{ marginTop: "10px" }}>
        <button onClick={saveArtifact}>💾 Save</button>
        <button onClick={runArtifact} style={{ marginLeft: "10px" }}>
          ▶ Run
        </button>
      </div>
    </div>
  );
};

export default CodeEditor;