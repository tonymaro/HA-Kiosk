from flask import Flask, request, jsonify
import subprocess
import logging
import os
import re
from urllib.parse import urlparse

app = Flask(__name__)

logging.basicConfig(level=logging.DEBUG)

# Define your shell scripts and their corresponding endpoints
scripts = {
    "playstream": "~/Scripts/choosestream.sh",
    "playavatar": "~/Scripts/playavatar.sh",
    "dashboard": "~/Scripts/dashboard.sh",
    "noscreen": "~/Scripts/noscreen.sh",
    "start_slideshow": "~/Scripts/start_slideshow.sh",
    "nightlight":"~/Scripts/nightlight.sh",
    "listening":"~/Scripts/play_listening.sh",
    "rotate_roku":"~/Scripts/rotate_roku.sh",
    "rotate_dashboard":"~/Scripts/rotate_dashboard.sh"
}

# Functions to sanitize the parameters passed
def sanitize_directory_name(dir_name):
    if not (dir_name):
        return ""
    if len(dir_name) > 255:
        raise ValueError("Directory name too long")
    if not re.match(r'^[\w-]+$', dir_name):
        raise ValueError("Invalid directory name")

    # Normalize the path and check if it contains any path traversal
    normalized_path = os.path.normpath(dir_name)
    if normalized_path != dir_name:
        return ""

    return dir_name

def is_valid_url(url):
    try:
        result = urlparse(url)
        # Check if the scheme is one of the allowed types
        if result.scheme in ['http', 'https', 'rtsp']:
            # Ensure that both netloc (hostname) and path are present
            return bool(result.netloc) and bool(result.path)
        return False
    except Exception:
        return False

def sanitize_url_input(url):
    url = url.strip()
    if not is_valid_url(url):
        return ""
    return url



@app.route('/run/<script_name>', methods=['POST'])
def run_script(script_name):

  #logging.debug("Running script")

  if script_name not in scripts:
    return jsonify({"error": "Script not found"}), 404

  #logging.debug("Getting args")

  # Get arguments from the request
  args = request.json.get('args', [])

  # ensure args are valid in form of directory / url for 1 and 2
  if args:
    args[0] = sanitize_directory_name(args[0])
  if args and len(args) > 1:
    args[1] = sanitize_url_input(args[1])

  logging.debug("Arguments = ")
  logging.debug(args)

  script_path = os.path.expanduser(scripts[script_name])

  # Construct the command
  command = [script_path] + args

  # Fork the process to run the script in the background
  try:
      subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
      return jsonify({"message": "Script is running in the background"}), 202
  except Exception as e:
      return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='192.168.5.3', port=5000, debug=True)

