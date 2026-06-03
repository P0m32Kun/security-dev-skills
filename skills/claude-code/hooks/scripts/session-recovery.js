#!/usr/bin/env node
// Session Recovery — SessionStart hook
// Loads the most recent session summary for the current project.
// Outputs additionalContext to inject into the session.

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

try {
  const sessionsDir = path.join(
    process.env.HOME || '~',
    '.p-skills',
    'sessions'
  );

  if (!fs.existsSync(sessionsDir)) process.exit(0);

  // Determine current project name
  const projectDir = process.cwd();
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

  // Scan session files and parse frontmatter
  const files = fs.readdirSync(sessionsDir)
    .filter((f) => f.endsWith('.md'))
    .sort()
    .reverse(); // Most recent first (YYYY-MM-DD prefix sorts correctly)

  for (const file of files) {
    const filePath = path.join(sessionsDir, file);
    try {
      const content = fs.readFileSync(filePath, 'utf8');

      // Parse YAML frontmatter
      const fmMatch = content.match(/^---\n([\s\S]*?)\n---/);
      if (!fmMatch) continue;

      const fm = fmMatch[1];
      const projectMatch = fm.match(/project:\s*"([^"]+)"/);
      if (!projectMatch) continue;

      if (projectMatch[1] === project) {
        // Found matching project — output the content
        const result = {
          additionalContext: `📋 Previous session:\n${content}`,
        };
        process.stdout.write(JSON.stringify(result));
        process.exit(0);
      }
    } catch {
      continue;
    }
  }

  // No matching session found — output nothing
  process.exit(0);
} catch {
  // Silently catch all errors
  process.exit(0);
}
