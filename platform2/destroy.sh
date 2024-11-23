#!/bin/bash

# --- Variables ---
TERRAFORM_DIR="terraform"
ANSIBLE_DIR="ansible"
VAR_FILE="variables.tfvars"  # Ajout de la variable pour les credentials AWS

# --- Couleurs pour le feedback ---
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# --- Fonction pour afficher les messages ---
function print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

function print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# --- Étape 1 : Destruction des ressources de Terraform ---
print_message "Destruction des ressources de Terraform..."
cd $TERRAFORM_DIR || { print_error "Dossier Terraform introuvable"; exit 1; }
terraform destroy -var-file="$VAR_FILE" -auto-approve || { print_error "Erreur lors de la destruction des ressources Terraform"; exit 1; }

# --- Fin du processus ---
print_message "Destruction terminé avec succès !"
