# Örnek promptlar — cursor-agent-kit

[English](example-prompts.md) · **Türkçe**

Bu dosya, `.cursor/` altındaki **hooks**, **commands**, **skills**, **subagents**, **rules** ve **plans** yapılarını en iyi şekilde kullanmak için kopyala-yapıştır örnek promptlar içerir.

**Dil:** Chat Türkçe (`locale.chat`); plan/brief İngilizce (`locale.plan`).  
**Kaynak:** [.cursor/README.md](../README.md) · [registry.json](../skills/skills-router/registry.json)

---

## Katmanlar nasıl birlikte çalışır?

```text
Prompt → hooks (stack + intent + skill route) → skill (ana akış) → subagent (paralel keşif/doğrulama)
Slash → commands/*.md → aynı skill + subagent adımları (manuel, deterministik)
Rules → her turda (core) veya dosya glob'unda (plan, quality) yüklenir
Plans → brief → plan → implement (plan gövdesi read-only)
```

Kaliteli prompt = **hedef + kapsam + kısıt + doğrulama** (+ gerekiyorsa dosya yolu).

---

## Genel kalite şablonu

```text
[Hedef] … yapmak istiyorum.
[Kapsam] Dahil: … / Hariç: …
[Stack] React + .NET API / mevcut repo yapısına uy.
[Kısıt] Auth zorunlu, mock API, Türkçe UI.
[Doğrulama] Login → liste → oluştur akışı çalışsın.
[Mod] skip intake / skip refinement (isteğe bağlı)
```

---

## Hızlı referans

| Ne istiyorsun? | En iyi giriş |
|----------------|--------------|
| Fikri netleştir | `/refine` veya `prompt geliştir: …` |
| Brief | `/intake` veya `greenfield …` |
| Plan | `/plan` veya `plan oluştur …` |
| Kod (planlı) | `/implement` |
| Yeni modül iskeleti | `/scaffold` |
| UI/tasarım | `/design` |
| Modül tamir | `/fix` veya `uçtan uca` |
| Browser test | `/screen-test` |
| Oturum devri | `/handoff` |
| Repo anlatımı | `/onboard` |
| CVE | `/audit-deps` |
| SAST/secrets | `/security` |
| OpenAPI | `/api-review` |
| CI | `/ci` |
| Durum | `/status` |
| Brief atla | `skip intake` |
| Refine atla | `skip refinement` |

---

# 1. Slash commands

## `/refine` — Prompt netleştirme

```
/refine

Sıfırdan bir B2B faturalama paneli düşünüyorum. Kullanıcılar fatura oluşturup PDF indirebilsin.
Şu an sadece fikir aşamasındayım; stack ve modül sınırlarını netleştirmek istiyorum.
```

```
/refine

Mevcut monorepo'da "raporlama" modülü ekleyeceğiz ama veri kaynağı (API vs DB) kararsız.
Kısıtlar: mevcut shadcn + Tailwind, backend .NET 8.
Onay sonrası intake'e geçelim.
```

```
prompt geliştir: mobil-first onboarding wizard, 3 adım, analytics event'leri olsun
```

## `/intake` — Brief oluşturma

```
/intake

Greenfield: SaaS abonelik yönetim paneli.
Frontend React, backend REST API, mock ile başlayalım.
Deliverable: önce plan sonra kod.
```

```
/intake

Yeni ekran değil tam proje: iç ekip için envanter takip uygulaması.
Rol bazlı yetki, barkod okuma yok, sadece web.
Brief'i İngilizce plan diline uygun kaydet.
```

```
proje başlat: contractor onboarding portal, tek modül, PostgreSQL gerçek DB
```

## `/plan` — Uygulama planı

```
/plan

Onaylı brief: `.cursor/plans/_briefs/inventory-panel.brief.md`
Gap analizi yap, repo pattern'lerine uygun feature plan yaz.
Kritik plan-reviewer bulgularını düzeltmeden sunma.
```

```
plan oluştur: auth modülü — JWT + refresh token, mevcut Users tablosuyla uyumlu
```

