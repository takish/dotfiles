#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const os = require('os');
const readline = require('readline');
const { exec } = require('child_process');
const util = require('util');

const execPromise = util.promisify(exec);

// ============================================================================
// Constants
// ============================================================================

/** Compaction threshold in tokens (200K * 0.8) */
const COMPACTION_THRESHOLD = 200000 * 0.8;

/** Percentage thresholds for color coding */
const THRESHOLDS = {
  low: 70,    // Below 70%: Green
  high: 90    // Above 90%: Red, between: Yellow
};

/** ANSI color codes */
const COLOR_CODES = {
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  red: '\x1b[31m',
  reset: '\x1b[0m'
};

/** Cache for file modification times and calculated values */
const cache = {
  transcriptFile: null,
  lastModTime: null,
  lastTokens: 0,
  dailyCost: null,
  dailyCostTimestamp: null
};

/** Cache duration for daily cost (1 second) */
const DAILY_COST_CACHE_DURATION = 1000;

// ============================================================================
// Main Entry Point
// ============================================================================

/**
 * Main function that reads stdin and generates status line output
 */
async function main() {
  try {
    // Read JSON from stdin
    const data = await readStdin();

    // Extract values
    const model = data.model?.display_name || 'Unknown';
    const currentDir = path.basename(data.workspace?.current_dir || data.cwd || '.');
    const sessionId = data.session_id;

    // Calculate token usage for current session
    const totalTokens = await getSessionTokens(sessionId);

    // Get daily cost (with caching)
    const dailyCost = await getDailyCost();

    // Calculate percentage
    const percentage = Math.min(100, Math.round((totalTokens / COMPACTION_THRESHOLD) * 100));

    // Get username and hostname for PS1-style prompt
    const username = os.userInfo().username;
    const hostname = os.hostname().split('.')[0]; // Short hostname

    // Format displays
    const tokenDisplay = formatTokenCount(totalTokens);
    const percentageColor = getColorCode(percentage);
    const costDisplay = dailyCost !== null ? ` | 📅 $${dailyCost.toFixed(2)}` : '';

    // Build status line with PS1-style prompt
    const ps1Prompt = `${COLOR_CODES.green}[${username}@${hostname}]${COLOR_CODES.reset}`;
    const statusLine = `${ps1Prompt} [${model}] 📁 ${currentDir} | 🪙 ${tokenDisplay}${costDisplay} | ${percentageColor}${percentage}%${COLOR_CODES.reset}`;

    console.log(statusLine);
  } catch (error) {
    // Fallback status line on error with PS1-style prompt
    const username = os.userInfo().username;
    const hostname = os.hostname().split('.')[0];
    const ps1Prompt = `${COLOR_CODES.green}[${username}@${hostname}]${COLOR_CODES.reset}`;
    console.log(`${ps1Prompt} [Error] 📁 . | 🪙 0 | 0%`);
  }
}

// ============================================================================
// Input/Output Functions
// ============================================================================

/**
 * Reads JSON data from stdin
 * @returns {Promise<Object>} Parsed JSON object from stdin
 */
function readStdin() {
  return new Promise((resolve, reject) => {
    let input = '';
    process.stdin.on('data', chunk => input += chunk);
    process.stdin.on('end', () => {
      try {
        resolve(JSON.parse(input));
      } catch (error) {
        reject(error);
      }
    });
    process.stdin.on('error', reject);
  });
}

// ============================================================================
// Token Calculation Functions
// ============================================================================

/**
 * Gets total token count for the current session
 * @param {string} sessionId - The session ID to look up
 * @returns {Promise<number>} Total token count
 */
async function getSessionTokens(sessionId) {
  if (!sessionId) {
    return 0;
  }

  const transcriptFile = findTranscriptFile(sessionId);
  if (!transcriptFile) {
    return 0;
  }

  // Check cache
  const stats = fs.statSync(transcriptFile);
  if (cache.transcriptFile === transcriptFile && cache.lastModTime === stats.mtimeMs) {
    return cache.lastTokens;
  }

  // Calculate tokens and update cache
  const tokens = await calculateTokensFromTranscript(transcriptFile);
  cache.transcriptFile = transcriptFile;
  cache.lastModTime = stats.mtimeMs;
  cache.lastTokens = tokens;

  return tokens;
}

