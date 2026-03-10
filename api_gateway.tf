resource "aws_apigatewayv2_api" "video_api" {
  name          = "video-processing-api"
  protocol_type = "HTTP"
}

# Integration apontando para o backend HTTP
resource "aws_apigatewayv2_integration" "video_backend" {
  api_id                 = aws_apigatewayv2_api.video_api.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "ANY"
  integration_uri        = var.backend_base_url
  payload_format_version = "1.0"
}

# POST /videos  (upload multipart/form-data)
resource "aws_apigatewayv2_route" "post_videos" {
  api_id    = aws_apigatewayv2_api.video_api.id
  route_key = "POST /videos"
  target    = "integrations/${aws_apigatewayv2_integration.video_backend.id}"
}

# GET /videos/{videoId}
resource "aws_apigatewayv2_route" "get_video_by_id" {
  api_id    = aws_apigatewayv2_api.video_api.id
  route_key = "GET /videos/{videoId}"
  target    = "integrations/${aws_apigatewayv2_integration.video_backend.id}"
}

# GET /users/{userId}/videos
resource "aws_apigatewayv2_route" "get_user_videos" {
  api_id    = aws_apigatewayv2_api.video_api.id
  route_key = "GET /users/{userId}/videos"
  target    = "integrations/${aws_apigatewayv2_integration.video_backend.id}"
}

# GET /health
resource "aws_apigatewayv2_route" "health" {
  api_id    = aws_apigatewayv2_api.video_api.id
  route_key = "GET /health"
  target    = "integrations/${aws_apigatewayv2_integration.video_backend.id}"
}

# Stage
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.video_api.id
  name        = "$default"
  auto_deploy = true
}

output "api_invoke_url" {
  value = aws_apigatewayv2_api.video_api.api_endpoint
}
