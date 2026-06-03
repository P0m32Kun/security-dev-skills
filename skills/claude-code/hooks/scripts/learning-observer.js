#!/usr/bin/env node
// Learning Observer — PostToolUse hook
// Observes Edit/Write/Bash tool usage and records to JSONL.
// Every 20 observations, triggers learning-evolve.js.

const fs = require('fs');
const path = require('path');
const { execSync, fork } = require('child_process');
const crypto = require('crypto');

const OBSERVED_TOOLS = new Set(['Edit', 'Write', 'Bash']);
const SKIP_TOOLS = new Set(['Read', 'Grep', 'Agent', 'LS', 'Glob']);

try {
  // Check if learning is disabled
  if (process.env.P_SKILLS_LEARNING === 'off') process.exit(0);

  const input = JSON.parse(fs.readFileSync('/dev/stdin', 'utf8'));
  const toolName = input.tool_name || input.name || '';

  // Only observe specific tools
  if (!OBSERVED_TOOLS.has(toolName)) process.exit(0);

  const sessionId = input.session_id || 'unknown';
  const projectDir = input.cwd || process.cwd();

  // Determine project ID
  let projectId;
  try {
    const remoteUrl = execSync('git remote get-url origin', {
      cwd: projectDir,
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
    projectId = crypto
      .createHash('md5')
      .update(path.basename(projectDir))
      .digest('hex')
      .substring(0, 12);
  }

  // Extract file path from tool input
  const toolInput = input.input || {};
  const filePath =
    toolInput.file_path || toolInput.path || toolInput.filePath || '';

  // Get file extension
  const fileExt = filePath ? path.extname(filePath) : '';

  // Build observation record
  const observation = {
    timestamp: new Date().toISOString(),
    session_id: sessionId,
    tool: toolName,
    file_path: filePath,
    file_ext: fileExt,
    project: projectId,
  };

  // Write to observations JSONL
  const projectDir2 = path.join(
    process.env.HOME || '~',
    '.p-skills',
    'learning',
    'projects',
    projectId
  );
  fs.mkdirSync(projectDir2, { recursive: true });

  const observationsFile = path.join(projectDir2, 'observations.jsonl');
  fs.appendFileSync(
    observationsFile,
    JSON.stringify(observation) + '\n',
    'utf8'
  );

  // Count observations and trigger evolve every 20
  const lineCount = fs
    .readFileSync(observationsFile, 'utf8')
    .split('\n')
    .filter(Boolean).length;

  if (lineCount % 20 === 0) {
    const evolveScript = path.join(__dirname, 'learning-evolve.js');
    try {
      // Run evolve script in background
      const child = fork(evolveScript, ['--project', projectId], {
        detached: true,
        stdio: 'ignore',
      });
      child.unref();
    } catch {
      // Silently fail
    }
  }
} catch {
  // Silently catch all errors
}