```
implementation plan for slug `billing-admin` — include verification scenarios for invoice CRUD
```

## `/implement` — Planı uygulama

```
/implement

`.cursor/plans/features/billing-admin.plan.md` dosyasındaki planı uygula.
Sadece todos[].status güncelle; plan gövdesini değiştirme.
İlk todo: API contract + DTO'lar.
```

```
Implement the plan — start with todo "scaffold-api-routes", skip intake and refinement
```

## `/scaffold` — Modül iskeleti

```
/scaffold

Brief: `user-management.brief.md`
`apps/web/src/features/` altındaki mevcut pattern'e uygun kullanıcı listesi + detay modülü.
API client, types, route, boş sayfalar — iş mantığı sonra.
```

```
yeni modül: Sipariş geçmişi ekranı — liste + filtre + detay drawer, scaffold only
```

```
new screen: admin audit log viewer matching existing `features/reports` layout
```

## `/design` — Tasarım intake

```
/design

Dashboard redesign: koyu tema, düşük motion, shadcn + Tailwind.
Brief'te aesthetic minimal; grafikler için Recharts.
Önce design brief + design plan, kod yok.
```

```
tasarım: login ve kayıt ekranlarını modernleştir, a11y baseline, mobile-first mockup yaklaşımı
```

```
mockup plan for settings page — tabs: profile, security, notifications
```

## `/fix` — Uçtan uca modül onarımı

```
/fix

Ödeme modülü uçtan uca çalışmıyor: checkout başarılı görünüyor ama sipariş DB'ye düşmüyor.
Kapsam: `src/features/checkout/` + ilgili API handler'lar.
3-strike kuralına uy; TRACE sonrası dependency-tracer çıktısını kullan.
```

```
make auth work end-to-end — login redirect loop, focus on `apps/web` auth guard + API middleware
```

```
modül bozuk: bildirim servisi push göndermiyor, webhook + queue tarafını da incele
```

## `/screen-test` — Ekran testi + dokümantasyon

```
/screen-test

Dev server :3000'de ayakta. Tüm CRUD ekranlarını smoke test et.
Çıktı: `user_test/admin-panel/` altında ekran başına test doc.
```

```
ekran testi yap: login, dashboard, kullanıcı listesi — otomatik browser test + doküman
```

```
screen test for settings flows — include create/edit/delete where applicable
```

## `/handoff` — Oturum devri

```
/handoff

Yarın başka makineden devam edeceğim. Bu oturumu compact handoff doc'a çevir.
Secrets/PII redact et; plan ve brief path'lerini referans ver.
```

```
oturumu bitir — kalan işler: plan todo 4-7, açık PR yok
```

```
pick this up later — summarize decisions on auth approach and open blockers
```

## `/onboard` — Codebase onboarding

```
/onboard

Yeni backend geliştirici için onboarding doc: mimari, klasör yapısı, local setup, test komutları.
Hedef kitle: senior, 30 dk okuma.
```

```
repo nasıl çalışıyor — özellikle event-driven kısımları ve deployment akışını anlat
```

```
codebase overview for contractors — include command-validator çıktısıyla doğrulanmış install/test komutları
```

## `/audit-deps` — Bağımlılık denetimi

```
/audit-deps

Release öncesi tam dependency audit: CVE, transitive risk, lisans çakışması.
Öncelik: critical/high CVE'ler için upgrade yolu.
```

```
cve taraması yap — npm + pip tarafı, audit-runner ham çıktısını özetle
```

```
dependency audit — flag GPL conflicts in frontend bundles
```

## `/security` — Güvenlik taraması

```
/security

OWASP Top 10 odaklı uygulama güvenlik taraması. semgrep + gitleaks + secrets.
Rapor: bulgu, önem, düzeltme önerisi.
```

```
güvenlik taraması: auth endpoint'leri, SQL injection, hardcoded secret
```

```
security scan before production — include checkov if infra folders exist
```

