import json
import logging
from typing import List

import google.generativeai as genai

logger = logging.getLogger(__name__)

SYSTEM_PROMPT = (
    "Reorganiza estas tareas por prioridad cognitiva. "
    "Considera urgencia + energía requerida + dependencias."
)


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
