import requests
import json
import time
import threading

def send_request(endpoint, body):
    try:
        headers = {'Content-Type': 'application/json'}
        if body:
            response = requests.post(endpoint, data=json.dumps(body), headers=headers)
        else:
            response = requests.get(endpoint, headers=headers)
        
        print(f"Response Code: {response.status_code}, Response Body: {response.text}")
    except Exception as e:
        print(f"Error: {e}")

def load_test(endpoint, num_requests, duration, body=None):
    if body:
        body = json.loads(body)
    
    interval = duration / num_requests

    print(f"Starting load test: {num_requests} requests over {duration} seconds.")
    
    threads = []

    for i in range(num_requests):
        thread = threading.Thread(target=send_request, args=(endpoint, body))
        threads.append(thread)
        thread.start()
        time.sleep(interval)
    
    for thread in threads:
        thread.join()
    
    print("Load test completed.")

if __name__ == "__main__":
    endpoint = input("Endpoint à atteindre: ")
    num_requests = int(input("Nombre de requêtes: "))
    duration = int(input("Durée totale d'exécution: "))
    body = input("Body JSON de la requête (laisser vide si GET): ")
    body = body if body.strip() else None

    load_test(endpoint, num_requests, duration, body)
