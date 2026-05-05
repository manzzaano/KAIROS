// kairos-store.jsx — Shared state, reducer & seed data for the prototype

const SEED_TASKS = [
  { id: 't1', title: 'Refactorizar módulo de auth (JWT)', desc: 'Migrar a refresh tokens y revisar expiración', priority: 'high', energy: 5, due: 'Hoy', estimate: 90, done: false, project: 'KAIROS · Backend', isSynced: true },
  { id: 't2', title: 'Revisar PR #142 — Realm sync', desc: '', priority: 'high', energy: 3, due: 'Hoy', estimate: 30, done: false, project: 'Code Review', isSynced: true },
  { id: 't3', title: 'Llamada con tutor TFG', desc: 'Punto de control sprint 03', priority: 'med', energy: 2, due: 'Hoy 16:00', estimate: 30, done: false, project: 'Académico', isSynced: true },
  { id: 't4', title: 'Leer capítulo 4 — Clean Architecture', desc: '', priority: 'low', energy: 4, due: 'Hoy', estimate: 60, done: false, project: 'Lectura', isSynced: false },
  { id: 't5', title: 'Responder emails pendientes', desc: '', priority: 'low', energy: 1, due: 'Hoy', estimate: 15, done: false, project: 'Inbox', isSynced: true },
  { id: 't6', title: 'Diseñar wireframes onboarding', desc: 'Versión inicial low-fi', priority: 'med', energy: 4, due: 'Mañana', estimate: 60, done: false, project: 'KAIROS · UX', isSynced: true },
  { id: 't7', title: 'Sesión de gimnasio', desc: 'Tren superior', priority: 'med', energy: 3, due: 'Mañana 19:00', estimate: 75, done: false, project: 'Salud', isSynced: true },
  { id: 't8', title: 'Comprar frutas y verduras', desc: '', priority: 'low', energy: 1, due: 'Mañana', estimate: 20, done: false, project: 'Personal', isSynced: true },
  { id: 't9', title: 'Test unitarios módulo Tasks', desc: '', priority: 'high', energy: 4, due: 'Hoy', estimate: 45, done: true, project: 'KAIROS · Backend', isSynced: true },
  { id: 't10', title: 'Café con María', desc: '', priority: 'low', energy: 1, due: 'Hoy 11:00', estimate: 45, done: true, project: 'Personal', isSynced: true },
];

const PRIORITY_LABEL = { high: 'Alta', med: 'Media', low: 'Baja' };
const PRIORITY_COLOR = {
  high: { bg: 'rgba(248,113,113,0.12)', fg: '#fca5a5', dot: '#f87171' },
  med:  { bg: 'rgba(251,146,60,0.12)',  fg: '#fdba74', dot: '#fb923c' },
  low:  { bg: 'rgba(115,115,115,0.18)', fg: '#a3a3a3', dot: '#737373' },
};

// Productive metrics (last 7 days, completed tasks per day)
const STATS_WEEK = [
  { d: 'L', tasks: 8, focus: 95 },
  { d: 'M', tasks: 11, focus: 120 },
  { d: 'X', tasks: 6, focus: 75 },
  { d: 'J', tasks: 13, focus: 145 },
  { d: 'V', tasks: 9, focus: 110 },
  { d: 'S', tasks: 4, focus: 50 },
  { d: 'D', tasks: 7, focus: 90 },
];

// Heatmap data (4 weeks x 7 days, intensity 0-4)
const HEATMAP = Array.from({ length: 28 }, (_, i) => {
  const seeds = [2,3,1,4,2,0,1, 3,4,2,4,3,1,2, 1,2,3,3,4,2,1, 2,3,4,4,3,2,3];
  return seeds[i] ?? 0;
});

Object.assign(window, {
  SEED_TASKS, PRIORITY_LABEL, PRIORITY_COLOR, STATS_WEEK, HEATMAP,
});
