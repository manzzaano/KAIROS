-- Crear tabla tasks en Supabase
-- Copiar y pegar en SQL Editor de Supabase https://app.supabase.com/project/mxhyuzucjygdjmamtcjq/sql/new

CREATE TABLE tasks (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  priority TEXT NOT NULL DEFAULT 'medium',
  energy INTEGER NOT NULL DEFAULT 3,
  project TEXT NOT NULL DEFAULT 'Personal',
  is_completed BOOLEAN NOT NULL DEFAULT false,
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  is_synced BOOLEAN NOT NULL DEFAULT true
);

-- Insertar datos de ejemplo
INSERT INTO tasks (id, title, priority, energy, project, is_completed, created_at) VALUES
('task-001', 'Completar documentación Flutter', 'high', 4, 'KAIROS', true, NOW()),
('task-002', 'Revisar código de autenticación', 'high', 3, 'KAIROS', true, NOW()),
('task-003', 'Integrar Realm offline-first', 'medium', 3, 'KAIROS', true, NOW()),
('task-004', 'Diseñar pantalla de stats', 'medium', 2, 'KAIROS', false, NOW()),
('task-005', 'Implementar Pomodoro timer', 'high', 4, 'KAIROS', true, NOW());

-- Habilitar RLS (opcional, para desarrollo usar anon key)
-- ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
