---
description: Ejecuta el pipeline completo: Planificador → Arquitecto → Constructor → Auditor
agent: director
---

Ejecuta el pipeline multiagente completo para esta tarea: **$ARGUMENTS**

Sigue el protocolo de 4 etapas de tu configuración, sin omitir ninguna:

1. `planificador` → `.opencode/pipeline/<slug>/01-plan.md`
2. `arquitecto` → `.opencode/pipeline/<slug>/02-arquitectura.md`
3. `constructor` → `.opencode/pipeline/<slug>/03-construccion.md`
4. `auditor` → `.opencode/pipeline/<slug>/04-auditoria.md`

Lanza los subagentes uno por uno, espera el informe de cada uno y verifica que su artefacto exista antes de pasar al siguiente. Al terminar, entrega el resumen final en español con el veredicto del auditor.
