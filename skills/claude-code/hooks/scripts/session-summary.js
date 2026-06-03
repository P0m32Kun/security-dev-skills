#!/usr/bin/env node
// Session Summary — Stop hook
// Persists a session summary when a Claude Code session ends.
// Reads transcript JSONL, extracts key info, saves to ~/.p-skills/sessions/

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const crypto = require('crypto');

try {
  const input = JSON.parse(fs.readFileSync('/dev/stdin', 'utf8'));
  const transcriptPath = input.transcript_path;
  if (!transcriptPath || !fs.existsSync(transcriptPath)) process.exit(0);

  const sessionId = input.session_id || 'unknown';
  const projectDir = input.cwd || process.cwd();

  // Determine project name
  let project;
  try {
    const remoteUrl = execSync('git remote get-url origin', {
      cwd: projectDir,
      encoding: 'utf8',
      timeout: 5000,
      stdio: ['pipe', 'pipe', 'pipe'],
    }).trim();
    project = remoteUrl.replace(/\.git$/, '').split('/').pop();
  } catch {
    project = path.basename(projectDir);
  }

  // Get current branch
  let branch = 'unknown';
  try {
    branch = execSync('git branch --show-current', {
      cwd: projectDir,
      encoding: 'utf8',
      timeout: 5000,
      stdio: ['pipe', 'pipe', 'pipe'],
    }).trim();
  } catch {}

  // Parse transcript JSONL
  const lines = fs.readFileSync(transcriptPath, 'utf8').split('\n').filter(Boolean);
  const userMessages = [];
  const toolsUsed = new Set();
  const filesModified = new Set();

  for (const line of lines) {
    let entry;
    try {
      entry = JSON.parse(line);
    } catch {
      continue;
    }

    // Extract user messages
    if (entry.type === 'human' || entry.role === 'user') {
      const text = typeof entry.message === 'string'
        ? entry.message
        : entry.content || '';
      const extracted = typeof text === 'string' ? text : '';
      if (extracted.trim()) {
        userMessages.push(extracted.substring(0, 200));
      }
    }

    // Extract tool usage
    if (entry.type === 'tool_use' || entry.tool) {
      const toolName = entry.name || entry.tool;
      if (toolName) toolsUsed.add(toolName);
    }

    // Extract modified files from tool results
    if (entry.type === 'tool_result' || entry.tool_result) {
      const input = entry.input || {};
      const filePath = input.file_path || input.path || input.filePath;
      if (filePath) filesModified.add(filePath);
    }

    // Also check tool_use entries for file paths
    if ((entry.type === 'tool_use' || entry.tool) && entry.input) {
      const filePath = entry.input.file_path || entry.input.path || entry.input.filePath;
      if (filePath) filesModified.add(filePath);
    }
  }

  // Take last 10 user messages
  const recentMessages = userMessages.slice(-10);
  const toolsArr = [...toolsUsed].slice(0, 20);
  const filesArr = [...filesModified].slice(0, 30);

  // Build summary
  const date = new Date().toISOString().split('T')[0];
  const sessionIdShort = sessionId.substring(0, 8);

  const frontmatter = [
    '---',
    `session_id: "${sessionId}"`,
    `date: "${date}"`,
    `project: "${project}"`,
    `branch: "${branch}"`,
    `tools_used: ${JSON.stringify(toolsArr)}`,
    `files_modified: ${JSON.stringify(filesArr)}`,
    '---',
  ].join('\n');

  const messageSection = recentMessages.length > 0
    ? '## Recent Messages\n\n' + recentMessages.map((m, i) => `${i + 1}. ${m}`).join('\n')
    : '';

  const content = `${frontmatter}\n\n# Session Summary\n\n**Project:** ${project}  \n**Branch:** ${branch}  \n**Date:** ${date}\n\n${messageSection}\n`;

  // Save to ~/.p-skills/sessions/
  const sessionsDir = path.join(
    process.env.HOME || '~',
    '.p-skills',
    'sessions'
  );
  fs.mkdirSync(sessionsDir, { recursive: true });

  const filename = `${date}-${sessionIdShort}.md`;
  fs.writeFileSync(path.join(sessionsDir, filename), content, 'utf8');
} catch {
  // Silently catch all errors
}
