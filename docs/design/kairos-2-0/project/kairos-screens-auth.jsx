// kairos-screens-auth.jsx — Splash, Onboarding, Login

const Splash = () => (
  <div className="k-app" style={{ alignItems: 'center', justifyContent: 'center' }}>
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 24, animation: 'k-fade-in .4s ease both' }}>
      <div style={{ position: 'relative', width: 80, height: 80 }}>
        <div style={{ position: 'absolute', inset: 0, borderRadius: '50%', border: '1px solid rgba(255,255,255,0.08)' }} />
        <div style={{ position: 'absolute', inset: 0, borderRadius: '50%', borderTop: '1.5px solid var(--k-accent)', borderRight: '1.5px solid transparent', borderBottom: '1.5px solid transparent', borderLeft: '1.5px solid transparent', animation: 'k-spin 1.4s linear infinite' }} />
        <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <IconLogo size={36} color="#fafafa" />
        </div>
      </div>
      <div style={{ textAlign: 'center' }}>
        <div style={{ fontSize: 22, fontWeight: 600, letterSpacing: '-0.02em' }}>KAIROS</div>
        <div className="mono" style={{ fontSize: 11, color: 'var(--k-text-3)', marginTop: 4, letterSpacing: '0.1em' }}>v2.0.1 · INICIANDO</div>
      </div>
    </div>
    <div style={{ position: 'absolute', bottom: 60, fontSize: 12, color: 'var(--k-text-4)' }} className="mono">
      realm · syncing local store…
    </div>
  </div>
);

const OnboardingSlide = ({ kicker, title, body, illust }) => (
  <div style={{ flex: 1, display: 'flex', flexDirection: 'column', padding: '32px 28px 0' }}>
    <div style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
      {illust}
    </div>
    <div style={{ paddingBottom: 16 }}>
      <div className="mono" style={{ fontSize: 11, color: 'var(--k-accent)', letterSpacing: '0.12em', marginBottom: 12 }}>{kicker}</div>
      <div style={{ fontSize: 28, fontWeight: 600, letterSpacing: '-0.025em', lineHeight: 1.15, marginBottom: 12 }}>{title}</div>
      <div style={{ fontSize: 15, color: 'var(--k-text-2)', lineHeight: 1.5, textWrap: 'pretty' }}>{body}</div>
    </div>
  </div>
);

const Onboarding = ({ onDone }) => {
  const [step, setStep] = React.useState(0);
  const slides = [
    {
      kicker: '01 / OFFLINE-FIRST',
      title: 'Tu agenda, siempre disponible',
      body: 'Realm guarda cada tarea localmente. No depende de la red: sigue funcionando en el metro, en un avión o en zonas sin cobertura.',
      illust: (
        <div style={{ position: 'relative', width: 220, height: 220 }}>
          <div style={{ position: 'absolute', inset: 0, border: '1px dashed rgba(255,255,255,0.12)', borderRadius: '50%' }} />
          <div style={{ position: 'absolute', inset: 30, border: '1px solid rgba(255,255,255,0.08)', borderRadius: '50%' }} />
          <div style={{ position: 'absolute', inset: 70, background: 'var(--k-bg-2)', border: '1px solid var(--k-line-2)', borderRadius: 18, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <IconCloudOff size={36} stroke="var(--k-accent)" sw={1.4} />
          </div>
          <div style={{ position: 'absolute', top: 14, left: 14, fontSize: 10, color: 'var(--k-text-3)' }} className="mono">REALM.DB</div>
          <div style={{ position: 'absolute', bottom: 14, right: 14, fontSize: 10, color: 'var(--k-text-3)' }} className="mono">LOCAL-ONLY</div>
        </div>
      ),
    },
    {
      kicker: '02 / SMART SCHEDULING',
      title: 'Optimiza tu día con un toque',
      body: 'Un algoritmo heurístico reordena tus tareas según prioridad, energía y deadlines. Tú decides; KAIROS sugiere.',
      illust: (
        <div style={{ width: 220, display: 'flex', flexDirection: 'column', gap: 8 }}>
          {[
            { t: 'Tarea de alta prioridad', e: 5, c: 'var(--k-accent)' },
            { t: 'Bloque de enfoque', e: 4, c: 'var(--k-text-2)' },
            { t: 'Comunicación rápida', e: 2, c: 'var(--k-text-3)' },
            { t: 'Ejercicio físico', e: 3, c: 'var(--k-text-3)' },
          ].map((r, i) => (
            <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '12px 14px', background: 'var(--k-bg-2)', border: '1px solid var(--k-line)', borderRadius: 12, opacity: i === 0 ? 1 : 0.7 - i * 0.1 }}>
              <div style={{ width: 6, height: 6, borderRadius: '50%', background: r.c }} />
              <div style={{ flex: 1, fontSize: 12, color: 'var(--k-text-2)' }}>{r.t}</div>
              <div className="mono" style={{ fontSize: 10, color: 'var(--k-text-3)' }}>E{r.e}</div>
            </div>
          ))}
        </div>
      ),
    },
    {
      kicker: '03 / DEEP WORK',
      title: 'Modo enfoque sin distracciones',
      body: 'Sesiones de trabajo profundo con cronómetro, gamificación y bloqueo visual. Una tarea a la vez, hasta el final.',
      illust: (
        <div style={{ position: 'relative', width: 220, height: 220, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <svg width="220" height="220" viewBox="0 0 220 220">
            <circle cx="110" cy="110" r="92" fill="none" stroke="rgba(255,255,255,0.06)" strokeWidth="1" />
            <circle cx="110" cy="110" r="92" fill="none" stroke="var(--k-accent)" strokeWidth="2"
              strokeDasharray="578" strokeDashoffset="180" transform="rotate(-90 110 110)" strokeLinecap="round" />
          </svg>
          <div style={{ position: 'absolute', textAlign: 'center' }}>
            <div className="mono" style={{ fontSize: 36, fontWeight: 500, letterSpacing: '-0.02em' }}>17:42</div>
            <div className="mono" style={{ fontSize: 10, color: 'var(--k-text-3)', letterSpacing: '0.1em', marginTop: 4 }}>ENFOQUE · POMODORO</div>
          </div>
        </div>
      ),
    },
  ];

  return (
    <div className="k-app">
      <div style={{ height: 60, flexShrink: 0 }} />
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '0 24px', height: 44, flexShrink: 0 }}>
        <div style={{ display: 'flex', gap: 6 }}>
          {slides.map((_, i) => (
            <div key={i} style={{ width: i === step ? 18 : 6, height: 3, borderRadius: 2, background: i <= step ? 'var(--k-accent)' : 'var(--k-line-2)', transition: 'all .25s ease' }} />
          ))}
        </div>
        <button className="k-btn k-btn-text" style={{ height: 32, padding: '0 4px', fontSize: 13 }} onClick={onDone}>Saltar</button>
      </div>
      <div key={step} style={{ flex: 1, display: 'flex', flexDirection: 'column', animation: 'k-fade-up .35s cubic-bezier(.2,.7,.3,1) both' }}>
        <OnboardingSlide {...slides[step]} />
      </div>
      <div style={{ padding: '20px 24px 40px', flexShrink: 0 }}>
        <button className="k-btn k-btn-primary" onClick={() => step < slides.length - 1 ? setStep(step + 1) : onDone()}>
          {step < slides.length - 1 ? 'Continuar' : 'Empezar'}
          <IconArrowR size={18} />
        </button>
      </div>
    </div>
  );
};

