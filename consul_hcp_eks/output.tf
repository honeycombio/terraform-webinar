output "cluster_name" {
  value = local.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_primary_security_group_id
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_route_table_id" {
  description = "The route table id for the public subnet"
  value       = module.vpc.public_route_table_ids
}

output "public_subnets" {
  description = "The subnets for the public subnet"
  value       = module.vpc.public_subnets
}

output "kubernetes_endpoint" {
  value = data.aws_eks_cluster.cluster.endpoint
}

output "kubernetes_certificate" {
  value = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}

output "kubernetes_token" {
  sensitive = true
  value     = data.aws_eks_cluster_auth.cluster.token
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "oidc_provider" {
  value = module.eks.oidc_provider
}

output "consul_root_token" {
  value     = hcp_consul_cluster_root_token.token.secret_id
  sensitive = true
}

output "consul_url" {
  value = hcp_consul_cluster.main.consul_public_endpoint_url
}