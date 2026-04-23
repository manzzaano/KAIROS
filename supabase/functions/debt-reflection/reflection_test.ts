import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";

const FALLBACK_TEXT = "La deuda no es condena";

const encoder = new TextEncoder();
const sseChunk = `data: ${
  JSON.stringify({
    candidates: [{ content: { parts: [{ text: "Epicteto diría: " }] } }],
  })
}\n\n`;

globalThis.fetch = async () => {
  const stream = new ReadableStream({
    start(controller) {
      controller.enqueue(encoder.encode(sseChunk));
      controller.close();
    },
  });
  return new Response(stream, {
    headers: { "Content-Type": "text/event-stream" },
  });
};

const { handler } = await import("./index.ts");

Deno.test("debt-reflection: responde con Content-Type SSE", async () => {
  const req = new Request("http://localhost/debt-reflection", {
    method: "POST",
    headers: {
      "Authorization": "Bearer test-jwt",
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      total_debt_minutes: 120,
      streak_days: 3,
      sessions_completed: 10,
      recent_abandons: 1,
    }),
  });

  const res = await handler(req);
  assertEquals(res.status, 200);
  assertEquals(
    res.headers.get("Content-Type")?.includes("text/event-stream"),
    true,
  );

  const text = await res.text();
  assertEquals(text.length > 0, true);
});

Deno.test("debt-reflection: fallback si Gemini falla", async () => {
  globalThis.fetch = async () => {
    throw new Error("Network error");
  };

  const req = new Request("http://localhost/debt-reflection", {
    method: "POST",
    headers: {
      "Authorization": "Bearer test-jwt",
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      total_debt_minutes: 60,
      streak_days: 0,
      sessions_completed: 5,
      recent_abandons: 2,
    }),
  });

  const res = await handler(req);
  assertEquals(res.status, 200);
  const text = await res.text();
  assertEquals(text.includes(FALLBACK_TEXT), true);
});
