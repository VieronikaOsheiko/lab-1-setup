# Лабораторна робота №3

## Тема
Оркестрація багатокомпонентних вебархітектур за допомогою Docker Compose (Front-end/Back-end/Database): запуск зв'язки застосунку та БД, управління залежностями.

## Мета
Опанувати практичні навички запуску багатоконтейнерних застосунків через Docker Compose, налаштувати персистентність даних (volumes), bind mounts для розробки, міграцію з SQLite на MySQL, та керування залежностями через `depends_on` + `healthcheck`.

## База для роботи
Використано демо-проєкт `getting-started-app` з ЛР2:
`C:\Labmac\lab-2-docker\getting-started-app`

## Етап 1. Persistence (SQLite)
Файл: `compose.sqlite.yaml`

Запуск:
```powershell
cd "C:\Labmac\lab-2-docker\getting-started-app"
docker compose -f compose.sqlite.yaml up -d --build
docker compose -f compose.sqlite.yaml ps
```

Перевірка: `http://localhost:3000`

Зупинка (том з даними залишиться):
```powershell
docker compose -f compose.sqlite.yaml down
```

Повне очищення включно з томом:
```powershell
docker compose -f compose.sqlite.yaml down --volumes
```

## Етап 1.3 Bind mount (dev)
Файл: `compose.dev.yaml`

Запуск:
```powershell
docker compose -f compose.dev.yaml up -d
docker compose -f compose.dev.yaml logs -f app
```
Перевірка: `http://localhost:3000`

## Етап 2-3. MySQL + Docker Compose (оркестрація)
Файл: `compose.yaml` (сервіси `mysql` та `app`)

Запуск:
```powershell
docker compose up -d --build
docker compose ps
```

Логи застосунку (має бути підключення до MySQL за хостом `mysql`):
```powershell
docker compose logs app
```

Зупинка (дані MySQL збережуться у named volume `todo-mysql-data`):
```powershell
docker compose down
```

Перевірка персистентності:
1) Додати кілька To-Do у `http://localhost:3000`
2) `docker compose down`
3) `docker compose up -d`
4) Переконатися, що дані збереглися

## Що додати у звіт (скріни)
- `docker compose up -d` (видно створення мережі/томів)
- `docker compose ps` (MySQL = healthy)
- `docker compose logs app` (успішне підключення до MySQL)
- Демонстрація персистентності (до/після `down` та `up`)
