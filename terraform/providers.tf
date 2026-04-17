terraform {
  required_version = ">= 1.2.0"

  required_providers {
    vercel = {
      source  = "vercel/vercel"
      # v1.x не підтримує нові токени формату vcp_... (які показує UI Vercel)
      # Оновлюємо провайдер, щоб Terraform міг прийняти такі токени.
      version = "~> 3.0"
    }
  }
}

provider "vercel" {
  api_token = var.vercel_api_token
}

