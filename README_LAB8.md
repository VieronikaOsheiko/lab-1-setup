# Лабораторна робота №8

## Тема
Побудова та впровадження систем моніторингу, логування та алертингу для хмарних вебсервісів (AWS CloudWatch, EC2, SNS).

## Мета
Сформувати цілісне розуміння спостережуваності (observability): метрики, логи, алерти та дашборди; перейти від реактивного підходу до проактивного виявлення аномалій.

## Зв’язок з Лаб. №7
Об’єкт моніторингу — інфраструктура з Лаб 7: **EC2 (Ubuntu + Nginx + PM2 + застосунок)**, **RDS**, **S3**. У звіті вкажіть актуальні **публічну IP EC2**, **ідентифікатор/endpoint RDS**, **назву бакета S3** (без паролів і ключів).

## Структура у репозиторії
- `lab-8-monitoring/cloudwatch-agent-config.example.json` — **приклад** конфігурації Unified CloudWatch Agent (шляхи до логів PM2 перевірте на сервері командою `ls ~/.pm2/logs/`).
- Цей файл — орієнтир для звіту; робочий `config.json` на EC2 зазвичай лежить у `/opt/aws/amazon-cloudwatch-agent/bin/config.json` після майстра або ручного копіювання.

---

## Етап 1. IAM і роль для EC2

1. **IAM → Roles → Create role** → trusted entity: **AWS service** → **EC2**.
2. Додайте керовану політику **`CloudWatchAgentServerPolicy`** (запис метрик і логів у CloudWatch).
3. Завершіть створення ролі (наприклад, ім’я `EC2-CloudWatch-Agent-Role`).
4. **EC2 → Instances** → виберіть інстанс з Лаб 7 → **Actions → Security → Modify IAM role** → призначте цю роль.
5. Переконайтеся, що **немає** статичних AWS-ключів у конфігах агента на диску — автентифікація через **метадані інстансу**.

---

## Етап 2. Встановлення CloudWatch Agent (Ubuntu 22.04, amd64)

Підключіться по SSH до EC2 і виконайте:

```bash
cd /tmp
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i amazon-cloudwatch-agent.deb
```

Інтерактивний майстер (опційно, для чернетки конфігурації):

```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard
```

Підказки майстра: Linux, EC2, увімкнути **memory / disk / swap**, додати шляхи до логів Nginx і PM2.

---

## Етап 3. Конфігурація агента (метрики + логи)

1. Скопіюйте приклад з репозиторію на сервер або відредагуйте локально згенерований файл.
2. **Обов’язково перевірте імена файлів PM2**: `pm2 list`, потім `ls -la /home/ubuntu/.pm2/logs/`.  
   Якщо процес називається інакше, ніж `lab7-vite`, змініть `file_path` у секції `logs` відповідно до реальних `*-out.log` / `*-error.log`.
3. **Multi-line** для PM2: параметр `multi_line_start_pattern` задає, з якого рядка починається *новий* лог-запис (часто рядок з датою). Якщо ваші логи однорядкові або формат інший — змініть патерн або приберіть ключ (інакше рядки можуть «склеюватися» некоректно).
4. Збережіть робочий JSON, наприклад:

```bash
sudo nano /opt/aws/amazon-cloudwatch-agent/bin/config.json
```

5. Застосуйте конфігурацію та увімкніть агент:

```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json
```

6. Перевірка:

```bash
sudo systemctl status amazon-cloudwatch-agent
```

7. У консолі **CloudWatch → Metrics → All metrics → CWAgent** з’являться системні метрики; **Logs → Log groups** — групи на кшталт `Nginx-Access`, `PM2-App-Logs` (назви як у вашому JSON).

---

## Етап 4. Metric Filters для HTTP 4xx / 5xx (Nginx access.log)

1. Відкрийте **Log groups** → групу, куди стрімиться **access.log** (у прикладі — `Nginx-Access`).
2. **Create metric filter**.
3. Підберіть **Filter pattern** під ваш **log format**. Для типового combined-формату статус часто можна виділити як поле; приклади з документації AWS — пошук за шаблоном статус-коду (5xx / 4xx). Див. [Find a term and count the matches](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/FindCountMetric.html).
4. Створіть метрики, наприклад:
   - простір імен: **LogMetrics** (або інший узгоджений з методичкою);
   - імена: `Http5xxCount`, `Http4xxCount`;
   - значення **1** на кожен збіг (для подальшого `SUM` у алармі).