## `/api-review` — API tasarım incelemesi

```
/api-review

`openapi.yaml` v2 migration review — breaking change analizi, versioning, error envelope tutarlılığı.
spectral + oasdiff kullan.
```

```
rest api design review for `/api/v1/orders` — pagination, idempotency, status codes
```

```
openapi lint — compare staging vs production spec for breaking changes
```

## `/ci` — CI/CD pipeline

```
/ci

GitHub Actions: lint, test, build, staging deploy. Monorepo pnpm, .NET API ayrı job.
Mevcut `package.json` script'lerini command-validator ile doğrula.
```

```
pipeline oluştur: PR'da unit test + main'de docker image publish
```

```
ci/cd for Node frontend + Python worker — parallel jobs, cache strategy
```

## `/skip-intake` ve `/skip-refine`

```
/skip-intake

Plan zaten kafamda net: doğrudan `features/notifications.plan.md` yaz.
Brief atlanabilir; scope prompt'ta.
```

```
skip intake — implement existing plan at `.cursor/plans/features/auth.plan.md`
```

```
/skip-refine

Acil hotfix: `UserService.cs` line 142 null reference — minimal diff, intake/refine yok.
```

```
skip refinement — greenfield değil, sadece README güncelle
```

## `/status` — Kit durumu

```
/status

Aktif brief'ler, plan'lar, branch, son context report özeti.
```

---

# 2. Skills (doğal dil — hook registry)

Hook'lar [registry.json](../skills/skills-router/registry.json) üzerinden skill seçer. Aşağıdaki ifadeler otomatik yönlendirme tetikler (İngilizce ve Türkçe).

### Greenfield & planlama

| Prompt | Beklenen davranış |
|--------|-------------------|
| `Sıfırdan Next.js admin paneli planla` | prompt-refinement → project-intake → implementation-plan |
| `from scratch: headless CMS + React editor` | project-intake |
| `agent oluştur: repo analiz botu, CLI çıktılı` | project-intake |
| `plan yap: çok kiracılı (multi-tenant) SaaS çekirdeği` | implementation-plan |

### Modül & scaffold

| Prompt | Skill |
|--------|-------|
| `yeni ekran: ürün kataloğu listesi ve detay` | module-scaffolder |
| `feature ekle: webhook yönetimi admin'e` | module-scaffolder |
| `scaffold notifications preferences module` | module-scaffolder |

### Tasarım

| Prompt | Skill |
|--------|-------|
| `UI'ı güzel yap: landing page, gradient hero, düşük motion` | design-intake |
| `wireframe seviyesinde checkout akışı tasarım planı` | design-intake |
| `redesign settings with dark theme` | design-intake |

### Onarım (focused-fix vs hızlı fix)

| Prompt | Davranış |
|--------|----------|
| `Fix login bug — typo in redirect URL` | QUICK_FIX (skill yok, sadece core.mdc) |
| `make billing work end-to-end` | focused-fix + dependency-tracer |
| `uçtan uca: rapor export Excel bozuk` | focused-fix |
| `modül bozuk: cache invalidation` | focused-fix |

### Uzman skill örnekleri

```
OpenAPI spec'imizi v3.1'e taşıyoruz; breaking change ve versioning standardı öner.
→ api-design-reviewer + openapi-linter
```

```
PostgreSQL şema tasarımı: orders, order_items, payments — normalize et, ERD çıkar.
→ database-schema-designer + schema-reviewer
```

```
GitHub API'yi MCP server olarak expose et — OpenAPI'dan tool üret.
→ mcp-server-builder
```

```
Yeni skill yaz: PR description otomatik üreten workflow, registry trigger'ları dahil.
→ skill-creator
```

```
`rapor.docx` oluştur: Q1 özet, tablo + başlıklar.
→ docx-tools
```

```
`fiyatlar.xlsx` — CSV'ye çevir, boş satırları temizle.
→ xlsx-tools
```

```
`sunum.pptx`: yatırımcı pitch, 12 slide, problem-çözüm-pazar.
→ pptx-tools
```

