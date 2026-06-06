# user_test

Proje-bagimsiz **ekran testi dokumantasyonu** klasoru. Her uygulama (app) icin ekran ekran test dosyalari Markdown olarak burada uretilir.

Bu klasor, gelistirme sirasinda agent tarafindan otomatik beslenir:

- **Otomatik tarayici testi** — dev server ayaktaysa `cursor-ide-browser` ile giris yapilir, tiklanir, form doldurulur/silinir/duzeltilir; sonuc ekran dosyasina yazilir.
- **Manuel test rehberi** — son kullanicinin hangi ekrani nasil test edecegini gosteren adim/checklist tablolari.

Kural ve akis: [`.cursor/skills/screen-test-protocol/SKILL.md`](../.cursor/skills/screen-test-protocol/SKILL.md) ve [`.cursor/rules/screen-test-docs.mdc`](../.cursor/rules/screen-test-docs.mdc).

## Yapi

| Yol | Icerik |
|-----|--------|
| [`index.md`](index.md) | Uygulama kayit defteri |
| `_templates/` | Generic sablonlar (process / fixture / run / app-index) |
| `<app>/index.md` | App ekran listesi + durum |
| `<app>/processes/NN-slug.md` | Tek ekran test dosyasi |
| `<app>/fixtures/*.md` | Mock / sentetik test verisi |
| `<app>/runs/YYYY-MM-DD-*.md` | Oturum bazli sonuc kaydi |

## Kurallar (ozet)

- Her dosya frontmatter'inda `app:` bulunur.
- Gercek kisisel veri yazilmaz; sentetik / mock seed kullanilir.
- Kod degisikligi burada yapilmaz; yalnizca test dokumani.
