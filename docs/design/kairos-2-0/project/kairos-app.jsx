// kairos-app.jsx — Main interactive prototype: routes between all screens

const Prototype = ({ accent }) => {
  const [tasks, setTasks] = React.useState(SEED_TASKS);
  const [route, setRoute] = React.useState({ name: 'splash' });
  const [tab, setTab] = React.useState('home');
  const [online, setOnline] = React.useState(true);
  const [overlay, setOverlay] = React.useState(null);
  const [showOffline, setShowOffline] = React.useState(false);

  React.useEffect(() => {
    if (route.name === 'splash') {
      const t = setTimeout(() => setRoute({ name: 'onboarding' }), 1800);
      return () => clearTimeout(t);
    }
  }, [route.name]);

  React.useEffect(() => { document.documentElement.style.setProperty('--k-accent', accent); }, [accent]);

  const toggleTask = (id) => setTasks(ts => ts.map(t => t.id === id ? { ...t, done: !t.done, isSynced: false } : t));
  const deleteTask = (id) => setTasks(ts => ts.filter(t => t.id !== id));
  const addTask = (data) => {
    const t = { id: 'tn' + Date.now(), ...data, done: false, isSynced: online, project: 'Personal' };
    setTasks(ts => [t, ...ts]);
    setRoute({ name: 'app' });
    setTab('home');
  };
  const openTask = (task) => setRoute({ name: 'detail', task });

  const goLogin = () => setRoute({ name: 'login' });
  const goApp = () => { setRoute({ name: 'app' }); setTab('home'); };

  // Toggle offline banner briefly when going offline
  const toggleOnline = (v) => {
    setOnline(v);
    if (!v) { setShowOffline(true); setTimeout(() => setShowOffline(false), 2800); }
  };

  // Render
  let content;
  if (route.name === 'splash') content = <Splash />;
  else if (route.name === 'onboarding') content = <Onboarding onDone={goLogin} />;
  else if (route.name === 'login') content = <Login onLogin={goApp} />;
  else if (route.name === 'create') content = <CreateTask onCancel={() => setRoute({ name: 'app' })} onSave={addTask} />;
  else if (route.name === 'detail') content = <TaskDetail task={route.task} onClose={() => setRoute({ name: 'app' })} onToggle={toggleTask} onDelete={deleteTask} />;
  else if (route.name === 'optimize') content = <Optimize onDone={() => { setRoute({ name: 'app' }); setTab('home'); }} onCancel={() => setRoute({ name: 'app' })} />;
  else if (route.name === 'focus') content = <Focus task={route.task} onClose={() => setRoute({ name: 'app' })} />;
  else if (route.name === 'app') {
    let inner;
    if (tab === 'home') inner = <Dashboard tasks={tasks} setTab={setTab} openTask={openTask} toggleTask={toggleTask} deleteTask={deleteTask} openCreate={() => setRoute({ name: 'create' })} openOptimize={() => setRoute({ name: 'optimize' })} online={online} />;
    else if (tab === 'list') inner = <TaskList tasks={tasks} openTask={openTask} toggleTask={toggleTask} deleteTask={deleteTask} openCreate={() => setRoute({ name: 'create' })} />;
    else if (tab === 'focus') inner = <FocusLanding tasks={tasks} onStart={(task) => setRoute({ name: 'focus', task })} />;
    else if (tab === 'stats') inner = <Stats />;
    else if (tab === 'profile') inner = <Profile online={online} setOnline={toggleOnline} openSync={() => setOverlay('sync')} openConflict={() => setOverlay('conflict')} onLogout={() => setRoute({ name: 'login' })} />;
    content = (
      <div className="k-app">
        {inner}
        <TabBar tab={tab} setTab={setTab} />
        <OfflineBanner visible={showOffline} />
        {overlay === 'sync' && <SyncSheet onClose={() => setOverlay(null)} />}
        {overlay === 'conflict' && <ConflictSheet onClose={() => setOverlay(null)} onResolve={() => setOverlay(null)} />}
      </div>
    );
  }

  return content;
};

// Focus tab landing — pick a task to focus on
const FocusLanding = ({ tasks, onStart }) => {
  const top = tasks.filter(t => !t.done).slice(0, 4);
  return (
    <div style={{ flex: 1, overflowY: 'auto' }}>
      <div style={{ padding: '64px 20px 12px' }}>
        <div className="mono" style={{ fontSize: 11, color: 'var(--k-text-3)', letterSpacing: '0.08em' }}>DEEP WORK</div>
        <div style={{ fontSize: 28, fontWeight: 600, letterSpacing: '-0.025em', marginTop: 6 }}>Modo enfoque</div>
        <div style={{ fontSize: 14, color: 'var(--k-text-2)', marginTop: 8, lineHeight: 1.5 }}>
          Una tarea. Un cronómetro. Sin distracciones. Empieza una sesión Pomodoro de 25 minutos.
        </div>
      </div>

      <div style={{ padding: '16px 20px 8px' }}>
        <button onClick={() => onStart(null)} className="k-btn k-btn-primary" style={{ height: 56 }}>
          <IconPlay size={16} fill="#1a0a00" stroke="#1a0a00" /> Empezar sesión libre
        </button>
      </div>

      <div style={{ padding: '16px 20px 8px' }}>
        <div className="mono" style={{ fontSize: 11, color: 'var(--k-text-3)', letterSpacing: '0.1em', padding: '8px 0' }}>O ENFÓCATE EN UNA TAREA</div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          {top.map(t => (
            <button key={t.id} onClick={() => onStart(t)} style={{
              padding: 14, background: 'var(--k-bg-2)', border: '1px solid var(--k-line)', borderRadius: 12,
              display: 'flex', alignItems: 'center', gap: 12, cursor: 'pointer', textAlign: 'left', fontFamily: 'var(--font-sans)', color: 'var(--k-text)',
            }}>
              <div style={{ width: 36, height: 36, borderRadius: 10, background: 'var(--k-bg-3)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <IconFocus size={16} stroke="var(--k-accent)" />
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 13, fontWeight: 500, lineHeight: 1.3 }}>{t.title}</div>
                <div className="mono" style={{ fontSize: 10, color: 'var(--k-text-3)', marginTop: 4 }}>~{t.estimate}MIN · ENERGY {t.energy}/5</div>
              </div>
              <IconArrowR size={14} stroke="var(--k-text-3)" />
            </button>
          ))}
        </div>
      </div>

      <div style={{ padding: '16px 20px' }}>
        <div className="k-card" style={{ padding: 16 }}>
          <div className="mono" style={{ fontSize: 11, color: 'var(--k-text-3)', letterSpacing: '0.1em', marginBottom: 12 }}>HOY</div>
          <div style={{ display: 'flex', gap: 24 }}>
            <div>
              <div className="mono tnum" style={{ fontSize: 22, fontWeight: 500 }}>3</div>
              <div style={{ fontSize: 11, color: 'var(--k-text-3)', marginTop: 2 }}>sesiones</div>
            </div>
            <div>
              <div className="mono tnum" style={{ fontSize: 22, fontWeight: 500 }}>1h 15m</div>
              <div style={{ fontSize: 11, color: 'var(--k-text-3)', marginTop: 2 }}>tiempo enfocado</div>
            </div>
          </div>
        </div>
      </div>
      <div style={{ height: 80 }} />
    </div>
  );
};

Object.assign(window, { Prototype, FocusLanding });