```
`sozlesme.pdf` ile `ek.pdf` birleştir, filigran ekle.
→ pdf-tools
```

---

# 3. Subagent odaklı promptlar

Subagent'lar genelde skill/command üzerinden tetiklenir. Net talimat örnekleri:

### `repo-explorer` (readonly)

```
Plan yazmadan önce repo-explorer çalıştır: mevcut feature klasör pattern'lerini ve stack sinyallerini tabloya dök.
Kapsam: sadece `apps/web` ve `services/api`.
```

```
Gap analysis — 3 örnek modül path'i + önerilen scaffold yolu; dosya oluşturma yok.
```

### `brief-validator` (readonly)

```
`.cursor/plans/_briefs/crm.brief.md` dosyasını `required_before_plan` alanlarına karşı doğrula.
Eksik alanları listele, brief düzeltme öner.
```

### `plan-reviewer` (readonly)

```
`.cursor/plans/features/crm.plan.md` — brief ile tutarlılık, plan-authoring kuralları, verification bölümü.
Kritik issue varsa implement önerme.
```

### `dependency-tracer` (readonly)

```
SCOPE tamam: `src/modules/payments/**`
dependency-tracer ile inbound/outbound import haritası çıkar; focused-fix DIAGNOSE için kullanacağız.
```

### `route-mapper` (readonly)

```
Tüm React route'ları, auth gereksinimi ve CRUD matrisi — screen-test öncesi route-mapper çıktısı istiyorum.
```

### `command-validator` (shell)

```
Projedeki install, dev, test, build komutlarını doğrula; hangileri çalışıyor hangileri kırık raporla.
```

### `audit-runner` (shell)

```
osv-scanner + npm audit + pip-audit — ham CLI çıktısı, triage ben yapacağım.
```

### `security-scanner` (shell)

```
semgrep + gitleaks taraması — tool yoksa "Could not run" formatında bildir.
```

### `openapi-linter` (shell)

```
spectral lint `docs/openapi.yaml` + oasdiff breaking vs `main` branch spec.
```

### `schema-reviewer` (readonly)

```
Mevcut EF Core migration'ları ve entity envanteri — yeni loyalty program şemasından önce schema-reviewer.
```

### `artifact-collector` (readonly)

```
Handoff için: tüm brief/plan path'leri, git branch, uncommitted değişiklik özeti — artifact-collector formatında.
```

### Paralel subagent

```
/plan öncesi paralel çalıştır:
1) repo-explorer — gap table
2) brief-validator — `inventory.brief.md`
Sonuçları birleştirip plana yansıt.
```

---

# 4. Plans & briefs

### Brief isteme

```
Brief slug: `vendor-portal`
İçerik: B2B tedarikçi portalı, tek modül, REST + React, mock API ile başla.
UI: shadcn, minimal aesthetic, system theme.
Out of scope: mobil native app.
```

### Plan yazdırma

```
`.cursor/plans/_briefs/vendor-portal.brief.md` onaylı.
Feature plan yaz: YAML frontmatter, Scope in/out, Verification tablosu (UI senaryoları).
Şablon: `plans/_templates/feature-plan.template.md`
Dil: plan İngilizce (project.defaults.yaml).
```

### Implement modu

```
Plan: `vendor-portal.plan.md`
Kural: plan gövdesi read-only; sadece todo status güncelle.
Sıra: backend API → frontend liste → entegrasyon testi.
Her todo bitince status `completed` yap.
```

### Plan kapatma

```
Plan `vendor-portal` tamamlandı — overview'a İngilizce kapanış satırı ekle, kalan todo yoksa hepsini completed işaretle.
```

---

# 5. Rules

| Rule | Ne zaman hatırlat |
|------|-----------------|
| [core.mdc](../rules/core.mdc) | Her zaman — minimal diff, commit yok |
| [plan-authoring.mdc](../rules/plan-authoring.mdc) | `.cursor/plans/**/*.plan.md` düzenlerken |
| [quality-standards.mdc](../rules/quality-standards.mdc) | UI/PR kalite incelemesi |
| [screen-test-docs.mdc](../rules/screen-test-docs.mdc) | `user_test/<app>/` doc formatı |

Örnek:

```
Bu plan dosyasını düzenlerken plan-authoring kurallarına uy:
frontmatter, Brief section, Scope, Verification linki zorunlu.
```

```
@cursor-guidelines — bu oturumda disiplin kurallarını hatırla, sonra /plan akışına devam et.
```

---

# 6. Hooks (dolaylı tetikleme)

| Hook event | Script | Örnek prompt etkisi |
|------------|--------|---------------------|
| `sessionStart` | session-detect-stack.sh | Yeni oturumda `[Stack:…]` — stack'i yeniden tahmin etme |
| `beforeSubmitPrompt` | route-work.sh | Intent + skill route + bağlam raporu |
| `beforeReadFile` | track-context-read.sh | Hangi rule/skill gerçekten okundu |
| `stop` | log-task-end.sh | Görev süresi log |

```
/status — son Agent Kit bağlam raporunu oku: hangi skill'ler route edildi?
```

```
Bu prompt'ta gereksiz intake açma; kapsam net, skip intake.
```

---

# 7. Uçtan uca senaryolar

### Senaryo A — Sıfırdan ürün

```text
1) /refine — B2B stok yönetimi, 5 rol, web only
2) [onay]
3) /intake — brief slug: stock-admin
4) /plan — gap + plan-reviewer
5) [plan onayı]
6) /implement — todo sırasıyla
7) /screen-test — CRUD smoke
8) /handoff — kalan işler
```

Tek mesaj:

```
Sıfırdan stok yönetim paneli planla: React, .NET API, mock MSW.
Roller: admin, depo, satış. Önce brief ve plan, onaydan sonra kod.
Türkçe chat, plan İngilizce.
```

### Senaryo B — Mevcut repoya modül

```
skip refinement

