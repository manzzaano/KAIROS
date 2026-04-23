-- ─── TABLAS ─────────────────────────────────────────────────────────────────

CREATE TABLE tasks (
  id                uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title             text        NOT NULL,
  priority          int         NOT NULL DEFAULT 1,
  energy            int         NOT NULL DEFAULT 3,
  estimated_minutes int         NOT NULL DEFAULT 0,
  completed         boolean     NOT NULL DEFAULT false,
  completed_at      timestamptz,
  abandoned         boolean     NOT NULL DEFAULT false,
  abandoned_at      timestamptz,
  latitude          float8,
  longitude         float8,
  created_at        timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX ix_tasks_user_created ON tasks (user_id, created_at DESC);

CREATE TABLE productivity_debt (
  id                  uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id             uuid        UNIQUE NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  total_debt_minutes  int         NOT NULL DEFAULT 0,
  free_time_minutes   int         NOT NULL DEFAULT 0,
  last_updated        timestamptz NOT NULL DEFAULT now(),
  notes               text
);

-- ─── RLS ────────────────────────────────────────────────────────────────────

ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE productivity_debt ENABLE ROW LEVEL SECURITY;

CREATE POLICY "tasks_user_isolation" ON tasks
  FOR ALL USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "debt_user_isolation" ON productivity_debt
  FOR ALL USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ─── FUNCIONES ──────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION add_free_time(p_user_id uuid, p_minutes int)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO productivity_debt (user_id, free_time_minutes, last_updated)
  VALUES (p_user_id, p_minutes, now())
  ON CONFLICT (user_id) DO UPDATE
    SET free_time_minutes = productivity_debt.free_time_minutes + p_minutes,
        last_updated = now();
END;
$$;

CREATE OR REPLACE FUNCTION add_debt(p_user_id uuid, p_minutes int)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO productivity_debt (user_id, total_debt_minutes, last_updated)
  VALUES (p_user_id, p_minutes, now())
  ON CONFLICT (user_id) DO UPDATE
    SET total_debt_minutes = productivity_debt.total_debt_minutes + p_minutes,
        last_updated = now();
END;
$$;

CREATE OR REPLACE FUNCTION pay_debt(p_user_id uuid, p_minutes int)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  UPDATE productivity_debt
  SET total_debt_minutes = GREATEST(0, total_debt_minutes - p_minutes),
      last_updated = now()
  WHERE user_id = p_user_id;
END;
$$;

CREATE OR REPLACE FUNCTION calculate_streak(p_user_id uuid)
RETURNS int LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_streak       int := 0;
  v_day          date;
  v_completed    int;
  v_abandoned    int;
BEGIN
  FOR i IN 0..364 LOOP
    v_day := CURRENT_DATE - i;

    SELECT COUNT(*) INTO v_abandoned
    FROM tasks
    WHERE user_id = p_user_id
      AND abandoned = true
      AND DATE(abandoned_at AT TIME ZONE 'UTC') = v_day;

    EXIT WHEN v_abandoned > 0;

    SELECT COUNT(*) INTO v_completed
    FROM tasks
    WHERE user_id = p_user_id
      AND completed = true
      AND DATE(completed_at AT TIME ZONE 'UTC') = v_day;

    IF v_completed > 0 THEN
      v_streak := v_streak + 1;
    ELSIF i > 0 THEN
      EXIT;
    END IF;
  END LOOP;
  RETURN v_streak;
END;
$$;
