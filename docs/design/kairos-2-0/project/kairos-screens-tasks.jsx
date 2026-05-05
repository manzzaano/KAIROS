// kairos-screens-tasks.jsx — Dashboard, TaskList (swipe), CreateTask, TaskDetail

const PriorityChip = ({ p }) => {
  const c = PRIORITY_COLOR[p];
  return (
    <span className="k-chip" style={{ background: c.bg, color: c.fg }}>
      <span style={{ width: 5, height: 5, borderRadius: '50%', background: c.dot }} />
      {PRIORITY_LABEL[p]}
    </span>
  );
};

const EnergyDots = ({ value, size = 4 }) => (
  <div style={{ display: 'flex', gap: 2 }}>
    {[1,2,3,4,5].map(i => (
      <div key={i} style={{ width: size, height: size, borderRadius: '50%',
        background: i <= value ? 'var(--k-accent)' : 'rgba(255,255,255,0.10)' }} />
    ))}
  </div>
);

const TaskRow = ({ task, onToggle, onClick, onDelete, swipeEnabled = true }) => {
  const [drag, setDrag] = React.useState(0);
  const [start, setStart] = React.useState(null);
  const startX = React.useRef(0);
  const onDown = (e) => {
    if (!swipeEnabled) return;
    startX.current = (e.touches ? e.touches[0].clientX : e.clientX);
    setStart(startX.current);
  };
  const onMove = (e) => {
    if (start == null) return;
    const x = (e.touches ? e.touches[0].clientX : e.clientX);
    const dx = x - start;
    setDrag(Math.max(-110, Math.min(110, dx)));
  };
  const onUp = () => {
    if (drag > 70) onToggle && onToggle(task.id);
    else if (drag < -70) onDelete && onDelete(task.id);
    setDrag(0); setStart(null);
  };

  return (
    <div style={{ position: 'relative', overflow: 'hidden', borderRadius: 12 }}>
      {/* swipe action layers */}
      {swipeEnabled && (
        <>
          <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', paddingLeft: 20,
            background: 'rgba(74,222,128,0.18)', opacity: drag > 0 ? Math.min(drag / 70, 1) : 0 }}>
            <IconCheck size={20} stroke="var(--k-success)" />
            <span className="mono" style={{ marginLeft: 10, fontSize: 11, color: 'var(--k-success)' }}>COMPLETAR</span>
          </div>
          <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'flex-end', paddingRight: 20,
            background: 'rgba(248,113,113,0.18)', opacity: drag < 0 ? Math.min(-drag / 70, 1) : 0 }}>
            <span className="mono" style={{ marginRight: 10, fontSize: 11, color: 'var(--k-danger)' }}>ELIMINAR</span>
            <IconTrash size={20} stroke="var(--k-danger)" />
          </div>
        </>
      )}
      <div
        onMouseDown={onDown} onMouseMove={onMove} onMouseUp={onUp} onMouseLeave={onUp}
        onTouchStart={onDown} onTouchMove={onMove} onTouchEnd={onUp}
        style={{
          position: 'relative', transform: `translateX(${drag}px)`,
          transition: start == null ? 'transform .25s cubic-bezier(.2,.7,.3,1)' : 'none',
          background: 'var(--k-bg-2)', border: '1px solid var(--k-line)', borderRadius: 12,
          padding: '14px 14px', display: 'flex', alignItems: 'flex-start', gap: 12,
          cursor: 'pointer', userSelect: 'none',
        }}
        onClick={(e) => { if (Math.abs(drag) < 4) onClick && onClick(task); }}
      >
        <button
          onClick={(e) => { e.stopPropagation(); onToggle && onToggle(task.id); }}
          style={{
            flexShrink: 0, marginTop: 2, width: 20, height: 20, borderRadius: 6, padding: 0,
            border: '1.5px solid ' + (task.done ? 'var(--k-accent)' : 'var(--k-line-2)'),
            background: task.done ? 'var(--k-accent)' : 'transparent',
            display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer',
          }}>
          {task.done && <IconCheck size={12} stroke="#1a0a00" sw={2.5} />}
        </button>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontSize: 14, fontWeight: 500, color: task.done ? 'var(--k-text-3)' : 'var(--k-text)',
            textDecoration: task.done ? 'line-through' : 'none', lineHeight: 1.35, marginBottom: 6 }}>
            {task.title}
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10, flexWrap: 'wrap' }}>
            <PriorityChip p={task.priority} />
            <div style={{ display: 'flex', alignItems: 'center', gap: 4, fontSize: 11, color: 'var(--k-text-3)' }}>
              <IconBolt size={11} stroke="var(--k-text-3)" />
              <EnergyDots value={task.energy} />
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 4, fontSize: 11, color: 'var(--k-text-3)' }} className="mono">
              <IconClock size={11} stroke="var(--k-text-3)" />
              {task.estimate}m
            </div>
            {!task.isSynced && (
              <div style={{ display: 'flex', alignItems: 'center', gap: 4, fontSize: 10, color: 'var(--k-warn)' }} className="mono">
                <div style={{ width: 5, height: 5, borderRadius: '50%', background: 'var(--k-warn)' }} />
                LOCAL
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

const TabBar = ({ tab, setTab }) => (
  <div className="k-tabbar">
    {[
      { k: 'home', label: 'Hoy', I: IconHome },
      { k: 'list', label: 'Tareas', I: IconList },
      { k: 'focus', label: 'Enfoque', I: IconFocus },
      { k: 'stats', label: 'Stats', I: IconChart },
      { k: 'profile', label: 'Perfil', I: IconUser },
    ].map(({ k, label, I }) => (
      <div key={k} className={'k-tab' + (tab === k ? ' active' : '')} onClick={() => setTab(k)}>
        <I size={20} sw={tab === k ? 1.8 : 1.5} />
        <span>{label}</span>
      </div>
    ))}
  </div>
);

const Dashboard = ({ tasks, setTab, openTask, toggleTask, deleteTask, openCreate, openOptimize, online }) => {
  const today = tasks.filter(t => t.due && t.due.startsWith('Hoy'));
  const pending = today.filter(t => !t.done);
  const done = today.filter(t => t.done);
  const totalEnergy = pending.reduce((s, t) => s + t.energy, 0);
  const energyMax = 18;

  return (
    <>
      <div style={{ flex: 1, overflowY: 'auto' }}>
        {/* header */}
        <div style={{ padding: '64px 20px 16px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 8 }}>
            <div>
              <div className="mono" style={{ fontSize: 11, color: 'var(--k-text-3)', letterSpacing: '0.08em' }}>
                {new Date(2026, 3, 25).toLocaleDateString('es-ES', { weekday: 'long', day: 'numeric', month: 'long' }).toUpperCase()}
              </div>
              <div style={{ fontSize: 28, fontWeight: 600, letterSpacing: '-0.025em', marginTop: 6 }}>Buenos días, Ismael</div>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
              <div style={{ width: 36, height: 36, borderRadius: '50%', background: 'var(--k-bg-2)', border: '1px solid var(--k-line)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <IconBell size={16} stroke="var(--k-text-2)" />
              </div>
            </div>
          </div>

          {/* energy bar */}
          <div style={{ marginTop: 20, padding: 16, background: 'var(--k-bg-2)', border: '1px solid var(--k-line)', borderRadius: 14 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 10 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                <IconBolt size={14} stroke="var(--k-accent)" />
                <span style={{ fontSize: 13, fontWeight: 500 }}>Energía requerida hoy</span>
              </div>
              <span className="mono tnum" style={{ fontSize: 12, color: 'var(--k-text-2)' }}>{totalEnergy}/{energyMax}</span>
            </div>
            <div style={{ height: 6, background: 'rgba(255,255,255,0.06)', borderRadius: 99, overflow: 'hidden' }}>
              <div style={{ height: '100%', width: `${(totalEnergy / energyMax) * 100}%`, background: 'var(--k-accent)', borderRadius: 99, transition: 'width .3s ease' }} />
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 8, fontSize: 11, color: 'var(--k-text-3)' }}>
              <span>{pending.length} pendientes</span>
              <span>{done.length} completadas</span>
            </div>
          </div>

          {/* AI optimize CTA */}
          <button onClick={openOptimize} disabled={!online} style={{
            marginTop: 12, width: '100%', padding: '14px 16px', borderRadius: 14,
            background: online ? 'linear-gradient(135deg, rgba(251,146,60,0.14), rgba(251,146,60,0.04))' : 'var(--k-bg-2)',
            border: '1px solid ' + (online ? 'rgba(251,146,60,0.25)' : 'var(--k-line)'),
            display: 'flex', alignItems: 'center', gap: 12, cursor: online ? 'pointer' : 'not-allowed',
            opacity: online ? 1 : 0.5, color: 'var(--k-text)', fontFamily: 'var(--font-sans)',
          }}>
            <div style={{ width: 32, height: 32, borderRadius: 10, background: 'rgba(251,146,60,0.18)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <IconSparkle size={16} stroke="var(--k-accent)" />
            </div>
            <div style={{ flex: 1, textAlign: 'left' }}>
              <div style={{ fontSize: 14, fontWeight: 500 }}>Optimizar mi día con IA</div>
              <div style={{ fontSize: 11, color: 'var(--k-text-3)', marginTop: 2 }}>
                {online ? 'Reordena por prioridad y energía' : 'Función no disponible offline'}
              </div>
            </div>
            <IconChevronR size={16} stroke="var(--k-text-3)" />
          </button>
        </div>

        {/* pending */}
        <div style={{ padding: '12px 20px 8px', display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
          <div className="mono" style={{ fontSize: 11, color: 'var(--k-text-3)', letterSpacing: '0.1em' }}>PENDIENTES · {pending.length}</div>
          <button className="k-btn k-btn-text" style={{ height: 24, padding: 0, fontSize: 12 }} onClick={() => setTab('list')}>Ver todas</button>
        </div>
        <div style={{ padding: '0 20px', display: 'flex', flexDirection: 'column', gap: 8 }}>
          {pending.map(t => <TaskRow key={t.id} task={t} onToggle={toggleTask} onClick={openTask} onDelete={deleteTask} />)}
        </div>

        {/* completed */}
        {done.length > 0 && (
          <>
            <div style={{ padding: '24px 20px 8px' }}>
              <div className="mono" style={{ fontSize: 11, color: 'var(--k-text-3)', letterSpacing: '0.1em' }}>COMPLETADAS · {done.length}</div>
            </div>
            <div style={{ padding: '0 20px 24px', display: 'flex', flexDirection: 'column', gap: 8 }}>
              {done.map(t => <TaskRow key={t.id} task={t} onToggle={toggleTask} onClick={openTask} onDelete={deleteTask} />)}
            </div>
          </>
        )}
        <div style={{ height: 80 }} />
      </div>

      {/* FAB */}
      <button onClick={openCreate} style={{
        position: 'absolute', bottom: 100, right: 20, width: 56, height: 56, borderRadius: 18,
        background: 'var(--k-accent)', border: 0, cursor: 'pointer',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        boxShadow: '0 10px 30px rgba(251,146,60,0.35), 0 0 0 1px rgba(251,146,60,0.5)',
        zIndex: 10,
      }}>
        <IconPlus size={26} stroke="#1a0a00" sw={2.2} />
      </button>
    </>
  );
};

const TaskList = ({ tasks, openTask, toggleTask, deleteTask, openCreate }) => {
  const [filter, setFilter] = React.useState('all');
  const filtered = tasks.filter(t => {
    if (filter === 'pending') return !t.done;
    if (filter === 'done') return t.done;
    if (filter === 'high') return t.priority === 'high';
    return true;
  });
  // group by project
  const byProject = filtered.reduce((acc, t) => {
    (acc[t.project] = acc[t.project] || []).push(t); return acc;
  }, {});

  return (
    <>
      <div style={{ flex: 1, overflowY: 'auto' }}>
        <div style={{ padding: '64px 20px 12px' }}>
          <div style={{ fontSize: 28, fontWeight: 600, letterSpacing: '-0.025em' }}>Todas las tareas</div>
          <div style={{ fontSize: 13, color: 'var(--k-text-2)', marginTop: 4 }}>{tasks.length} en total · desliza para acción rápida</div>
        </div>

        <div style={{ padding: '0 20px 16px', display: 'flex', gap: 8, overflowX: 'auto' }}>
          {[
            { k: 'all', l: 'Todas' },
            { k: 'pending', l: 'Pendientes' },
            { k: 'done', l: 'Completadas' },
            { k: 'high', l: 'Alta prioridad' },
          ].map(f => (
            <button key={f.k} onClick={() => setFilter(f.k)} style={{
              padding: '8px 14px', borderRadius: 99,
              background: filter === f.k ? 'var(--k-text)' : 'var(--k-bg-2)',
              color: filter === f.k ? 'var(--k-bg)' : 'var(--k-text-2)',
              border: '1px solid ' + (filter === f.k ? 'var(--k-text)' : 'var(--k-line)'),
              fontSize: 12, fontWeight: 500, cursor: 'pointer', whiteSpace: 'nowrap',
            }}>{f.l}</button>
          ))}
        </div>

        {Object.entries(byProject).map(([proj, items]) => (
          <div key={proj} style={{ marginBottom: 20 }}>
            <div style={{ padding: '4px 20px 8px' }} className="mono">
              <span style={{ fontSize: 10, color: 'var(--k-text-3)', letterSpacing: '0.1em' }}>{proj.toUpperCase()} · {items.length}</span>
            </div>
            <div style={{ padding: '0 20px', display: 'flex', flexDirection: 'column', gap: 8 }}>
              {items.map(t => <TaskRow key={t.id} task={t} onToggle={toggleTask} onClick={openTask} onDelete={deleteTask} />)}
            </div>
          </div>
        ))}
        <div style={{ height: 100 }} />
      </div>
      <button onClick={openCreate} style={{
        position: 'absolute', bottom: 100, right: 20, width: 56, height: 56, borderRadius: 18,
        background: 'var(--k-accent)', border: 0, cursor: 'pointer',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        boxShadow: '0 10px 30px rgba(251,146,60,0.35), 0 0 0 1px rgba(251,146,60,0.5)',
        zIndex: 10,
      }}>
        <IconPlus size={26} stroke="#1a0a00" sw={2.2} />
      </button>
    </>
  );
};

const CreateTask = ({ onCancel, onSave }) => {
  const [title, setTitle] = React.useState('');
  const [desc, setDesc] = React.useState('');
  const [priority, setPriority] = React.useState('med');
  const [energy, setEnergy] = React.useState(3);
  const [due, setDue] = React.useState('Hoy');
  const [error, setError] = React.useState('');

  const save = () => {
    if (!title.trim()) { setError('El título es obligatorio'); return; }
    onSave({ title: title.trim(), desc, priority, energy, due, estimate: 30 });
  };

  return (
    <div className="k-app" style={{ background: 'var(--k-bg)' }}>
      <div style={{ height: 60, flexShrink: 0 }} />
      <div style={{ padding: '12px 20px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexShrink: 0 }}>
        <button className="k-btn k-btn-text" style={{ height: 36, padding: 0, fontSize: 15 }} onClick={onCancel}>Cancelar</button>
        <div style={{ fontSize: 16, fontWeight: 600 }}>Nueva tarea</div>
        <button className="k-btn" style={{ height: 36, padding: '0 14px', fontSize: 14, fontWeight: 600,
          background: title.trim() ? 'var(--k-accent)' : 'var(--k-bg-3)',
          color: title.trim() ? '#1a0a00' : 'var(--k-text-3)' }} onClick={save}>Guardar</button>
      </div>

      <div style={{ flex: 1, overflowY: 'auto', padding: '20px' }}>
        <div style={{ marginBottom: 8 }}>
          <input className="k-input" style={{
            background: 'transparent', border: 0, padding: '8px 0',
            fontSize: 22, fontWeight: 500, letterSpacing: '-0.02em',
            borderRadius: 0,
          }} placeholder="¿Qué tienes en mente?"
            value={title} onChange={(e) => { setTitle(e.target.value); setError(''); }} autoFocus />
          {error && (
            <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginTop: 8, color: 'var(--k-danger)', fontSize: 12 }}>
              <IconAlert size={12} stroke="var(--k-danger)" />
              {error}
            </div>
          )}
        </div>

        <textarea className="k-input" placeholder="Descripción (opcional)" rows={3}
          value={desc} onChange={(e) => setDesc(e.target.value)}
          style={{ resize: 'none', fontFamily: 'var(--font-sans)', marginBottom: 24 }} />

        <div style={{ marginBottom: 20 }}>
          <span className="k-input-label">Prioridad</span>
          <div style={{ display: 'flex', gap: 8 }}>
            {['high','med','low'].map(p => {
              const c = PRIORITY_COLOR[p];
              const active = priority === p;
              return (
                <button key={p} onClick={() => setPriority(p)} style={{
                  flex: 1, padding: '14px 12px', borderRadius: 12,
                  background: active ? c.bg : 'var(--k-bg-2)',
                  border: '1px solid ' + (active ? c.dot : 'var(--k-line)'),
                  color: active ? c.fg : 'var(--k-text-2)',
                  display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6,
                  cursor: 'pointer', fontFamily: 'var(--font-sans)',
                }}>
                  <div style={{ width: 8, height: 8, borderRadius: '50%', background: c.dot }} />
                  <span style={{ fontSize: 12, fontWeight: 500 }}>{PRIORITY_LABEL[p]}</span>
                </button>
              );
            })}
          </div>
        </div>

        <div style={{ marginBottom: 20 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 12 }}>
            <span className="k-input-label" style={{ marginBottom: 0 }}>Nivel de energía</span>
            <span className="mono tnum" style={{ fontSize: 18, fontWeight: 500, color: 'var(--k-accent)' }}>{energy}/5</span>
          </div>
          <input type="range" min={1} max={5} step={1} value={energy}
            onChange={(e) => setEnergy(+e.target.value)}
            style={{ width: '100%', accentColor: 'var(--k-accent)' }} />
          <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 4, fontSize: 11, color: 'var(--k-text-3)' }}>
            <span>Mínima</span><span>Ligera</span><span>Media</span><span>Alta</span><span>Extrema</span>
          </div>
        </div>

        <div style={{ marginBottom: 20 }}>
          <span className="k-input-label">Fecha</span>
          <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
            {['Hoy','Mañana','Esta semana','Sin fecha'].map(d => (
              <button key={d} onClick={() => setDue(d)} style={{
                padding: '10px 14px', borderRadius: 10,
                background: due === d ? 'var(--k-bg-3)' : 'var(--k-bg-2)',
                border: '1px solid ' + (due === d ? 'var(--k-line-2)' : 'var(--k-line)'),
                color: due === d ? 'var(--k-text)' : 'var(--k-text-2)',
                fontSize: 13, cursor: 'pointer', fontFamily: 'var(--font-sans)',
              }}>{d}</button>
            ))}
          </div>
        </div>

        <div style={{ padding: 14, background: 'var(--k-bg-2)', border: '1px solid var(--k-line)', borderRadius: 12, display: 'flex', alignItems: 'center', gap: 10 }}>
          <IconCloud size={16} stroke="var(--k-text-3)" />
          <div style={{ flex: 1, fontSize: 12, color: 'var(--k-text-3)' }}>Se guarda primero en local (Realm) y se sincroniza al detectar conexión.</div>
        </div>
      </div>
    </div>
  );
};

const TaskDetail = ({ task, onClose, onToggle, onDelete }) => {
  if (!task) return null;
  return (
    <div className="k-app">
      <div style={{ height: 60, flexShrink: 0 }} />
      <div style={{ padding: '12px 12px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexShrink: 0 }}>
        <button onClick={onClose} style={{ width: 40, height: 40, borderRadius: 12, background: 'var(--k-bg-2)', border: '1px solid var(--k-line)', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}>
          <IconClose size={18} stroke="var(--k-text)" />
        </button>
        <div style={{ display: 'flex', gap: 8 }}>
          <button style={{ width: 40, height: 40, borderRadius: 12, background: 'var(--k-bg-2)', border: '1px solid var(--k-line)', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}>
            <IconEdit size={16} stroke="var(--k-text-2)" />
          </button>
          <button onClick={() => { onDelete(task.id); onClose(); }} style={{ width: 40, height: 40, borderRadius: 12, background: 'var(--k-bg-2)', border: '1px solid var(--k-line)', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}>
            <IconTrash size={16} stroke="var(--k-danger)" />
          </button>
        </div>
      </div>

      <div style={{ flex: 1, overflowY: 'auto', padding: '8px 24px' }}>
        <div className="mono" style={{ fontSize: 11, color: 'var(--k-text-3)', letterSpacing: '0.1em', marginBottom: 12 }}>
          {task.project.toUpperCase()}
        </div>
        <div style={{ fontSize: 26, fontWeight: 600, letterSpacing: '-0.02em', lineHeight: 1.25, marginBottom: 16 }}>
          {task.title}
        </div>
        {task.desc && <div style={{ fontSize: 14, color: 'var(--k-text-2)', lineHeight: 1.55, marginBottom: 24 }}>{task.desc}</div>}

        <div className="k-card" style={{ padding: 4, marginBottom: 16 }}>
          {[
            { l: 'Prioridad', v: <PriorityChip p={task.priority} /> },
            { l: 'Energía', v: <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}><EnergyDots value={task.energy} size={6} /><span className="mono" style={{ fontSize: 12, color: 'var(--k-text-2)' }}>{task.energy}/5</span></div> },
            { l: 'Estimación', v: <span className="mono" style={{ fontSize: 13, color: 'var(--k-text-2)' }}>{task.estimate} min</span> },
            { l: 'Fecha', v: <span style={{ fontSize: 13, color: 'var(--k-text-2)' }}>{task.due}</span> },
            { l: 'Estado', v: <span style={{ fontSize: 12, color: task.isSynced ? 'var(--k-success)' : 'var(--k-warn)' }} className="mono">{task.isSynced ? '✓ SINCRONIZADO' : '◐ LOCAL'}</span> },
          ].map((r, i, arr) => (
            <div key={i} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '14px 14px',
              borderBottom: i < arr.length - 1 ? '1px solid var(--k-line)' : 0 }}>
              <span style={{ fontSize: 13, color: 'var(--k-text-3)' }}>{r.l}</span>
              {r.v}
            </div>
          ))}
        </div>

        <button className="k-btn k-btn-primary" onClick={() => onToggle(task.id)} style={{ marginTop: 8 }}>
          {task.done ? 'Marcar como pendiente' : <>Marcar como completada <IconCheck size={18} /></>}
        </button>
        <button className="k-btn k-btn-ghost" style={{ marginTop: 10 }}>
          <IconFocus size={16} stroke="var(--k-text)" /> Iniciar Modo Enfoque
        </button>
      </div>
    </div>
  );
};

Object.assign(window, { Dashboard, TaskList, CreateTask, TaskDetail, TabBar, TaskRow, PriorityChip, EnergyDots });
