# user_test - Ekran testi arsivi

Her uygulama (app) icin ekran ekran test dokumanlari burada Markdown olarak tutulur. Otomatik tarayici testi (cursor-ide-browser) ve son kullanici manuel testi ayni dosyadan beslenir.

Uretim/guncelleme kurali: [`.cursor/skills/screen-test-protocol/SKILL.md`](../.cursor/skills/screen-test-protocol/SKILL.md)

## Uygulamalar

| App | Klasor | Dev komutu | Dev URL | Durum |
|-----|--------|------------|---------|-------|
| _henuz yok_ | `user_test/<app>/` | | | |

> Yeni app testi: `<app>` icin klasor acilir ve [`_templates/`](_templates/) sablonlarindan ekran dosyalari uretilir.

## Klasor yapisi (her app)

```
user_test/<app>/
  index.md          <- app ekran listesi + durum (app-index.template.md)
  processes/        <- ekran ekran test dosyalari (NN-slug.md)
  fixtures/         <- mock / sentetik test verisi
  runs/             <- oturum bazli calistirma kayitlari (YYYY-MM-DD-*.md)
```

## Sablonlar

| Sablon | Amac |
|--------|------|
| [`_templates/process.template.md`](_templates/process.template.md) | Tek ekran test dosyasi |
| [`_templates/fixture.template.md`](_templates/fixture.template.md) | Test verisi |
| [`_templates/run.template.md`](_templates/run.template.md) | Calistirma kaydi |
| [`_templates/app-index.template.md`](_templates/app-index.template.md) | App ekran indeksi |

## Kurallar

- Her dosyada frontmatter `app:` zorunlu.
- Gercek TCKN / telefon / e-posta yazilmaz; mock seed veya sentetik degerler.
- Test bitince ilgili ekran dosyasindaki checklist ve "Otomatik test sonucu" guncellenir + `runs/YYYY-MM-DD-*.md` eklenir.
- Bu klasorde kod degisikligi yapilmaz; yalnizca test dokumantasyonu.
