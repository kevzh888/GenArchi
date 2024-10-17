variable "var_dynamodb_table_name" {
  description = "Le nom de la table DynamoDB."
  type        = string
}

variable "var_billing_mode" {
  description = "Le mode de facturation pour la table DynamoDB."
  type        = string
  default     = "PROVISIONED"  
}

variable "var_hash_key" {
  description = "La clé de hachage pour la table DynamoDB."
  type        = string
  default     = "quote_id"  
}

variable "var_stream_enabled" {
  description = "Si les flux DynamoDB doivent être activés."
  type        = bool
  default     = true  
}

variable "var_stream_view_type" {
  description = "Le type de vue pour DynamoDB Streams."
  type        = string
  default     = "NEW_IMAGE"  
}
