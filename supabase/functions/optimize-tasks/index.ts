const GEMINI_URL =
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

function fallbackResponse(tasks: unknown[]) {
  return Response.json(
    {
      optimized: tasks,
      explanation:
        "Aviso: no se pudo optimizar vía Gemini. Se devuelven las tareas sin reordenar.",
    },
    { headers: corsHeaders },
  );
}

export async function handler(req: Request): Promise<Response> {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  if (!req.headers.get("Authorization")) {
    return new Response("Unauthorized", { status: 401 });
  }

  const { tasks } = await req.json();
  const apiKey = Deno.env.get("GEMINI_API_KEY") ?? "";

  if (!apiKey) return fallbackResponse(tasks);

  const prompt =
    `Reorganiza estas tareas por prioridad cognitiva. Considera urgencia + energía requerida + dependencias.\n\nTareas (JSON):\n${
      JSON.stringify(tasks)
    }\n\nResponde EXCLUSIVAMENTE con un JSON válido:\n{"optimized": [<tareas reordenadas>], "explanation": "<explicación breve en español>"}`;

  try {
    const res = await fetch(`${GEMINI_URL}?key=${apiKey}`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ contents: [{ parts: [{ text: prompt }] }] }),
    });
    const data = await res.json();
    const raw = (data.candidates[0].content.parts[0].text as string).trim();
    const cleaned = raw.replace(/^```json?\n?/, "").replace(/\n?```$/, "").trim();
    const parsed = JSON.parse(cleaned);

    if (!parsed.optimized || !parsed.explanation) throw new Error("Bad format");

    return Response.json(parsed, { headers: corsHeaders });
  } catch {
    return fallbackResponse(tasks);
  }
}

Deno.serve(handler);
