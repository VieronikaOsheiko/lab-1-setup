# Лабораторна робота №6

## Тема
Автоматизація розгортання вебзастосунків та управління хмарною інфраструктурою засобами Terraform (Infrastructure as Code).

## Мета
Опанувати Terraform (HCL), роботу з провайдерами, планування/застосування змін та аналіз дрейфу конфігурації на прикладі автоматичного розгортання застосунку з Лаб. №1 у Vercel.

## Структура у репозиторії
- `terraform/` — Terraform конфігурація для Vercel
- `lab-1-setup/` — застосунок (Vite), який розгортається у Vercel

## Встановлення Terraform (Windows)
Рекомендовано через `winget`:

```powershell
winget install Hashicorp.Terraform
terraform -v
```

## ВАРІАНТ 1: Vercel (PaaS)

### 1) Отримати Vercel API Token
`Vercel -> Account Settings -> Tokens -> Create Token` (Scope: Full Access).  
Токен показується 1 раз — збережіть його.

### 2) Підготувати `terraform.tfvars` (НЕ комітити)
У папці `terraform/`:
- скопіювати `terraform.tfvars.example` → `terraform.tfvars`
- заповнити:
  - `vercel_api_token`
  - `student_id` (латиницею, без пробілів; наприклад `nosko`)
  - `github_repo` (у форматі `owner/repo`)

Файл `terraform.tfvars` і Terraform state **ігноруються** через кореневий `.gitignore`.

### 3) Запуск Terraform
Команди виконувати у терміналі з директорії `C:\Labmac\terraform`:

```powershell
terraform init
terraform plan
terraform apply
```

### 4) Перевірка результату
Після `apply`:
- у Vercel з'явиться проєкт `lab6-terraform`
- домен буде: `lab6-<student_id>.vercel.app`

## Обов’язкові скріншоти для звіту
- **Рис. 1**: `terraform -v` (версія Terraform)
- **Рис. 2**: `terraform plan` (показує ресурси, які будуть створені)
- **Рис. 3**: `terraform apply` (успішне застосування, `Apply complete!`)
- **Рис. 4**: Vercel Dashboard з проєктом `lab6-terraform`
- **Рис. 5**: Працюючий сайт за URL (відкритий у браузері)

## Аналіз дрейфу конфігурації (drift)
1) Відкрий Vercel → проєкт `lab6-terraform` → Settings.
2) Вручну змініть щось, що Terraform контролює (наприклад **Project Name**).
3) У терміналі (в `terraform/`) запустіть:

```powershell
terraform plan
```

4) У звіті коротко опишіть, що Terraform:
- виявив розбіжність між **state** і реальним ресурсом
- пропонує зміни, щоб повернути інфраструктуру до описаного стану (або навпаки — оновити state при застосуванні).

