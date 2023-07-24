from requests_ratelimiter import LimiterSession
from time import time
import os

value = os.getenv("ACCESS_KEY", default=None)
session = LimiterSession(per_second=5)
start = time()
headers = {
    'Ocp-Apim-Subscription-Key': value
}
for _ in range(60):
    response = session.get(f'https://svr-test-dev-api-management.azure-api.net/health/health', headers=headers)
    print(response.status_code)
    session.get(f'https://svr-test-dev-api-management.azure-api.net/health/health', headers=headers)
    print(response.status_code)