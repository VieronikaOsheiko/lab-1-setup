# Лабораторна робота №2

## Тема
Практикум з Docker: створення багатоетапних збірок (multi-stage), робота з реєстрами (Docker Hub/ECR).

## Мета
Опанування контейнеризації вебзастосунків, оптимізації образів через multi-stage збірку та публікації образів у Docker Hub (і за бажанням у Amazon ECR).

## Структура проєкту
- Робоча папка: `C:\Labmac\lab-2-docker\getting-started-app`
- Single-stage Dockerfile: `Dockerfile`
- Multi-stage Dockerfile: `Dockerfile.multi`

## Етап 1-2. Підготовка середовища і демо-проєкт
Перевірка Docker:
```powershell
docker --version
```

Демо-проєкт взято з Docker Workshop (`getting-started-app`).

## Етап 3. Однорівнева збірка
Файл `Dockerfile`:
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
cd "C:\Labmac\lab-2-docker\getting-started-app"
docker build -t todo-single -f Dockerfile .
```

## Етап 4. Багатоетапна збірка
Файл `Dockerfile.multi`:
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
docker build -t todo-multi -f Dockerfile.multi .
```

Порівняння:
```powershell
docker images
```

Отримані результати:
- `todo-single:latest` -> `296MB` (disk usage), content size `75.2MB`
- `todo-multi:latest` -> `271MB` (disk usage), content size `66.4MB`

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
| Розмір образу (disk usage) | 296MB | 271MB |
| Content size | 75.2MB | 66.4MB |
| Кількість етапів збірки | 1 | 2 |
| Рівень мінімізації артефактів | нижчий | вищий |

## Висновок (коротко)
Багатоетапна збірка дозволяє відокремити процес підготовки залежностей від runtime-етапу та переносити у фінальний образ тільки необхідні файли. Це зменшує розмір образу, покращує контроль складу артефактів і спрощує подальше розгортання в реєстрах контейнерів.
