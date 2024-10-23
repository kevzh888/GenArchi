#!/bin/bash

# --- Variables ---
ANSIBLE_PLAYBOOK_SETUP_SHARD="ansible/playbooks/setup_shard.yml"
ANSIBLE_PLAYBOOK_COMMON="ansible/playbooks/common.yml"
ANSIBLE_PLAYBOOK_DB_SETUP="ansible/playbooks/db_setup.yml"
INVENTORY_SCRIPT="ansible/inventory/dynamic_inventory.py"
TERRAFORM_DIR="terraform"
ANSIBLE_DIR="ansible"
MYSQL_ROOT_PASSWORD="YourPassword"  # Change this or make it dynamic if needed

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
print_message "Application du plan Terraform..."
terraform apply -auto-approve || { print_error "Erreur lors de l'application du plan Terraform"; exit 1; }

# --- Étape 3 : Extraction des IPs via Terraform Output ---
print_message "Récupération des adresses IP des shards..."
terraform output -json > ../$ANSIBLE_DIR/terraform_output.json || { print_error "Erreur lors de l'extraction des IPs"; exit 1; }

# --- Étape 4 : Vérification du script d'inventaire dynamique ---
print_message "Vérification du script d'inventaire dynamique..."
cd ../$ANSIBLE_DIR || { print_error "Dossier Ansible introuvable"; exit 1; }
if [ ! -f "$INVENTORY_SCRIPT" ]; then
    print_error "Le script d'inventaire dynamique est introuvable : $INVENTORY_SCRIPT"
    exit 1
fi

# --- Étape 5 : Exécution du Playbook Common ---
print_message "Exécution du playbook 'common.yml' pour configurer les tâches générales..."
ansible-playbook -i $INVENTORY_SCRIPT $ANSIBLE_PLAYBOOK_COMMON --extra-vars "mysql_root_password=$MYSQL_ROOT_PASSWORD" || { print_error "Erreur lors de l'exécution du playbook 'common.yml'"; exit 1; }

# --- Étape 6 : Exécution du Playbook DB Setup ---
print_message "Exécution du playbook 'db_setup.yml' pour configurer la base de données..."
ansible-playbook -i $INVENTORY_SCRIPT $ANSIBLE_PLAYBOOK_DB_SETUP --extra-vars "mysql_root_password=$MYSQL_ROOT_PASSWORD" || { print_error "Erreur lors de l'exécution du playbook 'db_setup.yml'"; exit 1; }

# --- Étape 7 : Exécution du Playbook Setup Shard ---
print_message "Exécution du playbook 'setup_shard.yml' pour configurer les shards MySQL..."
ansible-playbook -i $INVENTORY_SCRIPT $ANSIBLE_PLAYBOOK_SETUP_SHARD --extra-vars "mysql_root_password=$MYSQL_ROOT_PASSWORD" || { print_error "Erreur lors de l'exécution du playbook 'setup_shard.yml'"; exit 1; }

# --- Fin du processus ---
print_message "Déploiement terminé avec succès !"
