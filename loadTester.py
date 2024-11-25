import requests
import json
import time
import threading
from concurrent.futures import ThreadPoolExecutor
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry

def create_session():
    session = requests.Session()
    retry_strategy = Retry(
        total=3,
        backoff_factor=0.1,
        status_forcelist=[500, 502, 503, 504]
    )
    adapter = HTTPAdapter(max_retries=retry_strategy, pool_connections=50, pool_maxsize=50)
    session.mount("http://", adapter)
    session.mount("https://", adapter)
    return session

def send_request(session, endpoint, body):
    try:
        headers = {'Content-Type': 'application/json'}
        if body:
            response = session.post(endpoint, json=body, headers=headers)
        else:
            response = session.get(endpoint, headers=headers)
        print(f"Response Code: {response.status_code}, Response Body: {response.text}")
    except Exception as e:
        print(f"Error: {e}")

def load_test(endpoint, num_requests, duration, body=None):
    if body:
        body = json.loads(body)
    
    interval = duration / num_requests
    print(f"Starting load test: {num_requests} requests over {duration} seconds.")
    
    session = create_session()
    with ThreadPoolExecutor(max_workers=num_requests) as executor:
        for _ in range(num_requests):
            executor.submit(send_request, session, endpoint, body)
            time.sleep(interval)
    
    print("Load test completed.")

if __name__ == "__main__":
    endpoint = "http://" + input("Endpoint à atteindre: ") + "/api/quotes"
    num_requests = int(input("Nombre de requêtes: "))
    duration = int(input("Durée totale d'exécution: "))
    body = "{\"quote\": " + "\"" + input("Body JSON de la requête (laisser vide si GET): ") + "\"}"
    body = body if body.strip() else None
    load_test(endpoint, num_requests, duration, body)