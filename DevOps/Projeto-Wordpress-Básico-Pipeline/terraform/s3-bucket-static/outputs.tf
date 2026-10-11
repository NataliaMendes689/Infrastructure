output "bucket_name" {
  description = "Name of the created bucket."
  value       = aws_s3_bucket.static_site.id
}

output "bucket_arn" {
  value = aws_s3_bucket.static_site.arn
}

output "website_endpoint" {
  description = "HTTP endpoint serving the site. S3 website hosting is HTTP only; put CloudFront in front for TLS."
  value       = aws_s3_bucket_website_configuration.static_site.website_endpoint
}
