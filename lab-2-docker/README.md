# Лабораторна робота №2

## Тема
Практикум з Docker: створення багатоетапних збірок (multi-stage), робота з реєстрами (Docker Hub/ECR).

## Мета
Опанування контейнеризації вебзастосунків, оптимізації образів через multi-stage збірку та публікації образів у Docker Hub (і за бажанням у Amazon ECR).

## Структура репозиторію
- Код демо-проєкту: каталог `getting-started-app/` (офіційний приклад Docker Workshop).
- Single-stage: `getting-started-app/Dockerfile`
- Multi-stage: `getting-started-app/Dockerfile.multi`

## Етап 1-2. Підготовка середовища і демо-проєкт
Перевірка Docker:
```powershell
docker --version
```

Демо-проєкт взято з Docker Workshop (`getting-started-app`).

## Етап 3. Однорівнева збірка
Файл `getting-started-app/Dockerfile`:
```dockerfile
FROM node:24-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev

COPY . .

EXPOSE 3000
CMD ["node", "src/index.js"]
```

Збірка:
```powershell
cd getting-started-app
docker build -t todo-single -f Dockerfile .
```

## Етап 4. Багатоетапна збірка
Файл `getting-started-app/Dockerfile.multi`:
```dockerfile
FROM node:24-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

FROM node:24-alpine AS runtime

WORKDIR /app
ENV NODE_ENV=production

COPY --from=builder /app/package*.json ./
COPY --from=builder /app/src ./src
COPY --from=builder /app/node_modules ./node_modules

EXPOSE 3000
CMD ["node", "src/index.js"]
```

Збірка:
```powershell
cd getting-started-app
docker build -t todo-multi -f Dockerfile.multi .
```

Порівняння:
```powershell
docker images
```

Отримані результати (приклад):
- `todo-single:latest` → ~296MB (disk usage)
- `todo-multi:latest` → ~271MB (disk usage)

## Етап 5. Docker Hub (push/pull/verify)
1) Логін (через PAT):
```powershell
docker login -u <dockerhub_username>
```

2) Тегування:
```powershell
docker tag todo-multi <dockerhub_username>/todo-app:v1.0
```

3) Публікація:
```powershell
docker push <dockerhub_username>/todo-app:v1.0
```

4) Перевірка pull/run:
```powershell
docker rmi todo-multi
docker run -dp 3000:3000 <dockerhub_username>/todo-app:v1.0
```
Відкрити: `http://localhost:3000`

## Бонус. Amazon ECR
```powershell
aws configure
aws ecr create-repository --repository-name node-todo-repo --region <region>
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.<region>.amazonaws.com
docker tag todo-multi <aws_account_id>.dkr.ecr.<region>.amazonaws.com/node-todo-repo:latest
docker push <aws_account_id>.dkr.ecr.<region>.amazonaws.com/node-todo-repo:latest
```

## Аналітична таблиця (для звіту)
| Критерій | todo-single | todo-multi |
|---|---:|---:|
| Розмір образу (disk usage) | ~296MB | ~271MB |
| Кількість етапів збірки | 1 | 2 |
| Рівень мінімізації артефактів | нижчий | вищий |

## Висновок (коротко)
Багатоетапна збірка дозволяє відокремити процес підготовки залежностей від runtime-етапу та переносити у фінальний образ тільки необхідні файли. Це зменшує розмір образу, покращує контроль складу артефактів і спрощує подальше розгортання в реєстрах контейнерів.
