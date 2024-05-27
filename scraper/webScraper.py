import requests
from bs4 import BeautifulSoup
from urllib.parse import urlparse, urljoin

base_url = "https://tweaked.cc/"
visited_urls = set()
urls_to_visit = set([base_url])

def scrape_site(current_url):
    if current_url in visited_urls:
        return
    try:
        print(f"Scraping {current_url}")
        response = requests.get(current_url)
        response.raise_for_status()   
    except requests.RequestException:
        return
    
    visited_urls.add(current_url)
    soup = BeautifulSoup(response.content, "html.parser")
    
    filename = urlparse(current_url).path
    if not filename:
        filename = "index"
    if filename.endswith("/"):
        filename += "index"
    with open(f"{filename.replace('/', '_')}.html", "wb") as file:
        file.write(response.content)
    
    for link in soup.find_all('a', href=True):
        url = link.get('href')
        parsed_url = urlparse(url)
        if parsed_url.netloc and parsed_url.netloc != urlparse(current_url).netloc:
            continue  # External URL, so skip it
        full_url = urljoin(current_url, url)
        if full_url not in visited_urls:
            urls_to_visit.add(full_url)

while urls_to_visit:
    current_url = urls_to_visit.pop()
    scrape_site(current_url)