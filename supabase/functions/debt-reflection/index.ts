const GEMINI_STREAM_URL =
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:streamGenerateContent";

const FALLBACK =
  "La deuda no es condena, sino medida de lo que aún puedes dar. " +
  "Epicteto diría: solo controlas tu esfuerzo presente, no el pasado acumulado. " +
  "Hoy, completa una tarea pequeña. Un paso honesto vale más que mil promesas.";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

function buildPrompt(data: {
  total_debt_minutes: number;
  streak_days: number;
  sessions_completed: number;
  recent_abandons: number;
}): string {
  return `Eres un consejero estoico inspirado en Marco Aurelio y Epicteto. El usuario tiene:
- Deuda productiva: ${data.total_debt_minutes} minutos
- Racha actual: ${data.streak_days} días sin abandonar
- Sesiones completadas: ${data.sessions_completed}
- Abandonos recientes: ${data.recent_abandons}

Genera una reflexión breve (2-3 párrafos, máx 200 palabras) que:
1. Reconozca su esfuerzo sin ser condescendiente
2. Reencuadre la deuda como oportunidad de crecimiento (Epicteto: lo que está en tu control)
3. Termine con una acción concreta para hoy

Tono: Directo, sin emojis, inspirador pero realista. Como si Marco Aurelio te hablara.`;
}

const sseHeaders = {
  ...corsHeaders,
  "Content-Type": "text/event-stream",
  "Cache-Control": "no-cache",
};

function fallbackStreamResponse(): Response {
  const encoder = new TextEncoder();
  const stream = new ReadableStream<Uint8Array>({
    start(controller) {
      controller.enqueue(
        encoder.encode(`data: ${JSON.stringify({ text: FALLBACK })}\n\n`),
      );
      controller.close();
    },
  });
  return new Response(stream, { headers: sseHeaders });
}

export async function handler(req: Request): Promise<Response> {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  if (!req.headers.get("Authorization")) {
    return new Response("Unauthorized", { status: 401 });
  }

  const body = await req.json();
  const apiKey = Deno.env.get("GEMINI_API_KEY") ?? "";

  if (!apiKey) return fallbackStreamResponse();

  const stream = new ReadableStream<Uint8Array>({
    async start(controller) {
      const encoder = new TextEncoder();
      try {
        const res = await fetch(
          `${GEMINI_STREAM_URL}?key=${apiKey}&alt=sse`,
          {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
              contents: [{ parts: [{ text: buildPrompt(body) }] }],
            }),
          },
        );

        const reader = res.body!.getReader();
        const decoder = new TextDecoder();

        while (true) {
          const { done, value } = await reader.read();
          if (done) break;

          const chunk = decoder.decode(value);
          for (const line of chunk.split("\n")) {
            if (!line.startsWith("data: ")) continue;
            try {
              const parsed = JSON.parse(line.slice(6));
              const text = parsed.candidates?.[0]?.content?.parts?.[0]?.text;
              if (text) {
                controller.enqueue(
                  encoder.encode(`data: ${JSON.stringify({ text })}\n\n`),
                );
              }
            } catch { /* skip malformed lines */ }
          }
        }
      } catch {
        controller.enqueue(
          encoder.encode(`data: ${JSON.stringify({ text: FALLBACK })}\n\n`),
        );
      }
      controller.close();
    },
  });

  return new Response(stream, { headers: sseHeaders });
}

Deno.serve(handler);
