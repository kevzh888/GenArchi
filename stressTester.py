import concurrent.futures
import time
import math

def cpu_intensive_task(duration):
    end_time = time.time() + duration
    result = 0
    while time.time() < end_time:
        result += math.factorial(100)
    return result

def stress_test(cpu_cores, duration):
    print(f"Starting CPU stress test with {cpu_cores} cores for {duration} seconds...")
    start_time = time.time()
    
    with concurrent.futures.ThreadPoolExecutor(max_workers=cpu_cores) as executor:
        futures = [executor.submit(cpu_intensive_task, duration) for _ in range(cpu_cores)]
        concurrent.futures.wait(futures)

    elapsed_time = time.time() - start_time
    print(f"Stress test completed in {elapsed_time:.2f} seconds.")

if __name__ == "__main__":
    cpu_cores = int(input("Enter the number of CPU cores to stress: "))
    duration = int(input("Enter the duration of the stress test in seconds: "))
    
    stress_test(cpu_cores, duration)
