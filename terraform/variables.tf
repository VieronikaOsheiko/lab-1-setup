variable "vercel_api_token" {
  description = "Vercel API Token for authentication"
  type        = string
  sensitive   = true
}

variable "student_id" {
  description = "Student ID for custom domain (e.g. surname, nickname)"
  type        = string
}

variable "github_repo" {
  description = "GitHub repo in format owner/repo (monorepo root)"
  type        = string
}

