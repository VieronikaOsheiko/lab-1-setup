# Лабораторна робота №5

## Тема
Впровадження CI/CD: автоматизація перевірок коду та публікація Docker-образів у GitHub Actions (GHCR).

## Що реалізовано в репозиторії
- **Unit-тести** на базі **Vitest** + React Testing Library у `lab-1-setup/`
- **Dockerfile (multi-stage)** для production-образу Vite застосунку у `lab-1-setup/Dockerfile`
- **GitHub Actions CI/CD** у `.github/workflows/ci-cd.yml`:
  - job `quality-checks`: `lint` → `test` → `build` (на `push` і `pull_request`)
  - job `build-and-publish`: build & push у **GitHub Container Registry** (лише `push` в `main`)

## Локальна перевірка
У папці `lab-1-setup`:
```powershell
npm run lint
npm run test
npm run build
```

## Артефакти GHCR (після успішного пайплайна)
Образ публікується як:
`ghcr.io/<owner>/<repo>:latest`

Приклад pull:
```powershell
docker pull ghcr.io/vieronikaosheiko/lab-1-setup:latest
```

## Branch protection (виконується вручну у GitHub)
`Settings -> Branches -> Add branch protection rule` для `main`:
- Require status checks to pass before merging
- Обрати check: `quality-checks`

