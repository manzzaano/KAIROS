import json
import logging
from typing import AsyncGenerator, List

import google.generativeai as genai

logger = logging.getLogger(__name__)

SYSTEM_PROMPT = (
    "Reorganiza estas tareas por prioridad cognitiva. "
    "Considera urgencia + energía requerida + dependencias."
)

_FALLBACK_REFLECTION = (
    "La deuda no es condena, sino medida de lo que aún puedes dar. "
    "Epicteto diría: solo controlas tu esfuerzo presente, no el pasado acumulado. "
    "Hoy, completa una tarea pequeña. Un paso honesto vale más que mil promesas."
)

_DEBT_PROMPT = """\
Eres un consejero estoico inspirado en Marco Aurelio y Epicteto. El usuario tiene:
- Deuda productiva: {total_debt_minutes} minutos
- Racha actual: {streak_days} días sin abandonar
- Sesiones completadas: {sessions_completed}
- Abandonos recientes: {recent_abandons}

Genera una reflexión breve (2-3 párrafos, máx 200 palabras) que:
1. Reconozca su esfuerzo sin ser condescendiente
2. Reencuadre la deuda como oportunidad de crecimiento (Epicteto: lo que está en tu control)
3. Termine con una acción concreta para hoy

Tono: Directo, sin emojis, inspirador pero realista. Como si Marco Aurelio te hablara.\
"""


class GeminiOptimizer:
    def __init__(self, api_key: str):
        self.api_key = api_key
        genai.configure(api_key=api_key)
        self.model = genai.GenerativeModel("gemini-pro")

    async def optimize_tasks(self, tasks: List[dict]) -> dict:
        logger.debug("optimize_tasks called with %d tasks", len(tasks))

        prompt = (
            f"{SYSTEM_PROMPT}\n\n"
            f"Tareas (JSON):\n{json.dumps(tasks, ensure_ascii=False)}\n\n"
            "Responde EXCLUSIVAMENTE con un JSON válido con esta forma:\n"
            '{"optimized": [<tareas reordenadas con los mismos campos>], '
            '"explanation": "<breve explicación en español de por qué se reorganizó>"}'
        )

        try:
            response = await self.model.generate_content_async(prompt)
            raw = response.text.strip()
            logger.debug("Gemini raw response: %s", raw)

            if raw.startswith("```"):
                raw = raw.strip("`")
                if raw.lower().startswith("json"):
                    raw = raw[4:]
                raw = raw.strip()

            parsed = json.loads(raw)

            if "optimized" not in parsed or "explanation" not in parsed:
                raise ValueError("Gemini response missing required keys")

            logger.info("optimize_tasks succeeded with %d tasks", len(parsed["optimized"]))
            return parsed

        except Exception as exc:
            logger.exception("Gemini optimization failed: %s", exc)
            return {
                "optimized": tasks,
                "explanation": (
                    f"Aviso: no se pudo optimizar vía Gemini ({exc}). "
                    "Se devuelven las tareas originales sin reordenar."
                ),
            }


class GeminiService:
    def __init__(self, api_key: str):
        self._ready = bool(api_key)
        if self._ready:
            genai.configure(api_key=api_key)
            self.model = genai.GenerativeModel("gemini-1.5-flash")

    async def generate_debt_reflection(
        self,
        total_debt_minutes: int,
        streak_days: int,
        sessions_completed: int,
        recent_abandons: int,
    ) -> AsyncGenerator[str, None]:
        if not self._ready:
            yield _FALLBACK_REFLECTION
            return

        prompt = _DEBT_PROMPT.format(
            total_debt_minutes=total_debt_minutes,
            streak_days=streak_days,
            sessions_completed=sessions_completed,
            recent_abandons=recent_abandons,
        )

        try:
            response = await self.model.generate_content_async(prompt, stream=True)
            async for chunk in response:
                if chunk.text:
                    yield chunk.text
        except Exception as exc:
            logger.exception("GeminiService reflection failed: %s", exc)
            yield _FALLBACK_REFLECTION

    @staticmethod
    def analyze_debt_severity(
        total_debt_minutes: int,
        free_time_minutes: int,
    ) -> dict:
        ratio = total_debt_minutes / max(free_time_minutes, 1)
        if ratio > 2:
            return {"level": "critical", "color": "error600", "message": "Deuda crítica"}
        elif ratio > 1:
            return {"level": "warning", "color": "neutral400", "message": "Deuda considerable"}
        return {"level": "healthy", "color": "neutral50", "message": "En balance"}
