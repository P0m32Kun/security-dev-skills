#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');

const METRICS_DIR = '/tmp';

function getMetricsPath(sessionId) {
  return path.join(METRICS_DIR, `p-skills-metrics-${sessionId}.json`);
}

function readMetrics(filePath) {
  try {
    return JSON.parse(fs.readFileSync(filePath, 'utf8'));
  } catch {
    return { toolCalls: 0, recentTools: [], filesModified: [], warnedThresholds: {} };
  }
}

function atomicWrite(filePath, data) {
  const tmp = filePath + '.tmp.' + process.pid;
  try {
    fs.writeFileSync(tmp, JSON.stringify(data, null, 2));
    fs.renameSync(tmp, filePath);
  } catch {
    try { fs.unlinkSync(tmp); } catch {}
  }
}

function main() {
  let input;
  try {
    input = JSON.parse(require('fs').readFileSync('/dev/stdin', 'utf8'));
  } catch {
    return;
  }

  const sessionId = input.session_id || 'unknown';
  const toolName = input.tool_name || '';
  const toolInput = input.tool_input || {};
  const metricsPath = getMetricsPath(sessionId);
  const metrics = readMetrics(metricsPath);

  // Update counts
  metrics.toolCalls = (metrics.toolCalls || 0) + 1;

  // Ring buffer for recent tools (last 5)
  metrics.recentTools = metrics.recentTools || [];
  metrics.recentTools.push(toolName);
  if (metrics.recentTools.length > 5) {
    metrics.recentTools = metrics.recentTools.slice(-5);
  }

  // Track unique modified files
  const editTools = ['Edit', 'Write', 'MultiEdit'];
  if (editTools.includes(toolName)) {
    const filePath = toolInput.file_path || toolInput.path || '';
    if (filePath && !metrics.filesModified.includes(filePath)) {
      metrics.filesModified.push(filePath);
    }
  }

  metrics.warnedThresholds = metrics.warnedThresholds || {};

  const warnings = [];

  // Threshold 1: High tool count
  if (metrics.toolCalls > 50 && !metrics.warnedThresholds.highToolCount) {
    warnings.push(`⚠️ High tool count (${metrics.toolCalls}). Consider /compact.`);
    metrics.warnedThresholds.highToolCount = true;
  }

  // Threshold 2: Same tool 3+ times consecutively
  if (metrics.recentTools.length >= 3) {
    const last3 = metrics.recentTools.slice(-3);
    if (last3[0] === last3[1] && last3[1] === last3[2] && !metrics.warnedThresholds.loopDetected) {
      warnings.push(`⚠️ Possible loop detected.`);
      metrics.warnedThresholds.loopDetected = true;
    }
  }

  // Threshold 3: Large scope
  if (metrics.filesModified.length > 15 && !metrics.warnedThresholds.largeScope) {
    warnings.push(`⚠️ Large scope: ${metrics.filesModified.length} files modified.`);
    metrics.warnedThresholds.largeScope = true;
  }

  // Persist metrics
  atomicWrite(metricsPath, metrics);

  // Output warnings if any
  if (warnings.length > 0) {
    console.log(JSON.stringify({ additionalContext: warnings.join('\n') }));
  }
}

main();
