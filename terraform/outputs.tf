output "vercel_project_id" {
  value = vercel_project.lab_deployment.id
}

output "vercel_domain" {
  value = vercel_project_domain.custom_domain.domain
}

