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

# --- Étape 1 : Initialisation de Terraform ---
print_message "Initialisation de Terraform..."
cd $TERRAFORM_DIR || { print_error "Dossier Terraform introuvable"; exit 1; }
terraform init || { print_error "Erreur lors de l'initialisation de Terraform"; exit 1; }

# --- Étape 2 : Application du plan Terraform ---
print_message "Création du plan Terraform..."
terraform plan -var-file="$VAR_FILE" || { print_error "Erreur lors de la création du plan Terraform"; exit 1; }

# --- Étape 3 : Application du plan Terraform ---
print_message "Application du plan Terraform..."
terraform apply -var-file="$VAR_FILE" -auto-approve || { print_error "Erreur lors de l'application du plan Terraform"; exit 1; }

# --- Étape 4 : Extraction des IPs via Terraform Output ---
print_message "Récupération des adresses IP des db instances..."
terraform output -json > ../$TERRAFORM_DIR/terraform_output.json || { print_error "Erreur lors de l'extraction des IPs"; exit 1; }

# --- Fin du processus ---
print_message "Déploiement terminé avec succès !"
