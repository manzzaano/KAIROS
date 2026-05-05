// kairos-screens-extras.jsx — Optimize, Focus, Stats, Profile, Sync states

const Optimize = ({ onDone, onCancel }) => {
  const [phase, setPhase] = React.useState('serializing');
  React.useEffect(() => {
    const seq = [
      ['serializing', 800],
      ['sending', 900],
      ['processing', 1400],
      ['receiving', 700],
      ['done', 700],
    ];
    let i = 0;
    const tick = () => {
      if (i >= seq.length) { onDone(); return; }
      setPhase(seq[i][0]);
      setTimeout(() => { i++; tick(); }, seq[i][1]);
    };
    tick();
  }, []);

  const steps = [
    { k: 'serializing', label: 'Serializando tareas locales', sub: 'Realm → JSON' },
    { k: 'sending', label: 'Enviando al servidor', sub: 'POST /api/v1/optimize' },
    { k: 'processing', label: 'Procesando con algoritmo heurístico', sub: 'priority · energy · deadlines' },
    { k: 'receiving', label: 'Recibiendo agenda optimizada', sub: '200 OK' },
    { k: 'done', label: 'Aplicando cambios', sub: 'UI sync' },
  ];
  const currentIdx = steps.findIndex(s => s.k === phase);

  return (
    <div className="k-app" style={{ alignItems: 'stretch', justifyContent: 'center', padding: '0 28px' }}>
      <div style={{ position: 'absolute', top: 60, right: 20 }}>
        <button onClick={onCancel} style={{ width: 36, height: 36, borderRadius: 12, background: 'var(--k-bg-2)', border: '1px solid var(--k-line)', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}>
          <IconClose size={16} stroke="var(--k-text-2)" />
        </button>
      </div>

      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center' }}>
        {/* Animated orbit */}
        <div style={{ position: 'relative', width: 200, height: 200, marginBottom: 40 }}>
          <div style={{ position: 'absolute', inset: 0, border: '1px dashed rgba(255,255,255,0.10)', borderRadius: '50%' }} />
          <div style={{ position: 'absolute', inset: 30, border: '1px solid rgba(255,255,255,0.06)', borderRadius: '50%' }} />
          <div style={{ position: 'absolute', inset: 0, animation: 'k-spin 3.5s linear infinite' }}>
            <div style={{ position: 'absolute', top: -4, left: '50%', transform: 'translateX(-50%)', width: 8, height: 8, borderRadius: '50%', background: 'var(--k-accent)', boxShadow: '0 0 20px var(--k-accent)' }} />
          </div>
          <div style={{ position: 'absolute', inset: 30, animation: 'k-spin 5s linear infinite reverse' }}>
            <div style={{ position: 'absolute', top: -3, left: '50%', transform: 'translateX(-50%)', width: 6, height: 6, borderRadius: '50%', background: 'var(--k-text-2)' }} />
          </div>
          <div style={{ position: 'absolute', inset: 60, background: 'var(--k-bg-2)', border: '1px solid var(--k-line-2)', borderRadius: '50%', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <IconSparkle size={32} stroke="var(--k-accent)" sw={1.4} />
          </div>
        </div>

        <div style={{ textAlign: 'center', marginBottom: 24 }}>
          <div className="mono" style={{ fontSize: 11, color: 'var(--k-accent)', letterSpacing: '0.1em', marginBottom: 8 }}>OPTIMIZANDO</div>
          <div style={{ fontSize: 22, fontWeight: 600, letterSpacing: '-0.02em' }}>Reorganizando tu día</div>
          <div style={{ fontSize: 13, color: 'var(--k-text-3)', marginTop: 6 }}>Esto suele tardar unos segundos</div>
        </div>

        <div style={{ width: '100%', display: 'flex', flexDirection: 'column', gap: 10 }}>
          {steps.map((s, i) => {
            const state = i < currentIdx ? 'done' : i === currentIdx ? 'active' : 'pending';
            return (
              <div key={s.k} style={{
                display: 'flex', alignItems: 'center', gap: 12, padding: '10px 12px',
                background: state === 'active' ? 'var(--k-bg-2)' : 'transparent',
                border: '1px solid ' + (state === 'active' ? 'var(--k-line-2)' : 'transparent'),
                borderRadius: 10, opacity: state === 'pending' ? 0.4 : 1, transition: 'all .2s ease',
              }}>
                <div style={{ width: 18, height: 18, borderRadius: '50%', display: 'flex', alignItems: 'center', justifyContent: 'center',
                  background: state === 'done' ? 'var(--k-accent)' : state === 'active' ? 'transparent' : 'transparent',
                  border: state === 'active' ? '1.5px solid var(--k-accent)' : state === 'pending' ? '1.5px solid var(--k-line-2)' : '0' }}>
                  {state === 'done' && <IconCheck size={11} stroke="#1a0a00" sw={2.5} />}
                  {state === 'active' && <div style={{ width: 6, height: 6, borderRadius: '50%', background: 'var(--k-accent)', animation: 'k-pulse 1s ease-in-out infinite' }} />}
                </div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 13, color: state === 'pending' ? 'var(--k-text-3)' : 'var(--k-text)' }}>{s.label}</div>
                  <div className="mono" style={{ fontSize: 10, color: 'var(--k-text-3)', marginTop: 2 }}>{s.sub}</div>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
};

const Focus = ({ task, onClose }) => {
  const POMO = 25 * 60;
  const [seconds, setSeconds] = React.useState(POMO);
  const [running, setRunning] = React.useState(true);
  const [completed, setCompleted] = React.useState(false);

  React.useEffect(() => {
    if (!running || completed) return;
    const id = setInterval(() => {
      setSeconds(s => {
        if (s <= 1) { setCompleted(true); setRunning(false); return 0; }
        return s - 1;
      });
    }, 1000);
    return () => clearInterval(id);
  }, [running, completed]);

  const mm = Math.floor(seconds / 60).toString().padStart(2, '0');
  const ss = (seconds % 60).toString().padStart(2, '0');
  const progress = (POMO - seconds) / POMO;
  const C = 2 * Math.PI * 120;

  return (
    <div className="k-app" style={{ background: '#080808' }}>
      <div style={{ height: 60, flexShrink: 0 }} />
      <div style={{ padding: '12px 20px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexShrink: 0 }}>
        <button className="k-btn k-btn-text" style={{ height: 36, padding: 0, fontSize: 13 }} onClick={onClose}>
          <IconClose size={16} stroke="var(--k-text-2)" /> Salir
        </button>
        <div className="mono" style={{ fontSize: 11, color: 'var(--k-text-3)', letterSpacing: '0.1em' }}>POMODORO 1/4</div>
        <div style={{ width: 36 }} />
      </div>

      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '0 28px' }}>
        <div className="mono" style={{ fontSize: 11, color: 'var(--k-accent)', letterSpacing: '0.1em', marginBottom: 12 }}>ENFOCADO EN</div>
        <div style={{ textAlign: 'center', fontSize: 18, fontWeight: 500, marginBottom: 48, maxWidth: 280, textWrap: 'pretty' }}>
          {task ? task.title : 'Sesión libre'}
        </div>

        <div style={{ position: 'relative', width: 280, height: 280, marginBottom: 40 }}>
          <svg width="280" height="280" viewBox="0 0 280 280" style={{ position: 'absolute', inset: 0 }}>
            <circle cx="140" cy="140" r="120" fill="none" stroke="rgba(255,255,255,0.05)" strokeWidth="1.5" />
            <circle cx="140" cy="140" r="120" fill="none" stroke="var(--k-accent)" strokeWidth="2"
              strokeDasharray={C} strokeDashoffset={C * (1 - progress)}
              transform="rotate(-90 140 140)" strokeLinecap="round"
              style={{ transition: 'stroke-dashoffset 1s linear' }} />
          </svg>
          <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}>
            <div className="mono tnum" style={{ fontSize: 64, fontWeight: 300, letterSpacing: '-0.04em', lineHeight: 1 }}>
              {mm}<span style={{ color: 'var(--k-text-3)' }}>:</span>{ss}
            </div>
            <div className="mono" style={{ fontSize: 11, color: 'var(--k-text-3)', letterSpacing: '0.15em', marginTop: 14 }}>
              {completed ? 'COMPLETADO' : running ? 'EN PROGRESO' : 'EN PAUSA'}
            </div>
          </div>
        </div>

        <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
          <button onClick={() => { setSeconds(POMO); setCompleted(false); setRunning(true); }}
            style={{ width: 52, height: 52, borderRadius: 16, background: 'var(--k-bg-2)', border: '1px solid var(--k-line)', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}>
            <IconSync size={18} stroke="var(--k-text-2)" />
          </button>
          <button onClick={() => setRunning(r => !r)} disabled={completed}
            style={{ width: 72, height: 72, borderRadius: 24, background: completed ? 'var(--k-bg-2)' : 'var(--k-accent)', border: 0,
              display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: completed ? 'default' : 'pointer',
              boxShadow: completed ? 'none' : '0 10px 30px rgba(251,146,60,0.35)' }}>
            {completed ? <IconCheck size={26} stroke="var(--k-success)" sw={2.2} /> : running ? <IconPause size={22} fill="#1a0a00" stroke="#1a0a00" /> : <IconPlay size={22} fill="#1a0a00" stroke="#1a0a00" />}
          </button>
          <button onClick={onClose}
            style={{ width: 52, height: 52, borderRadius: 16, background: 'var(--k-bg-2)', border: '1px solid var(--k-line)', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}>
            <IconClose size={18} stroke="var(--k-danger)" />
          </button>
        </div>

        <div style={{ marginTop: 32, display: 'flex', gap: 24, fontSize: 11, color: 'var(--k-text-3)' }} className="mono">
          <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
            <IconShield size={11} stroke="var(--k-text-3)" /> NOTIFS PAUSADAS
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
            <IconBolt size={11} stroke="var(--k-text-3)" /> +12 PUNTOS
          </div>
        </div>
      </div>
    </div>
  );
};

const Stats = () => {
  const maxTasks = Math.max(...STATS_WEEK.map(d => d.tasks));
  const totalTasks = STATS_WEEK.reduce((s, d) => s + d.tasks, 0);
  const totalFocus = STATS_WEEK.reduce((s, d) => s + d.focus, 0);
  const fh = Math.floor(totalFocus / 60), fm = totalFocus % 60;

  return (
    <div style={{ flex: 1, overflowY: 'auto' }}>
      <div style={{ padding: '64px 20px 12px' }}>
        <div className="mono" style={{ fontSize: 11, color: 'var(--k-text-3)', letterSpacing: '0.08em' }}>ÚLTIMOS 7 DÍAS</div>
        <div style={{ fontSize: 28, fontWeight: 600, letterSpacing: '-0.025em', marginTop: 6 }}>Tu productividad</div>
      </div>

      {/* KPIs */}
      <div style={{ padding: '12px 20px', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
        {[
          { l: 'Tareas completadas', v: totalTasks, sub: '+12% vs anterior', icon: IconCheck },
          { l: 'Tiempo enfocado', v: `${fh}h ${fm}m`, sub: '21 sesiones', icon: IconClock },
          { l: 'Racha actual', v: '14 días', sub: 'mejor: 23 días', icon: IconBolt },
          { l: 'Tareas/día', v: (totalTasks / 7).toFixed(1), sub: 'media semanal', icon: IconChart },
        ].map((k, i) => (
          <div key={i} className="k-card" style={{ padding: 14 }}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 10 }}>
              <span style={{ fontSize: 11, color: 'var(--k-text-3)' }}>{k.l}</span>
              <k.icon size={12} stroke="var(--k-text-3)" />
            </div>
            <div className="mono tnum" style={{ fontSize: 22, fontWeight: 500, letterSpacing: '-0.02em' }}>{k.v}</div>
            <div style={{ fontSize: 10, color: 'var(--k-text-3)', marginTop: 4 }}>{k.sub}</div>
          </div>
        ))}
      </div>

      {/* Bar chart */}
      <div style={{ padding: '8px 20px' }}>
        <div className="k-card" style={{ padding: 18 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 18 }}>
            <span style={{ fontSize: 13, fontWeight: 500 }}>Tareas completadas</span>
            <span className="mono" style={{ fontSize: 11, color: 'var(--k-text-3)' }}>POR DÍA</span>
          </div>
          <div style={{ display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', height: 120, gap: 8 }}>
            {STATS_WEEK.map((d, i) => {
              const h = (d.tasks / maxTasks) * 100;
              return (
                <div key={i} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
                  <div style={{ width: '100%', flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'flex-end' }}>
                    <div style={{ width: '100%', height: `${h}%`, background: i === 3 ? 'var(--k-accent)' : 'rgba(255,255,255,0.10)', borderRadius: 4, position: 'relative' }}>
                      {i === 3 && <div className="mono tnum" style={{ position: 'absolute', top: -18, left: 0, right: 0, textAlign: 'center', fontSize: 11, color: 'var(--k-accent)' }}>{d.tasks}</div>}
                    </div>
                  </div>
                  <span className="mono" style={{ fontSize: 11, color: 'var(--k-text-3)' }}>{d.d}</span>
                </div>
              );
            })}
          </div>
        </div>
      </div>

      {/* Heatmap */}
      <div style={{ padding: '8px 20px' }}>
        <div className="k-card" style={{ padding: 18 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 14 }}>
            <span style={{ fontSize: 13, fontWeight: 500 }}>Sesiones de enfoque</span>
            <span className="mono" style={{ fontSize: 11, color: 'var(--k-text-3)' }}>4 SEMANAS</span>
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7, 1fr)', gap: 4 }}>
            {HEATMAP.map((v, i) => (
              <div key={i} style={{
                aspectRatio: '1', borderRadius: 3,
                background: ['rgba(255,255,255,0.04)', 'rgba(251,146,60,0.20)', 'rgba(251,146,60,0.40)', 'rgba(251,146,60,0.65)', 'rgba(251,146,60,0.95)'][v],
              }} />
            ))}
          </div>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: 12 }}>
            <span className="mono" style={{ fontSize: 10, color: 'var(--k-text-3)' }}>MENOS</span>
            <div style={{ display: 'flex', gap: 3 }}>
              {[0,1,2,3,4].map(v => (
                <div key={v} style={{ width: 10, height: 10, borderRadius: 2,
                  background: ['rgba(255,255,255,0.04)', 'rgba(251,146,60,0.20)', 'rgba(251,146,60,0.40)', 'rgba(251,146,60,0.65)', 'rgba(251,146,60,0.95)'][v] }} />
              ))}
            </div>
            <span className="mono" style={{ fontSize: 10, color: 'var(--k-text-3)' }}>MÁS</span>
          </div>
        </div>
      </div>

      {/* Insights */}
      <div style={{ padding: '8px 20px 24px' }}>
        <div className="mono" style={{ fontSize: 11, color: 'var(--k-text-3)', letterSpacing: '0.1em', padding: '8px 4px' }}>INSIGHTS</div>
        {[
          { title: 'Tu mejor día es el jueves', sub: 'Promedio: 13 tareas completadas', dot: 'var(--k-accent)' },
          { title: 'Procrastinas más por las tardes', sub: 'Solo 28% de tareas tras las 18:00', dot: 'var(--k-warn)' },
          { title: 'Subestimas tareas de energía 4-5', sub: '+22% sobre tu estimación', dot: 'var(--k-text-3)' },
        ].map((it, i) => (
          <div key={i} style={{ display: 'flex', alignItems: 'flex-start', gap: 12, padding: '12px 14px', background: 'var(--k-bg-2)', border: '1px solid var(--k-line)', borderRadius: 12, marginBottom: 8 }}>
            <div style={{ width: 6, height: 6, borderRadius: '50%', background: it.dot, marginTop: 6 }} />
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 13, fontWeight: 500 }}>{it.title}</div>
              <div style={{ fontSize: 11, color: 'var(--k-text-3)', marginTop: 2 }}>{it.sub}</div>
            </div>
          </div>
        ))}
      </div>
      <div style={{ height: 80 }} />
    </div>
  );
};

const Profile = ({ online, setOnline, openSync, openConflict, onLogout }) => (
  <div style={{ flex: 1, overflowY: 'auto' }}>
    <div style={{ padding: '64px 20px 12px' }}>
      <div style={{ fontSize: 28, fontWeight: 600, letterSpacing: '-0.025em' }}>Perfil</div>
    </div>

    <div style={{ padding: '8px 20px 16px' }}>
      <div className="k-card" style={{ padding: 18, display: 'flex', alignItems: 'center', gap: 14 }}>
        <div style={{ width: 56, height: 56, borderRadius: 18, background: 'linear-gradient(135deg, #fb923c, #c2410c)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 22, fontWeight: 600, color: '#1a0a00' }}>IM</div>
        <div style={{ flex: 1 }}>
          <div style={{ fontSize: 16, fontWeight: 600 }}>Ismael Manzano</div>
          <div style={{ fontSize: 12, color: 'var(--k-text-3)' }}>ismael@kairos.app</div>
        </div>
        <IconChevronR size={16} stroke="var(--k-text-3)" />
      </div>
    </div>

    {/* Sync status */}
    <div style={{ padding: '8px 20px' }}>
      <div className="mono" style={{ fontSize: 11, color: 'var(--k-text-3)', letterSpacing: '0.1em', padding: '8px 4px' }}>SINCRONIZACIÓN</div>
      <div className="k-card" style={{ overflow: 'hidden' }}>
        <div style={{ padding: 14, display: 'flex', alignItems: 'center', gap: 12, borderBottom: '1px solid var(--k-line)' }}>
          {online ? <IconCloud size={18} stroke="var(--k-success)" /> : <IconCloudOff size={18} stroke="var(--k-warn)" />}
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 13, fontWeight: 500 }}>{online ? 'Sincronizado' : 'Modo offline'}</div>
            <div style={{ fontSize: 11, color: 'var(--k-text-3)' }} className="mono">
              {online ? 'última sync: hace 2 min' : '3 cambios pendientes'}
            </div>
          </div>
          <button onClick={() => setOnline(!online)} style={{
            width: 38, height: 22, borderRadius: 99, padding: 0, border: 0,
            background: online ? 'var(--k-accent)' : 'var(--k-bg-3)', position: 'relative', cursor: 'pointer',
          }}>
            <div style={{ position: 'absolute', top: 2, left: online ? 18 : 2, width: 18, height: 18, borderRadius: '50%', background: '#fff', transition: 'left .15s ease' }} />
          </button>
        </div>
        <div onClick={openSync} style={{ padding: 14, display: 'flex', alignItems: 'center', gap: 12, cursor: 'pointer', borderBottom: '1px solid var(--k-line)' }}>
          <IconSync size={18} stroke="var(--k-text-2)" />
          <div style={{ flex: 1, fontSize: 13 }}>Forzar sincronización</div>
          <IconChevronR size={14} stroke="var(--k-text-3)" />
        </div>
        <div onClick={openConflict} style={{ padding: 14, display: 'flex', alignItems: 'center', gap: 12, cursor: 'pointer' }}>
          <IconAlert size={18} stroke="var(--k-warn)" />
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 13 }}>Conflictos de versión</div>
            <div style={{ fontSize: 11, color: 'var(--k-warn)' }} className="mono">1 PENDIENTE</div>
          </div>
          <IconChevronR size={14} stroke="var(--k-text-3)" />
        </div>
      </div>
    </div>

    <div style={{ padding: '8px 20px' }}>
      <div className="mono" style={{ fontSize: 11, color: 'var(--k-text-3)', letterSpacing: '0.1em', padding: '8px 4px' }}>PREFERENCIAS</div>
      <div className="k-card" style={{ overflow: 'hidden' }}>
        {[
          { I: IconBell, l: 'Notificaciones', v: 'Activadas' },
          { I: IconMoon, l: 'Apariencia', v: 'Oscuro' },
          { I: IconShield, l: 'Privacidad y datos', v: '' },
          { I: IconSettings, l: 'Ajustes avanzados', v: '' },
        ].map((it, i, arr) => (
          <div key={i} style={{ padding: 14, display: 'flex', alignItems: 'center', gap: 12, cursor: 'pointer', borderBottom: i < arr.length - 1 ? '1px solid var(--k-line)' : 0 }}>
            <it.I size={18} stroke="var(--k-text-2)" />
            <div style={{ flex: 1, fontSize: 13 }}>{it.l}</div>
            {it.v && <span style={{ fontSize: 12, color: 'var(--k-text-3)' }}>{it.v}</span>}
            <IconChevronR size={14} stroke="var(--k-text-3)" />
          </div>
        ))}
      </div>
    </div>

    <div style={{ padding: '16px 20px 32px' }}>
      <button onClick={onLogout} className="k-btn k-btn-ghost" style={{ color: 'var(--k-danger)' }}>
        <IconLogout size={16} stroke="var(--k-danger)" /> Cerrar sesión
      </button>
      <div className="mono" style={{ textAlign: 'center', fontSize: 10, color: 'var(--k-text-4)', marginTop: 16, letterSpacing: '0.08em' }}>
        KAIROS 2.0.1 · BUILD 2026.04.25 · ©IML
      </div>
    </div>
    <div style={{ height: 80 }} />
  </div>
);

const SyncSheet = ({ onClose }) => {
  const [phase, setPhase] = React.useState(0);
  React.useEffect(() => {
    const id = setInterval(() => setPhase(p => p < 3 ? p + 1 : p), 700);
    return () => clearInterval(id);
  }, []);

  return (
    <div style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.65)', backdropFilter: 'blur(8px)', display: 'flex', alignItems: 'flex-end', zIndex: 60, animation: 'k-fade-in .2s ease' }}>
      <div style={{ width: '100%', background: 'var(--k-bg-1)', borderTopLeftRadius: 24, borderTopRightRadius: 24, padding: '12px 24px 36px', borderTop: '1px solid var(--k-line-2)' }}>
        <div style={{ width: 36, height: 4, background: 'var(--k-line-2)', borderRadius: 99, margin: '4px auto 16px' }} />
        <div style={{ fontSize: 18, fontWeight: 600, letterSpacing: '-0.02em', marginBottom: 6 }}>Sincronizando datos</div>
        <div style={{ fontSize: 13, color: 'var(--k-text-2)', marginBottom: 20 }}>Realm ↔ PostgreSQL · API REST</div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          {[
            { l: 'Detectando cambios locales', v: '3 objetos · isSynced=false' },
            { l: 'Subiendo a /api/v1/tasks', v: 'PUT · 200 OK' },
            { l: 'Descargando cambios remotos', v: '2 objetos nuevos' },
            { l: 'Aplicando en Realm', v: 'commit() · ✓' },
          ].map((s, i) => (
            <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 12, opacity: i <= phase ? 1 : 0.35, transition: 'opacity .25s ease' }}>
              <div style={{ width: 16, height: 16, borderRadius: '50%', background: i < phase ? 'var(--k-accent)' : 'transparent', border: i === phase ? '1.5px solid var(--k-accent)' : i < phase ? '0' : '1.5px solid var(--k-line-2)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                {i < phase && <IconCheck size={9} stroke="#1a0a00" sw={2.5} />}
                {i === phase && <div style={{ width: 5, height: 5, borderRadius: '50%', background: 'var(--k-accent)', animation: 'k-pulse 1s ease-in-out infinite' }} />}
              </div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 13 }}>{s.l}</div>
                <div className="mono" style={{ fontSize: 10, color: 'var(--k-text-3)', marginTop: 1 }}>{s.v}</div>
              </div>
            </div>
          ))}
        </div>
        <button className="k-btn k-btn-ghost" style={{ marginTop: 24 }} onClick={onClose}>Cerrar</button>
      </div>
    </div>
  );
};

