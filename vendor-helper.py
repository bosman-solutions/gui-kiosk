#!/usr/bin/env python3

import os
import sys
import json
import hashlib
import urllib.request
import logging
from typing import Dict
import time

# ─── Configuration ─────────────────────────────────────────────────────────────
VENDOR_JSON = "vendor.json"
LOCK_FILE = ".vendor.lock"
VENDOR_DIR = "vendor"

# ─── Logger Setup ──────────────────────────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
)

# ─── SHA256 Hash Function ──────────────────────────────────────────────────────
def sha256sum(path: str) -> str:
    """
    Compute the SHA-256 hash of a file.
    Uses buffered reads to avoid high memory use on large files.
    Returns the hash as a hex string, or "" on failure.
    """
    h = hashlib.sha256()
    try:
        with open(path, "rb") as f:
            for chunk in iter(lambda: f.read(8192), b""):
                h.update(chunk)
        return h.hexdigest()
    except FileNotFoundError:
        logging.error(f"File not found during hashing: {path}")
        return ""
    except Exception as e:
        logging.error(f"Hashing failed for {path}: {e}")
        return ""

# ─── Download Function ─────────────────────────────────────────────────────────
def download_file(url: str, dest: str) -> None:
    """
    Download a file from the given URL to the destination path.
    Raises if the download fails.
    """
    try:
        logging.info(f"Downloading {os.path.basename(dest)}...")
        urllib.request.urlretrieve(url, dest)
    except Exception as e:
        logging.error(f"Download failed: {url} → {dest}: {e}")
        raise

# ─── JSON Loader ───────────────────────────────────────────────────────────────
def load_json_file(path: str) -> Dict[str, str]:
    """
    Load a JSON file into a dictionary.
    Returns an empty dict if file is missing.
    Fails hard if file is malformed.
    """
    try:
        with open(path, "r") as f:
            return json.load(f)
    except FileNotFoundError:
        logging.warning(f"{path} not found. Proceeding with empty set.")
        return {}
    except json.JSONDecodeError as e:
        logging.error(f"{path} is not valid JSON: {e}")
        sys.exit(1)
    except Exception as e:
        logging.error(f"Unexpected error reading {path}: {e}")
        sys.exit(1)

# ─── Lockfile Writer ───────────────────────────────────────────────────────────
def save_lockfile(hashes: Dict[str, str]) -> None:
    """
    Write the hash map to the lockfile.
    Used to track exact versions of downloaded files.
    """
    try:
        with open(LOCK_FILE, "w") as f:
            json.dump(hashes, f, indent=2)
        logging.info("Lockfile updated.")
    except Exception as e:
        logging.error(f"Failed to write lockfile: {e}")
        sys.exit(1)

# ─── Check Current State ───────────────────────────────────────────────────────
def vendor_status(vendors: Dict[str, str]) -> bool:
    """
    Returns True if vendor directory exists and all expected files are present.
    Verifies file existence and optionally hashes.
    """
    if not os.path.isdir(VENDOR_DIR):
        logging.warning("Vendor directory does not exist.")
        return False

    missing = []
    for filename in vendors:
        filepath = os.path.join(VENDOR_DIR, filename)
        if not os.path.exists(filepath):
            missing.append(filename)

    if missing:
        logging.warning(f"Missing vendor files: {missing}")
        return False

    logging.info("All expected vendor files are present.")
    return True

# ─── Prompt Logic ──────────────────────────────────────────────────────────────
def prompt_force_refresh() -> bool:
    """
    Prompt user to confirm refresh.
    """
    resp = input("Everything looks good. Force refresh? [y/N]: ").strip().lower()
    if resp != "y":
        return False

    print("This will overwrite all vendor files. Waiting 2s to continue...")
    time.sleep(2)
    resp2 = input("Are you absolutely sure? [y/N]: ").strip().lower()
    return resp2 == "y"

# ─── Main Logic ────────────────────────────────────────────────────────────────
def main() -> None:
    os.makedirs(VENDOR_DIR, exist_ok=True)

    vendors = load_json_file(VENDOR_JSON)
    lock = load_json_file(LOCK_FILE)
    updated_lock: Dict[str, str] = {}

    if vendor_status(vendors):
        if not prompt_force_refresh():
            logging.info("Aborting without changes.")
            return

    for filename, url in vendors.items():
        dest = os.path.join(VENDOR_DIR, filename)

        try:
            if os.path.exists(dest):
                current_hash = sha256sum(dest)
                expected_hash = lock.get(filename)

                if current_hash == expected_hash:
                    logging.info(f"{filename} is up to date.")
                    updated_lock[filename] = current_hash
                    continue
                else:
                    logging.warning(f"{filename} hash mismatch. Will re-download.")
            else:
                logging.info(f"{filename} is missing. Will download.")

            download_file(url, dest)
            final_hash = sha256sum(dest)

            if final_hash:
                updated_lock[filename] = final_hash

        except Exception as e:
            logging.error(f"Could not process {filename}: {e}")

    if updated_lock:
        save_lockfile(updated_lock)
    else:
        logging.info("No updates made. Lockfile unchanged.")

    logging.info("Vendor fetch complete.")

# ─── Entrypoint ───────────────────────────────────────────────────────────────
if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        logging.warning("Interrupted by user.")
        sys.exit(1)
