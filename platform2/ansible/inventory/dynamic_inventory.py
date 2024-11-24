#!/usr/bin/env python

import os
import json
import subprocess

# Obtenir la sortie Terraform sous format JSON
def get_terraform_output():
    try:
        # Appel à la commande 'terraform output -json'
        result = subprocess.run(
            ["terraform", "output", "-json"],
            capture_output=True,
            check=True,
            text=True
        )
        return json.loads(result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"Erreur lors de l'exécution de Terraform: {e}")
        exit(1)

# Générer l'inventaire Ansible
def generate_inventory(terraform_output):
    # Extraire les IPs des shards de la sortie Terraform
    shard_ips = terraform_output.get('db_shard_ips', {}).get('value', [])

    # Construction de l'inventaire Ansible au format JSON
    inventory = {
        "db_shards": {
            "hosts": shard_ips
        },
        "_meta": {
            "hostvars": {}
        }
    }

    return json.dumps(inventory, indent=2)

if __name__ == "__main__":
    # Obtenir la sortie de Terraform
    terraform_output = get_terraform_output()

    # Générer et afficher l'inventaire dynamique
    inventory = generate_inventory(terraform_output)
    print(inventory)
