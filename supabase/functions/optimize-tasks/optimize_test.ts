import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";

const mockTasks = [
  { id: "1", title: "Tarea A", priority: 2, energy: 3, estimated_minutes: 30 },
  { id: "2", title: "Tarea B", priority: 1, energy: 1, estimated_minutes: 15 },
];

const geminiResponse = {
  candidates: [{
    content: {
      parts: [{
        text: JSON.stringify({
          optimized: [mockTasks[1], mockTasks[0]],
          explanation: "Tarea B primero por menor energía requerida.",
        }),
      }],
    },
  }],
};

globalThis.fetch = async (_url: string) =>
  new Response(JSON.stringify(geminiResponse), {
    headers: { "Content-Type": "application/json" },
  });

const { handler } = await import("./index.ts");

Deno.test("optimize-tasks: reordena tareas y devuelve explanation", async () => {
  const req = new Request("http://localhost/optimize-tasks", {
    method: "POST",
    headers: {
      "Authorization": "Bearer test-jwt",
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ tasks: mockTasks }),
  });

  const res = await handler(req);
  assertEquals(res.status, 200);

  const body = await res.json();
  assertEquals(Array.isArray(body.optimized), true);
  assertEquals(typeof body.explanation, "string");
  assertEquals(body.optimized.length, 2);
});

Deno.test("optimize-tasks: devuelve fallback si Gemini falla", async () => {
  globalThis.fetch = async () => {
    throw new Error("Network error");
  };

  const req = new Request("http://localhost/optimize-tasks", {
    method: "POST",
    headers: {
      "Authorization": "Bearer test-jwt",
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ tasks: mockTasks }),
  });

  const res = await handler(req);
  assertEquals(res.status, 200);
  const body = await res.json();
  assertEquals(Array.isArray(body.optimized), true);
  assertEquals(typeof body.explanation, "string");
});
