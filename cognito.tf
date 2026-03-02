# User Pool do Cognito
resource "aws_cognito_user_pool" "video_processing" {
  name = "video-processing-users"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  schema {
    attribute_data_type = "String"
    name                = "email"
    required            = true
    mutable             = true
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  tags = {
    Name        = "video-processing-user-pool"
    Environment = var.environment
  }
}

# App Client
resource "aws_cognito_user_pool_client" "video_processing_client" {
  name         = "video-processing-app-client"
  user_pool_id = aws_cognito_user_pool.video_processing.id

  generate_secret                      = false
  refresh_token_validity               = 30
  access_token_validity                = 60
  id_token_validity                    = 60
  token_validity_units {
    refresh_token = "days"
    access_token  = "minutes"
    id_token      = "minutes"
  }

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
}

# Domain para Hosted UI
resource "aws_cognito_user_pool_domain" "video_processing" {
  domain       = "video-processing-${random_string.suffix.result}"
  user_pool_id = aws_cognito_user_pool.video_processing.id
}
