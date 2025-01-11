import requests

# My Pastebin API key
PASTEBIN_API_KEY = "###"
# We are just gonna hardcode dennis' info for now
SCRIPT_PATH = ".\pastebin\dennis.lua"
PASTEBIN_TITLE = "Dennis"

def upload_to_pastebin(api_key, script_path, title):
    with open(script_path, 'r') as file:
        script_content = file.read()

    data = {
        'api_dev_key': api_key,
        'api_option': 'paste',
        'api_paste_code': script_content,
        'api_paste_name': title,
        'api_paste_expire_date': 'N',
        'api_paste_format': 'lua',
    }


    response = requests.post("https://pastebin.com/api/api_post.php", data=data)

    if response.status_code == 200:
        return response.text
    else:
        raise Exception(f"Error uploading to Pastebin: {response.text}")


def main():
  try:
    pastebin_url = upload_to_pastebin(PASTEBIN_API_KEY, SCRIPT_PATH, PASTEBIN_TITLE)
    pastebin_command = f"pastebin get {pastebin_url.split('/')[-1]} tood.lua"
    print(f"Script uploaded to Pastebin: {pastebin_url}")
    print(f"Script download command: {pastebin_command}")
    print(f"Script replace command: os.remove('tood.lua') {pastebin_command}")
    
    # Save the Pastebin link to a file
    with open('pastebin_url.txt', 'w') as url_file:
      url_file.write(pastebin_command)
  except Exception as e:
    print(e)

if __name__ == "__main__":
  main()
