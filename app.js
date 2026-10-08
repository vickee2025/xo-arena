/**
 * XO Arena — Cloud & DevOps Edition
 * Clean, lightweight, zero-dependency Tic-Tac-Toe engine
 */

const WINNING_COMBOS = [
  [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
  [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
  [0, 4, 8], [2, 4, 6]             // Diagonals
];

let boardState = Array(9).fill('');
let currentPlayer = 'X';
let isGameActive = true;
let scores = {
  X: 0,
  O: 0,
  ties: 0
};

// DOM Elements
const cells = document.querySelectorAll('.cell');
const statusBanner = document.getElementById('status-banner');
const cardX = document.getElementById('card-x');
const cardO = document.getElementById('card-o');
const scoreXEl = document.getElementById('score-x');
const scoreOEl = document.getElementById('score-o');
const scoreTiesEl = document.getElementById('score-ties');
const btnRestart = document.getElementById('btn-restart');
const btnResetScores = document.getElementById('btn-reset-scores');

// Load stored scores if available
function loadSavedScores() {
  try {
    const saved = localStorage.getItem('xo_arena_scores');
    if (saved) {
      scores = JSON.parse(saved);
      updateScoreboardUI();
    }
  } catch (e) {
    console.warn('LocalStorage not available:', e);
  }
}

function saveScores() {
  try {
    localStorage.setItem('xo_arena_scores', JSON.stringify(scores));
  } catch (e) {
    console.warn('LocalStorage write error:', e);
  }
}

function updateScoreboardUI() {
  scoreXEl.textContent = scores.X;
  scoreOEl.textContent = scores.O;
  scoreTiesEl.textContent = scores.ties;
}

function updateTurnDisplay() {
  const symbol = currentPlayer === 'X' ? '✕' : '◯';
  statusBanner.className = 'status-banner';
  statusBanner.innerHTML = `Turn: <span class="highlight-turn" id="turn-indicator">Player ${currentPlayer} (${symbol})</span>`;
  cardX.classList.toggle('active', currentPlayer === 'X');
  cardO.classList.toggle('active', currentPlayer === 'O');
}

function handleCellClick(e) {
  const cell = e.target;
  const index = parseInt(cell.getAttribute('data-cell'), 10);

  if (boardState[index] !== '' || !isGameActive) {
    return;
  }

  // Update board state
  boardState[index] = currentPlayer;
  cell.textContent = currentPlayer === 'X' ? '✕' : '◯';
  cell.classList.add(currentPlayer.toLowerCase());
  cell.disabled = true;

  // Evaluate win or draw
  checkRoundOutcome();
}

function checkRoundOutcome() {
  let roundWon = false;
  let winningLine = [];

  for (let i = 0; i < WINNING_COMBOS.length; i++) {
    const [a, b, c] = WINNING_COMBOS[i];
    if (boardState[a] && boardState[a] === boardState[b] && boardState[a] === boardState[c]) {
      roundWon = true;
      winningLine = [a, b, c];
      break;
    }
  }

  if (roundWon) {
    handleWin(currentPlayer, winningLine);
    return;
  }

  // Check for tie
  if (!boardState.includes('')) {
    handleTie();
    return;
  }

  // Switch player turn
  currentPlayer = currentPlayer === 'X' ? 'O' : 'X';
  updateTurnDisplay();
}

function handleWin(winner, line) {
  isGameActive = false;
  scores[winner]++;
  saveScores();
  updateScoreboardUI();

  // Highlight winning cells
  line.forEach(idx => cells[idx].classList.add('win-cell'));

  statusBanner.className = `status-banner winner-${winner.toLowerCase()}`;
  statusBanner.innerHTML = `🎉 Winner: <span class="highlight-turn">Player ${winner} (${winner === 'X' ? '✕' : '◯'})</span>!`;
}

function handleTie() {
  isGameActive = false;
  scores.ties++;
  saveScores();
  updateScoreboardUI();

  statusBanner.className = 'status-banner draw';
  statusBanner.innerHTML = `⚖️ Round Drawn! <b>Deadlock in Cluster.</b>`;
}

function restartRound() {
  boardState = Array(9).fill('');
  isGameActive = true;
  currentPlayer = 'X';

  cells.forEach(cell => {
    cell.textContent = '';
    cell.disabled = false;
    cell.className = 'cell';
  });

  updateTurnDisplay();
}

function resetAllScores() {
  scores = { X: 0, O: 0, ties: 0 };
  saveScores();
  updateScoreboardUI();
  restartRound();
}

// Event Listeners
cells.forEach(cell => cell.addEventListener('click', handleCellClick));
btnRestart.addEventListener('click', restartRound);
btnResetScores.addEventListener('click', resetAllScores);

// Initialize
loadSavedScores();
updateTurnDisplay();
