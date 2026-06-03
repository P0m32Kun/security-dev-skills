#!/usr/bin/env node
// Learning Evolve — standalone script (not a hook)
// Reads observations JSONL, groups by patterns, generates instinct files.
// Usage: node learning-evolve.js --project <id>

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

try {
  // Parse --project argument
  const args = process.argv.slice(2);
  let projectId = null;
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--project' && args[i + 1]) {
      projectId = args[i + 1];
      break;
    }
  }

  if (!projectId) {
    // Try to determine from current directory
    try {
      const { execSync } = require('child_process');
      const remoteUrl = execSync('git remote get-url origin', {
        encoding: 'utf8',
        timeout: 5000,
        stdio: ['pipe', 'pipe', 'pipe'],
      }).trim();
      projectId = crypto
        .createHash('md5')
        .update(remoteUrl.replace(/\.git$/, ''))
        .digest('hex')
        .substring(0, 12);
    } catch {
      process.exit(0);
    }
  }

  const projectDir = path.join(
    process.env.HOME || '~',
    '.p-skills',
    'learning',
    'projects',
    projectId
  );
  const observationsFile = path.join(projectDir, 'observations.jsonl');

  if (!fs.existsSync(observationsFile)) process.exit(0);

  // Read and parse observations
  const lines = fs
    .readFileSync(observationsFile, 'utf8')
    .split('\n')
    .filter(Boolean);
  const observations = [];
  for (const line of lines) {
    try {
      observations.push(JSON.parse(line));
    } catch {
      continue;
    }
  }

  if (observations.length === 0) process.exit(0);

  // Analyze patterns
  const fileExtFreq = {};
  const fileCoOccurrence = {};
  const dirActivity = {};
  const toolUsage = {};
  const sessionFiles = {};

  for (const obs of observations) {
    // File type frequency
    if (obs.file_ext) {
      fileExtFreq[obs.file_ext] = (fileExtFreq[obs.file_ext] || 0) + 1;
    }

    // Directory activity
    if (obs.file_path) {
      const dir = path.dirname(obs.file_path);
      dirActivity[dir] = (dirActivity[dir] || 0) + 1;
    }

    // Tool usage
    if (obs.tool) {
      toolUsage[obs.tool] = (toolUsage[obs.tool] || 0) + 1;
    }

    // Track files per session for co-occurrence
    if (obs.session_id && obs.file_path) {
      if (!sessionFiles[obs.session_id]) {
        sessionFiles[obs.session_id] = new Set();
      }
      sessionFiles[obs.session_id].add(obs.file_path);
    }
  }

  // Compute file co-occurrence across sessions
  for (const files of Object.values(sessionFiles)) {
    const fileArr = [...files];
    for (let i = 0; i < fileArr.length; i++) {
      for (let j = i + 1; j < fileArr.length; j++) {
        const key = [fileArr[i], fileArr[j]].sort().join(' <-> ');
        fileCoOccurrence[key] = (fileCoOccurrence[key] || 0) + 1;
      }
    }
  }

  // Create instincts directory
  const instinctsDir = path.join(projectDir, 'instincts');
  fs.mkdirSync(instinctsDir, { recursive: true });

  // Generate instinct files
  const now = new Date().toISOString();

  // File type frequency instincts
  for (const [ext, count] of Object.entries(fileExtFreq)) {
    if (count < 2) continue;
    const confidence = Math.min(0.3 + (count - 1) * 0.1, 0.9);
    const id = `filetype-${ext.replace('.', '')}`;
    const content = [
      '---',
      `id: "${id}"`,
      `trigger: "Working with ${ext} files"`,
      `confidence: ${confidence.toFixed(1)}`,
      `domain: "file-type"`,
      `scope: "project"`,
      `observations: ${count}`,
      `last_updated: "${now}"`,
      '---',
      '',
      `# File Type: ${ext}`,
      '',
      `This project frequently works with ${ext} files (${count} observations).`,
      `Consider optimizing workflows for ${ext} file handling.`,
    ].join('\n');

    fs.writeFileSync(path.join(instinctsDir, `${id}.md`), content, 'utf8');
  }

  // Directory activity instincts
  for (const [dir, count] of Object.entries(dirActivity)) {
    if (count < 3) continue;
    const confidence = Math.min(0.3 + (count - 1) * 0.1, 0.9);
    const dirBasename = path.basename(dir) || dir;
    const id = `dir-${dirBasename.replace(/[^a-zA-Z0-9]/g, '-')}`;
    const content = [
      '---',
      `id: "${id}"`,
      `trigger: "Files in ${dir} directory"`,
      `confidence: ${confidence.toFixed(1)}`,
      `domain: "directory-activity"`,
      `scope: "project"`,
      `observations: ${count}`,
      `last_updated: "${now}"`,
      '---',
      '',
      `# Active Directory: ${dir}`,
      '',
      `This directory is frequently modified (${count} observations).`,
      `Changes to this area may have broad impact.`,
    ].join('\n');

    fs.writeFileSync(path.join(instinctsDir, `${id}.md`), content, 'utf8');
  }

  // File co-occurrence instincts
  for (const [pair, count] of Object.entries(fileCoOccurrence)) {
    if (count < 2) continue;
    const confidence = Math.min(0.3 + (count - 1) * 0.1, 0.9);
    const hash = crypto
      .createHash('md5')
      .update(pair)
      .digest('hex')
      .substring(0, 8);
    const id = `cooccur-${hash}`;
    const content = [
      '---',
      `id: "${id}"`,
      `trigger: "Modifying files that often change together"`,
      `confidence: ${confidence.toFixed(1)}`,
      `domain: "file-co-occurrence"`,
      `scope: "project"`,
      `observations: ${count}`,
      `last_updated: "${now}"`,
      '---',
      '',
      `# Co-occurring Files`,
      '',
      `These files are frequently modified together (${count} observations):`,
      `- ${pair}`,
      '',
      'Consider making related changes to both files.',
    ].join('\n');

    fs.writeFileSync(path.join(instinctsDir, `${id}.md`), content, 'utf8');
  }

  // Tool usage instincts
  const totalToolUse = Object.values(toolUsage).reduce((a, b) => a + b, 0);
  for (const [tool, count] of Object.entries(toolUsage)) {
    if (count < 3) continue;
    const ratio = count / totalToolUse;
    const confidence = Math.min(0.3 + (count - 1) * 0.1, 0.9);
    const id = `tool-${tool.toLowerCase()}`;
    const content = [
      '---',
      `id: "${id}"`,
      `trigger: "Using ${tool} tool"`,
      `confidence: ${confidence.toFixed(1)}`,
      `domain: "tool-usage"`,
      `scope: "project"`,
      `observations: ${count}`,
      `last_updated: "${now}"`,
      '---',
      '',
      `# Tool Pattern: ${tool}`,
      '',
      `${tool} is used frequently (${count} observations, ${(ratio * 100).toFixed(0)}% of tool usage).`,
    ].join('\n');

    fs.writeFileSync(path.join(instinctsDir, `${id}.md`), content, 'utf8');
  }
} catch {
  // Silently catch all errors
}