/**
 * Finds the transcript file for a given session ID
 * @param {string} sessionId - The session ID to search for
 * @returns {string|null} Path to transcript file or null if not found
 */
function findTranscriptFile(sessionId) {
  const projectsDir = path.join(process.env.HOME, '.claude', 'projects');

  if (!fs.existsSync(projectsDir)) {
    return null;
  }

  // Get all project directories
  const projectDirs = fs.readdirSync(projectsDir)
    .map(dir => path.join(projectsDir, dir))
    .filter(dir => fs.statSync(dir).isDirectory());

  // Search for the current session's transcript file
  for (const projectDir of projectDirs) {
    const transcriptFile = path.join(projectDir, `${sessionId}.jsonl`);
    if (fs.existsSync(transcriptFile)) {
      return transcriptFile;
    }
  }

  return null;
}

/**
 * Calculates total token usage from a JSONL transcript file
 * @param {string} filePath - Path to the JSONL transcript file
 * @returns {Promise<number>} Total token count from last usage entry
 */
async function calculateTokensFromTranscript(filePath) {
  return new Promise((resolve, reject) => {
    let lastUsage = null;

    const fileStream = fs.createReadStream(filePath);
    const rl = readline.createInterface({
      input: fileStream,
      crlfDelay: Infinity
    });

    rl.on('line', (line) => {
      try {
        const entry = JSON.parse(line);

        // Check if this is an assistant message with usage data
        if (entry.type === 'assistant' && entry.message?.usage) {
          lastUsage = entry.message.usage;
        }
      } catch (e) {
        // Skip invalid JSON lines
      }
    });

    rl.on('close', () => {
      if (lastUsage) {
        // The last usage entry contains cumulative tokens
        const totalTokens = (lastUsage.input_tokens || 0) +
          (lastUsage.output_tokens || 0) +
          (lastUsage.cache_creation_input_tokens || 0) +
          (lastUsage.cache_read_input_tokens || 0);
        resolve(totalTokens);
      } else {
        resolve(0);
      }
    });

    rl.on('error', (err) => {
      reject(err);
    });
  });
}

// ============================================================================
// Cost Calculation Functions
// ============================================================================

/**
 * Gets today's total cost across all sessions using ccusage
 * @returns {Promise<number|null>} Daily cost in USD, or null if unavailable
 */
async function getDailyCost() {
  // Check cache (1 second duration)
  const now = Date.now();
  if (cache.dailyCostTimestamp && (now - cache.dailyCostTimestamp) < DAILY_COST_CACHE_DURATION) {
    return cache.dailyCost;
  }

  try {
    const today = new Date().toISOString().slice(0, 10).replace(/-/g, '');
    const { stdout } = await execPromise(
      `npx --yes ccusage@latest daily --since ${today} --json --offline`,
      { timeout: 5000 } // 5 second timeout
    );

    const data = JSON.parse(stdout);
    const cost = data.totals?.totalCost || 0;

    // Update cache
    cache.dailyCost = cost;
    cache.dailyCostTimestamp = now;

    return cost;
  } catch (error) {
    // Graceful fallback - return null if ccusage fails
    // Don't update cache on error so we can retry next time
    return null;
  }
}

// ============================================================================
// Formatting Functions
// ============================================================================

/**
 * Formats token count with K/M suffixes
 * @param {number} tokens - Raw token count
 * @returns {string} Formatted token count (e.g., "45.2K", "1.2M")
 */
function formatTokenCount(tokens) {
  if (tokens >= 1000000) {
    return `${(tokens / 1000000).toFixed(1)}M`;
  } else if (tokens >= 1000) {
    return `${(tokens / 1000).toFixed(1)}K`;
  }
  return tokens.toString();
}

/**
 * Determines color code based on percentage thresholds
 * @param {number} percentage - Usage percentage (0-100)
 * @returns {string} ANSI color code
 */
function getColorCode(percentage) {
  if (percentage >= THRESHOLDS.high) {
    return COLOR_CODES.red;
  } else if (percentage >= THRESHOLDS.low) {
    return COLOR_CODES.yellow;
  }
  return COLOR_CODES.green;
}

// ============================================================================
// Execute Main
// ============================================================================

main();