const Login = ({ onLogin }) => {
  const [email, setEmail] = React.useState('ismael@kairos.app');
  const [pass, setPass] = React.useState('••••••••••');
  const [loading, setLoading] = React.useState(false);

  const submit = () => {
    setLoading(true);
    setTimeout(() => { setLoading(false); onLogin(); }, 900);
  };

  return (
    <div className="k-app">
      <div style={{ height: 60, flexShrink: 0 }} />
      <div style={{ flex: 1, padding: '32px 28px', display: 'flex', flexDirection: 'column' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 48 }}>
          <IconLogo size={26} color="#fafafa" />
          <div style={{ fontSize: 18, fontWeight: 600, letterSpacing: '-0.01em' }}>KAIROS</div>
          <div style={{ flex: 1 }} />
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '4px 10px', background: 'rgba(74,222,128,0.10)', borderRadius: 99, border: '1px solid rgba(74,222,128,0.18)' }}>
            <div style={{ width: 6, height: 6, borderRadius: '50%', background: 'var(--k-success)', animation: 'k-pulse 2s ease-in-out infinite' }} />
            <span className="mono" style={{ fontSize: 10, color: 'var(--k-success)', letterSpacing: '0.06em' }}>ONLINE</span>
          </div>
        </div>

        <div style={{ marginBottom: 36 }}>
          <div style={{ fontSize: 28, fontWeight: 600, letterSpacing: '-0.025em', lineHeight: 1.2, marginBottom: 8 }}>Bienvenido de vuelta</div>
          <div style={{ fontSize: 15, color: 'var(--k-text-2)' }}>Sincroniza tus tareas con la nube</div>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
          <div>
            <span className="k-input-label">Correo</span>
            <input className="k-input" value={email} onChange={(e) => setEmail(e.target.value)} type="email" placeholder="tu@correo.com" />
          </div>
          <div>
            <span className="k-input-label">Contraseña</span>
            <input className="k-input" value={pass} onChange={(e) => setPass(e.target.value)} type="password" />
          </div>
          <div style={{ textAlign: 'right' }}>
            <button className="k-btn k-btn-text" style={{ height: 28, padding: 0, fontSize: 13, color: 'var(--k-accent)' }}>¿Olvidaste tu contraseña?</button>
          </div>
        </div>

        <div style={{ flex: 1 }} />

        <div style={{ display: 'flex', flexDirection: 'column', gap: 12, paddingBottom: 24 }}>
          <button className="k-btn k-btn-primary" onClick={submit} disabled={loading}>
            {loading ? (
              <>
                <div style={{ width: 14, height: 14, borderRadius: '50%', border: '1.5px solid rgba(26,10,0,0.3)', borderTopColor: '#1a0a00', animation: 'k-spin .7s linear infinite' }} />
                Sincronizando…
              </>
            ) : (
              <>Iniciar sesión y sincronizar <IconArrowR size={18} /></>
            )}
          </button>
          <button className="k-btn k-btn-ghost" onClick={onLogin}>Continuar sin sincronizar</button>
          <div style={{ textAlign: 'center', fontSize: 12, color: 'var(--k-text-3)', marginTop: 4 }}>
            ¿Aún no tienes cuenta? <span style={{ color: 'var(--k-text)', fontWeight: 500 }}>Crear una</span>
          </div>
        </div>
      </div>
    </div>
  );
};

Object.assign(window, { Splash, Onboarding, Login });
