#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');

const LEARNING_DIR = path.join(process.env.HOME, '.p-skills', 'learning');
const OBSERVATIONS_FILE = path.join(LEARNING_DIR, 'meta-observations.jsonl');
const META_REPORT = path.join(LEARNING_DIR, 'meta.md');
const ANALYSIS_THRESHOLD = 10;

// Skill file patterns to match
const SKILL_PATTERNS = [
  /skills\/[^/]+\/SKILL\.md$/,
  /skills\/[^/]+\//,
];

function ensureDir(dir) {
  try {
    fs.mkdirSync(dir, { recursive: true });
  } catch {}
}

function isSkillFile(filePath) {
  if (!filePath) return false;
  return SKILL_PATTERNS.some(p => p.test(filePath));
}

function extractSection(content) {
  if (!content) return 'unknown';
  // Try to find the nearest heading
  const match = content.match(/^#+\s+(.+)/m);
  return match ? match[1].trim() : 'body';
}

function appendObservation(obs) {
  ensureDir(LEARNING_DIR);
  try {
    fs.appendFileSync(OBSERVATIONS_FILE, JSON.stringify(obs) + '\n');
  } catch {}
}

function readObservations() {
  try {
    const data = fs.readFileSync(OBSERVATIONS_FILE, 'utf8');
    return data.trim().split('\n').filter(Boolean).map(line => {
      try { return JSON.parse(line); } catch { return null; }
    }).filter(Boolean);
  } catch {
    return [];
  }
}

function runMetaAnalysis(observations) {
  // Group by edit_type
  const byType = {};
  // Group by file
  const byFile = {};

  for (const obs of observations) {
    const t = obs.edit_type || 'unknown';
    byType[t] = (byType[t] || 0) + 1;

    const f = obs.file || 'unknown';
    byFile[f] = (byFile[f] || 0) + 1;
  }

  const lines = [
    '# Meta Skill Edit Analysis',
    '',
    `> Auto-generated at ${new Date().toISOString()}`,
    `> Total observations: ${observations.length}`,
    '',
    '## By Edit Type',
    '',
    '| Edit Type | Count |',
    '|-----------|-------|',
  ];

  for (const [type, count] of Object.entries(byType).sort((a, b) => b[1] - a[1])) {
    lines.push(`| ${type} | ${count} |`);
  }

  lines.push('');
  lines.push('## By File');
  lines.push('');
  lines.push('| File | Count |');
  lines.push('|------|-------|');

  for (const [file, count] of Object.entries(byFile).sort((a, b) => b[1] - a[1])) {
    lines.push(`| ${file} | ${count} |`);
  }

  lines.push('');
  lines.push('## Insights');
  lines.push('');

  const topType = Object.entries(byType).sort((a, b) => b[1] - a[1])[0];
  const topFile = Object.entries(byFile).sort((a, b) => b[1] - a[1])[0];

  if (topType) {
    lines.push(`- Most common edit type: **${topType[0]}** (${topType[1]} times)`);
  }
  if (topFile) {
    lines.push(`- Most edited file: **${topFile[0]}** (${topFile[1]} times)`);
  }

  if (observations.length >= 20) {
    const recentHalf = observations.slice(Math.floor(observations.length / 2));
    const recentByType = {};
    for (const obs of recentHalf) {
      const t = obs.edit_type || 'unknown';
      recentByType[t] = (recentByType[t] || 0) + 1;
    }
    const recentTop = Object.entries(recentByType).sort((a, b) => b[1] - a[1])[0];
    if (recentTop) {
      lines.push(`- Recent trend: **${recentTop[0]}** edits increasing`);
    }
  }

  try {
    fs.writeFileSync(META_REPORT, lines.join('\n') + '\n');
  } catch {}
}

function handleAnalyzeFlag() {
  const observations = readObservations();
  if (observations.length === 0) {
    console.log('No observations recorded yet.');
    return;
  }
  runMetaAnalysis(observations);
  console.log(`Analysis written to ${META_REPORT} (${observations.length} observations)`);
}

function main() {
  // Support --analyze flag for manual trigger
  if (process.argv.includes('--analyze')) {
    handleAnalyzeFlag();
    return;
  }

  let input;
  try {
    input = JSON.parse(fs.readFileSync('/dev/stdin', 'utf8'));
  } catch {
    return;
  }

  const toolName = input.tool_name || '';
  if (!['Edit', 'Write', 'MultiEdit'].includes(toolName)) return;

  const toolInput = input.tool_input || {};
  const filePath = toolInput.file_path || toolInput.path || '';

  if (!isSkillFile(filePath)) return;

  // Extract section hint from old_string or content
  let section = 'unknown';
  if (toolName === 'Edit' && toolInput.old_string) {
    section = extractSection(toolInput.old_string);
  } else if (toolInput.content) {
    section = extractSection(toolInput.content);
  }

  const observation = {
    timestamp: new Date().toISOString(),
    file: filePath,
    edit_type: toolName,
    section,
    session_id: input.session_id || 'unknown',
  };

  appendObservation(observation);

  // Check if we hit the analysis threshold
  const observations = readObservations();
  if (observations.length > 0 && observations.length % ANALYSIS_THRESHOLD === 0) {
    runMetaAnalysis(observations);
  }
}

main();
