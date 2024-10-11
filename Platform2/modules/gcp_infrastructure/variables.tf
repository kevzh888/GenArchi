variable "delete_disk" {
  description = "Détermine si le disque doit être supprimé"
  type        = bool
  default     = false # Changez à true si vous voulez supprimer le disque
}

variable "delete_image" {
  description = "Détermine si l'image doit être supprimée"
  type        = bool
  default     = false # Changez à true si vous voulez supprimer l'image
}
