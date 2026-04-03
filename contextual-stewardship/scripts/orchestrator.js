#!/usr/bin/env node

const fs = require('fs');
const os = require('os');
const path = require('path');

const content = process.argv[2];

if (!content) {
  console.error("Error: Missing memory content.");
  console.error("Usage: node orchestrator.js '<toon_content>'");
  process.exit(1);
}

// Tier 2: Fallback for Cold Storage Local (TOON)
try {
  const agentDir = path.join(os.homedir(), '.agents');
  
  // Create directory if it doesn't exist
  if (!fs.existsSync(agentDir)) {
    fs.mkdirSync(agentDir, { recursive: true });
  }
  
  const toonPath = path.join(agentDir, 'stewardship.toon');
  
  // Append content to the TOON file
  fs.appendFileSync(toonPath, `\n${content}\n`);
  
  console.log(`SUCCESS: Contexto salvo em: ${toonPath}`);
  process.exit(0);
} catch (e) {
  console.error("ERROR: Falha de I/O. Não foi possível salvar o contexto.");
  console.error(e.message);
  process.exit(1);
}