Brief zaten var: `crm-contacts.brief.md`
/scaffold — contacts list + detail, repo pattern'e uy
Ardından /implement — sadece frontend todo'ları
```

### Senaryo C — Kırık modül

```
/fix

make sync engine work end-to-end
Scope: `workers/sync/` + `api/webhooks/`
Verify: webhook alındı → queue → DB satırı oluştu
```

### Senaryo D — Release hazırlığı

```
Paralel güvenlik paketi:
1) /audit-deps
2) /security
3) /api-review — `openapi/production.yaml`
Özet tablo: blocker / warning / info
```

### Senaryo E — Takım onboarding

```
/onboard

Hedef: frontend dev, ilk gün setup.
repo-explorer + command-validator çıktısını doc'a göm.
Çıktı: `docs/ONBOARDING.md` (İngilizce teknik, chat Türkçe)
```

### Senaryo F — MCP entegrasyonu

```
Mevcut OpenAPI: `specs/internal-api.yaml`
Bu API'yi MCP server olarak expose et — Python, auth header forward.
mcp-server-builder skill akışını takip et.
```

---

# 8. İyi vs zayıf prompt

| Zayıf | İyi |
|-------|-----|
| `Plan yap` | `plan oluştur: slug inventory-admin, brief onaylı, gap analizi dahil` |
| `Güvenlik` | `/security — OWASP, auth route'lar, secret scan, öncelik sıralı rapor` |
| `Fix it` | `Fix login redirect — /fix ile auth modülü uçtan uca` |
| `Test et` | `/screen-test — :5173 ayakta, user_test docs zorunlu` |
| `Kod yaz` | `/implement — plan path ver, todo id belirt, plan read-only` |

---

## İlgili dosyalar

- Kit özeti: [README.md](../README.md)
- Slash command tanımları: [commands/](../commands/)
- Subagent tanımları: [agents/](../agents/)
- Skill router: [registry.json](../skills/skills-router/registry.json)
- Varsayılanlar: [project.defaults.yaml](../config/project.defaults.yaml)