const ConflictSheet = ({ onResolve, onClose }) => (
  <div style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.65)', backdropFilter: 'blur(8px)', display: 'flex', alignItems: 'flex-end', zIndex: 60, animation: 'k-fade-in .2s ease' }}>
    <div style={{ width: '100%', background: 'var(--k-bg-1)', borderTopLeftRadius: 24, borderTopRightRadius: 24, padding: '12px 24px 36px', borderTop: '1px solid var(--k-line-2)' }}>
      <div style={{ width: 36, height: 4, background: 'var(--k-line-2)', borderRadius: 99, margin: '4px auto 16px' }} />
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 8 }}>
        <IconAlert size={18} stroke="var(--k-warn)" />
        <div style={{ fontSize: 18, fontWeight: 600, letterSpacing: '-0.02em' }}>Conflicto de versión</div>
      </div>
      <div style={{ fontSize: 13, color: 'var(--k-text-2)', marginBottom: 18 }}>
        Esta tarea ha sido modificada en dos dispositivos. Elige qué versión conservar.
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
        {[
          { src: 'LOCAL · iPhone', date: 'Hoy 14:32', title: 'Refactorizar módulo de auth (JWT v2)', priority: 'high', accent: 'var(--k-accent)' },
          { src: 'REMOTO · MacBook', date: 'Hoy 14:28', title: 'Refactorizar módulo de auth con tokens', priority: 'med', accent: 'var(--k-text-3)' },
        ].map((v, i) => (
          <div key={i} style={{ padding: 14, background: 'var(--k-bg-2)', border: '1px solid ' + v.accent, borderRadius: 12 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 10 }}>
              <span className="mono" style={{ fontSize: 10, color: v.accent, letterSpacing: '0.08em' }}>{v.src}</span>
              <span className="mono" style={{ fontSize: 10, color: 'var(--k-text-3)' }}>{v.date}</span>
            </div>
            <div style={{ fontSize: 14, fontWeight: 500, marginBottom: 8 }}>{v.title}</div>
            <PriorityChip p={v.priority} />
          </div>
        ))}
      </div>

      <div style={{ display: 'flex', gap: 10, marginTop: 20 }}>
        <button className="k-btn k-btn-ghost" onClick={onClose} style={{ flex: 1 }}>Más tarde</button>
        <button className="k-btn k-btn-primary" onClick={onResolve} style={{ flex: 1 }}>Mantener local</button>
      </div>
    </div>
  </div>
);

const OfflineBanner = ({ visible }) => (
  <div style={{
    position: 'absolute', top: 56, left: 12, right: 12, zIndex: 40,
    transform: visible ? 'translateY(0)' : 'translateY(-80px)', opacity: visible ? 1 : 0,
    transition: 'all .3s cubic-bezier(.2,.7,.3,1)',
    padding: '10px 14px', background: 'rgba(250,204,21,0.12)', border: '1px solid rgba(250,204,21,0.25)',
    borderRadius: 12, display: 'flex', alignItems: 'center', gap: 10, backdropFilter: 'blur(20px)',
  }}>
    <IconWifiOff size={14} stroke="var(--k-warn)" />
    <div style={{ flex: 1 }}>
      <div style={{ fontSize: 12, fontWeight: 500, color: 'var(--k-warn)' }}>Sin conexión</div>
      <div style={{ fontSize: 10, color: 'rgba(250,204,21,0.7)' }} className="mono">Se sincronizará al recuperar red</div>
    </div>
  </div>
);

Object.assign(window, { Optimize, Focus, Stats, Profile, SyncSheet, ConflictSheet, OfflineBanner });