5. Зачекайте кілька хвилин і перевірте наявність метрик у **Metrics** після генерації трафіку/помилок.

---

## Етап 5. Amazon SNS і підписка e-mail

1. **SNS → Topics → Create topic** → тип **Standard**, ім’я наприклад **`InfrastructureAlerts`**.
2. **Create subscription** → протокол **Email**, ваш email → створити.
3. Відкрийте лист від AWS і натисніть **Confirm subscription** (без цього листів не буде).

---

## Етап 6. CloudWatch Alarms

У **CloudWatch → Alarms → All alarms → Create alarm**:

| Назва (приклад) | Джерело метрики | Умова (орієнтир) |
|-----------------|-----------------|------------------|
| High-CPU-Warning | EC2 → `CPUUtilization` | &gt; 80%, 2×5 хв |
| Low-Memory-Critical | CWAgent → `MEM_USED_PERCENT` | &gt; 90%, 1×5 хв |
| Disk-Full-Alarm | CWAgent → `DISK_USED_PERCENT` | &gt; 85%, 1×5 хв |
| API-5xx-Alert | Metric filter → `Http5xxCount` (SUM) | &gt; 5 за 1 хв (уточніть під свої дані) |

У кожному алармі в блоці **Notification** вкажіть SNS-топік **`InfrastructureAlerts`**, стан **In alarm**.

**Перевірка листа (CPU):** на EC2 можна тимчасово навантажити CPU (після `sudo apt install -y stress`):

```bash
stress --cpu 4 --timeout 120
```

Переконайтеся, що аларм переходить у **ALARM** і що лист прийшов (скрін для звіту).

---

## Етап 7. CloudWatch Dashboard

1. **CloudWatch → Dashboards → Create dashboard**, назва наприклад **`Production-Overview`**.
2. Віджети (приклад):
   - **Alarm status** — огляд стану алармів;
   - **Line** — CPU (EC2) і `MEM_USED_PERCENT` (CWAgent) на одному графіку або поруч;
   - за наявності метрик з фільтрів — графік 4xx/5xx;
   - **Logs table** — останні записи з `PM2-App-Logs` (фільтр за текстом `error`, якщо є).
3. Період: наприклад **3 години**, автооновлення **10 с** (якщо доступно в UI).

---

## RDS і S3 на дашборді (розширення)

- **RDS:** метрики `DatabaseConnections`, `ReadLatency`, `WriteLatency`, `FreeStorageSpace` — додайте віджети з namespace **AWS/RDS**, виберіть свій DB instance.
- **S3:** `BucketSizeBytes`, `NumberOfObjects` — namespace **AWS/S3**, виберіть бакет (уточніть періодичність оновлення метрик S3 у регіоні).

---

## CloudWatch Logs Insights (для звіту)

У **Logs Insights** виберіть log group(s) (Nginx / PM2), задайте часовий діапазон і запит, наприклад знайти рядки з `500` або `error`. Збережіть скріншот запиту та результатів.

---

## Рекомендації для логів Node.js (опційно)

- Структуровані логи (**JSON**) через **Pino** / **Winston** полегшують пошук у Logs Insights.
- **Correlation ID** (унікальний ID на запит) у кожному записі спрощує трасування від Nginx до застосунку.

---

## Вимоги до звіту (чеклист)

1. Титул, мета, завдання (коротко).
2. Опис об’єкта моніторингу (EC2 IP, RDS, S3 — без секретів).
3. Повний текст **`config.json`** агента з EC2 + коментар у тексті звіту щодо метрик, шляхів логів і multi-line.
4. Скріншоти метрик **CWAgent** (RAM, диск; за бажанням CPU).
5. Скріншоти **Log Groups**, приклад стрімінгу Nginx і PM2; **Logs Insights**.
6. Скріншоти **Alarms**, підтвердження **SNS**, лист від аларму після навантаження.
7. Скріншот **Dashboard** + пояснення віджетів.
8. Висновки: як моніторинг допоможе з витоками пам’яті / з’єднаннями з БД / помилками async; орієнтові витрати (метрики, логи, зберігання); готовність інфраструктури Лаб 7 до експлуатації після Лаб 8.

---

## Джерела (орієнтири)

- [EC2 Monitoring and Observability — AWS Observability Best Practices](https://aws-observability.github.io/observability-best-practices/guides/ec2-monitoring/)
- [CloudWatch Alarms](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Alarms.html)
- [Metric filters — приклад підрахунку 4xx](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/FindCountMetric.html)
- [Створення дашборду CloudWatch](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/create_dashboard.html)
