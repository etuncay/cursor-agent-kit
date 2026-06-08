#!/usr/bin/env python3
"""Unified prompt router + token-conscious context report for beforeSubmitPrompt."""
from __future__ import annotations

import json
import os
import re
import sys
from pathlib import Path
from typing import Any

ROOT = Path(os.environ.get("CURSOR_PROJECT_DIR", "."))
MANIFEST_PATH = ROOT / ".cursor/config/context-manifest.json"
REGISTRY_PATH = ROOT / ".cursor/skills/claude-skills-router/registry.json"
ACTIVE_CTX_PATH = ROOT / ".cursor/logs/.active-context.json"
BRIEF_DIR = ROOT / ".cursor/plans/_briefs"


def load_json(path: Path) -> dict[str, Any]:
    with path.open(encoding="utf-8") as f:
        return json.load(f)


def save_active_context(data: dict[str, Any]) -> None:
    ACTIVE_CTX_PATH.parent.mkdir(parents=True, exist_ok=True)
    with ACTIVE_CTX_PATH.open("w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


def load_active_context() -> dict[str, Any]:
    if not ACTIVE_CTX_PATH.is_file():
        return {"rules_read": [], "skills_read": [], "configs_read": []}
    try:
        with ACTIVE_CTX_PATH.open(encoding="utf-8") as f:
            return json.load(f)
    except (OSError, json.JSONDecodeError):
        return {"rules_read": [], "skills_read": [], "configs_read": []}


def attachment_paths(data: dict[str, Any]) -> list[str]:
    paths: list[str] = []
    for item in data.get("attachments") or []:
        if not isinstance(item, dict):
            continue
        fp = item.get("file_path") or item.get("path") or ""
        if fp:
            paths.append(fp)
    return paths


def ext_of(path: str) -> str:
    return Path(path).suffix.lstrip(".").lower()


def rule_active(rule: dict[str, Any], paths: list[str], intake_pending: bool) -> bool:
    mode = rule.get("mode")
    if mode == "always":
        return True
    if mode == "on_intake":
        return intake_pending
    if mode == "extensions":
        exts = {e.lower() for e in rule.get("extensions", [])}
        return any(ext_of(p) in exts for p in paths)
    if mode == "path_suffix":
        suffix = rule.get("suffix", "")
        contains = rule.get("path_contains", "")
        return any(p.endswith(suffix) and contains in p for p in paths)
    return False


def has(pattern: str, text: str) -> bool:
    return re.search(pattern, text, re.I) is not None


def match_registry(prompt: str) -> dict[str, Any] | None:
    if not REGISTRY_PATH.is_file():
        return None
    try:
        entries = load_json(REGISTRY_PATH).get("entries", [])
    except (OSError, KeyError, json.JSONDecodeError):
        return None
    entries.sort(key=lambda e: e.get("priority", 0), reverse=True)
    for entry in entries:
        pattern = entry.get("match", "")
        skill_path = entry.get("skillPath", "")
        if not pattern:
            continue
        full = ROOT / skill_path
        if not full.is_file():
            continue
        if re.search(pattern, prompt, re.I):
            return entry
    return None


def classify(prompt: str) -> dict[str, Any]:
    lower = prompt.lower()
    ctx_parts: list[str] = []
    intent = "DEFAULT"
    routed_skill: str | None = None
    intake_pending = False
    skip_intake = has(
        r"implement the plan|planı uygula|skip intake|intake atla|\bfix\b|bug|hata|refactor|düzelt|todo.*complete",
        lower,
    )
    feature_repair = has(
        r"make .* work|fix (the )?\w+ feature|broken|debug.*end-to-end|focus on|uçtan uca|çalışmıyor|kırık|modül.*(bozuk|çalışmıyor)|feature.*(broken|çalışmıyor)",
        lower,
    )

    if has(
        r"implement the plan|planı uygula|planı implement|plana göre|tüm todo|todo.*tamamla|do not edit the plan",
        lower,
    ):
        intent = "IMPLEMENT_PLAN"
        ctx_parts.append("[Intent:IMPLEMENT_PLAN]")
        return {
            "intent": intent,
            "ctx_parts": ctx_parts,
            "routed_skill": None,
            "intake_pending": False,
            "agent_route": "[route:implement-plan]",
            "quick_fix": False,
        }

    if has(r"\bfix\b|bug|hata|refactor|düzelt", lower) and not feature_repair:
        return {
            "intent": "QUICK_FIX",
            "ctx_parts": [],
            "routed_skill": None,
            "intake_pending": False,
            "agent_route": "",
            "quick_fix": True,
        }

    if has(r"plan(\s|$|ı|a|l)|uygulama plan|implementation plan|plan oluştur|plan yap", lower) and not has(
        r"implement|uygula|todo.*complete", lower
    ):
        intent = "PLAN_ONLY"
        ctx_parts.append("[Intent:PLAN_ONLY]")
        routed_skill = "implementation-plan"
    elif has(
        r"design|mockup|prototype|wireframe|tasarım|tema|ui oluştur|ekran tasar|redesign|güzel yap|visual|style|color palette|renk paleti",
        lower,
    ):
        intent = "DESIGN"
        ctx_parts.append("[Intent:DESIGN]")
        routed_skill = "design-intake"
    elif has(r"scaffold|yeni modül|yeni ekran|feature ekle|modül oluştur|ekran oluştur", lower):
        intent = "SCAFFOLD"
        ctx_parts.append("[Intent:SCAFFOLD]")
        routed_skill = "module-scaffolder"
    elif has(r"greenfield|proje başlat|agent oluştur|yeni proje|from scratch|sıfırdan", lower):
        intent = "GREENFIELD"
        ctx_parts.append("[Intent:GREENFIELD]")
        routed_skill = "project-intake"
    elif has(
        r"ekran testi|ekran test|screen test|test dökümanı|test dokumani|test docs|smoke test|user_test|uçtan uca test|e2e ekran",
        lower,
    ):
        intent = "SCREEN_TEST"
        ctx_parts.append("[Intent:SCREEN_TEST]")
        routed_skill = "screen-test-protocol"

    needs_intake = has(
        r"greenfield|proje başlat|agent oluştur|yeni proje|plan oluştur|uygulama plan|tasarım|mockup|scaffold|yeni modül|feature ekle|from scratch|sıfırdan",
        lower,
    )
    if needs_intake and not skip_intake:
        has_brief = BRIEF_DIR.is_dir() and any(BRIEF_DIR.glob("*.brief.md"))
        if not has_brief:
            intake_pending = True
            routed_skill = routed_skill or "project-intake"

    if not routed_skill:
        entry = match_registry(prompt)
        if entry:
            routed_skill = entry.get("id")

    agent_route = f"[route:{routed_skill}]" if routed_skill else ""

    return {
        "intent": intent,
        "ctx_parts": ctx_parts,
        "routed_skill": routed_skill,
        "intake_pending": intake_pending,
        "agent_route": agent_route,
        "quick_fix": False,
    }


def active_rules_and_estimate(
    routing: dict[str, Any],
    paths: list[str],
    manifest: dict[str, Any],
) -> tuple[list[str], int]:
    labels: list[str] = []
    est = 0
    for rule in manifest.get("rules", []):
        if rule_active(rule, paths, routing["intake_pending"]):
            labels.append(rule["label"])
            est += int(rule.get("tokens", 0))
    return labels, est


def build_report(
    routing: dict[str, Any],
    paths: list[str],
    manifest: dict[str, Any],
    active: dict[str, Any],
    active_rules: list[str],
    est: int,
) -> str:

    routed = routing.get("routed_skill")
    skill_tokens = manifest.get("skill_tokens", {})
    routed_skills: list[str] = []
    if routed:
        tok = skill_tokens.get(routed, 0)
        routed_skills.append(f"{routed} (yönlendirildi, ~{tok} tok)")

    read_rules = active.get("rules_read") or []
    read_skills = active.get("skills_read") or []
    read_configs = active.get("configs_read") or []

    lines = ["📋 Agent Kit — Bağlam"]
    lines.append(f"Intent: {routing['intent']}")
    lines.append(f"Rules: {', '.join(active_rules) if active_rules else '—'}")
    if routed_skills:
        lines.append(f"Skills (yönlendirilen): {', '.join(routed_skills)}")
    else:
        lines.append("Skills (yönlendirilen): —")
    if read_rules or read_skills or read_configs:
        loaded: list[str] = []
        loaded.extend(read_rules)
        loaded.extend(read_skills)
        loaded.extend(read_configs)
        lines.append(f"Okunan (bu oturum): {', '.join(loaded)}")
    if routing["intake_pending"]:
        lines.append("Intake: brief yok → config + intake skill bekleniyor")
    lines.append(f"Tahmini ek yük: ~{est} token")
    return "\n".join(lines)


def process(data: dict[str, Any]) -> dict[str, Any]:
    prompt = data.get("prompt") or data.get("user_message") or data.get("text") or ""
    if not prompt:
        return {"continue": True}

    manifest: dict[str, Any] = {"rules": [], "intake_artifacts": [], "skill_tokens": {}}
    if MANIFEST_PATH.is_file():
        try:
            manifest = load_json(MANIFEST_PATH)
        except (OSError, json.JSONDecodeError):
            pass

    paths = attachment_paths(data)
    routing = classify(prompt)
    active = load_active_context()
    active_rules, base_est = active_rules_and_estimate(routing, paths, manifest)

    routed = routing.get("routed_skill")
    skill_tokens = manifest.get("skill_tokens", {})
    est = base_est
    if routed:
        est += int(skill_tokens.get(routed, 0))
    if routing["intake_pending"]:
        for art in manifest.get("intake_artifacts", []):
            est += int(art.get("tokens", 0))

    user_message = build_report(routing, paths, manifest, active, active_rules, est)

    # user_message: full on-screen report (preferred; no agent cost when supported).
    # agent_message: compact one-liner (~15 tok) for IDE visibility + route tag.
    out: dict[str, Any] = {"continue": True, "user_message": user_message}

    if routing["ctx_parts"]:
        out["additional_context"] = " ".join(routing["ctx_parts"])

    route_msg = routing["agent_route"] or (
        "[route:implement-plan]" if routing["intent"] == "IMPLEMENT_PLAN" else ""
    )
    short_rules = ",".join(r.replace(".mdc", "") for r in active_rules[:3]) or "core"
    compact = f"[ctx ~{est}tok {short_rules}]"
    out["agent_message"] = f"{compact} {route_msg}".strip() if route_msg else compact

    # Persist last report for debugging / Hooks output channel
    report_path = ROOT / ".cursor/logs/last-context-report.txt"
    try:
        report_path.parent.mkdir(parents=True, exist_ok=True)
        report_path.write_text(user_message + "\n", encoding="utf-8")
    except OSError:
        pass

    return out


def main() -> None:
    raw = sys.stdin.read()
    if not raw.strip():
        print("{}")
        return
    try:
        data = json.loads(raw)
    except json.JSONDecodeError:
        print("{}")
        return
    print(json.dumps(process(data), ensure_ascii=False))


if __name__ == "__main__":
    main()
