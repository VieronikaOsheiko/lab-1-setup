locals {
  project_name = "lab6-terraform"
  domain_name  = "lab6-${var.student_id}.vercel.app"
}

resource "vercel_project" "lab_deployment" {
  name = local.project_name

  # Monorepo: our Vite app lives in /lab-1-setup
  root_directory = "lab-1-setup"

  # Make build deterministic for the lab report
  install_command = "npm ci"
  build_command   = "npm run build"
  output_directory = "dist"

  git_repository = {
    type = "github"
    repo = var.github_repo
  }
}

resource "vercel_project_domain" "custom_domain" {
  project_id = vercel_project.lab_deployment.id
  domain     = local.domain_name
}

