#!/usr/bin/env node
// Session Learning — SessionStart hook
// Loads high-confidence instincts for current project.
// Outputs additionalContext with learned patterns.

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const crypto = require('crypto');

try {
  // Determine project ID
  const projectDir = process.cwd();
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

  // Look for instincts
  const instinctsDir = path.join(
    process.env.HOME || '~',
    '.p-skills',
    'learning',
    'projects',
    projectId,
    'instincts'
  );

  if (!fs.existsSync(instinctsDir)) process.exit(0);

  // Read all instinct files
  const files = fs.readdirSync(instinctsDir).filter((f) => f.endsWith('.md'));
  const instincts = [];

  for (const file of files) {
    try {
      const content = fs.readFileSync(
        path.join(instinctsDir, file),
        'utf8'
      );
      const fmMatch = content.match(/^---\n([\s\S]*?)\n---/);
      if (!fmMatch) continue;

      const fm = fmMatch[1];
      const confidenceMatch = fm.match(/confidence:\s*([\d.]+)/);
      const triggerMatch = fm.match(/trigger:\s*"([^"]+)"/);

      if (confidenceMatch && triggerMatch) {
        const confidence = parseFloat(confidenceMatch[1]);
        if (confidence >= 0.5) {
          instincts.push({
            confidence,
            trigger: triggerMatch[1],
            content: content.split('---').slice(2).join('---').trim(),
          });
        }
      }
    } catch {
      continue;
    }
  }

  if (instincts.length === 0) process.exit(0);

  // Sort by confidence descending, take top 5
  instincts.sort((a, b) => b.confidence - a.confidence);
  const topInstincts = instincts.slice(0, 5);

  // Format as markdown
  const lines = topInstincts.map(
    (inst) =>
      `- [${inst.confidence.toFixed(1)}] ${inst.trigger}`
  );

  const result = {
    additionalContext: `🧠 Learned patterns:\n${lines.join('\n')}`,
  };

  process.stdout.write(JSON.stringify(result));
} catch {
  // Silently catch all errors
  process.exit(0);
}
