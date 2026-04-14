# Лабораторна робота №1

## Тема
Налаштування середовища розробки та базові інструменти розгортання.

## Що виконано
- Створено застосунок `React + Vite + TypeScript` у папці `lab-1-setup`.
- Перевірено базові npm-скрипти: `dev`, `build`, `lint`.
- Додано налаштування VS Code у `.vscode/settings.json` (format on save + ESLint fixes).
- Додано GitHub Actions workflow для GitHub Pages:
  - файл `.github/workflows/deploy.yml`;
  - збірка запускається в підпапці `./lab-1-setup`;
  - артефакт деплоїться з `./lab-1-setup/dist`.
- Додано Docker-конфігурацію:
  - `lab-1-setup/Dockerfile`
  - `lab-1-setup/.dockerignore`
- Для GitHub Pages у Vite додано `base: '/lab-1-setup/'` у `lab-1-setup/vite.config.ts`.

## Що зробити вручну для завершення (1 раз)
1. Встановити Git:
   - завантажити з https://git-scm.com/download/win
2. Встановити Docker Desktop:
   - завантажити з https://www.docker.com/products/docker-desktop/
3. Налаштувати Git глобально:
   - `git config --global user.name "Ваше Ім'я"`
   - `git config --global user.email "your-email@example.com"`
4. Створити GitHub репозиторій саме з назвою `lab-1-setup`.
5. Налаштувати SSH-ключ:
   - `ssh-keygen -t ed25519 -C "your-email@example.com"`
   - додати публічний ключ у GitHub → Settings → SSH and GPG keys.
6. У GitHub репозиторії увімкнути Pages:
   - Settings → Pages → Source: `GitHub Actions`.

## Команди для перевірки
У папці `lab-1-setup`:
- `npm install`
- `npm run dev`
- `npm run build`
- `npm run lint`

## Шаблон висновку
У межах лабораторної роботи було налаштовано локальне середовище веб-розробки, створено TypeScript-проєкт на Vite, додано інструменти контролю якості коду та автоматизовано деплой через GitHub Actions. Отримано практичні навички підготовки застосунку до публікації на GitHub Pages і Vercel.
