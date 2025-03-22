#!/bin/bash

# --- Camera Configuration ---
CAMERA_IP="C200.home.mackintosh.me"
USERNAME="homeassistant"
PASSWORD="secret"
CAMERA_PORT="2020"
PROFILE_TOKEN="Profile_1"  # Update if needed

PTZ_URL="http://$CAMERA_IP:$CAMERA_PORT/onvif/ptz_service"

# --- Generate WSSE Header ---

generate_wsse() {
  NONCE_RAW=$(openssl rand -hex 16)
  CREATED=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  # Prepare Base64 Nonce (for header)
  NONCE_B64=$(echo "$NONCE_RAW" | xxd -r -p | base64)

  # Create password digest without storing binary in a variable
  DIGEST=$( {
    echo -n "$NONCE_RAW" | xxd -r -p
    echo -n "$CREATED$PASSWORD"
  } | openssl dgst -sha1 -binary | base64 )

  cat <<EOF
<wsse:Security soap:mustUnderstand="1"
  xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"
  xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">
  <wsse:UsernameToken>
    <wsse:Username>$USERNAME</wsse:Username>
    <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordDigest">$DIGEST</wsse:Password>
    <wsse:Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">$NONCE_B64</wsse:Nonce>
    <wsu:Created>$CREATED</wsu:Created>
  </wsse:UsernameToken>
</wsse:Security>
EOF
}

# --- GetNodes Request (check zoom capability) ---
send_get_nodes() {
  WSSE_HEADER=$(generate_wsse)
  cat <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope"
               xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"
               xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"
               xmlns:ptz="http://www.onvif.org/ver20/ptz/wsdl">
  <soap:Header>
    $WSSE_HEADER
  </soap:Header>
  <soap:Body>
    <ptz:GetNodes/>
  </soap:Body>
</soap:Envelope>
EOF
}

# --- Continuous Zoom Move Request ---
send_zoom_move() {
  local zoom="$1"
  WSSE_HEADER=$(generate_wsse)

  cat <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope"
               xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"
               xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"
               xmlns:tt="http://www.onvif.org/ver10/schema"
               xmlns:ptz="http://www.onvif.org/ver20/ptz/wsdl">
  <soap:Header>
    $WSSE_HEADER
  </soap:Header>
  <soap:Body>
    <ptz:ContinuousMove>
      <ptz:ProfileToken>$PROFILE_TOKEN</ptz:ProfileToken>
      <ptz:Velocity>
        <tt:PanTilt x="0.0" y="0.0"/>
        <tt:Zoom x="$zoom"/>
      </ptz:Velocity>
    </ptz:ContinuousMove>
  </soap:Body>
</soap:Envelope>
EOF
}

# --- Execute Tests ---

echo "[*] Sending GetNodes to inspect zoom capability..."
curl -s -X POST "$PTZ_URL" \
  -H "Content-Type: application/soap+xml; charset=utf-8" \
  -d "$(send_get_nodes)" | tee >(grep -E 'Zoom|XRange|Min|Max|PanTilt')

echo
echo "[*] Testing zoom-in with 0.5..."
curl -s -X POST "$PTZ_URL" \
  -H "Content-Type: application/soap+xml; charset=utf-8" \
  -d "$(send_zoom_move 0.5)"

sleep 2

echo
echo "[*] Testing zoom-out with -0.5..."
curl -s -X POST "$PTZ_URL" \
  -H "Content-Type: application/soap+xml; charset=utf-8" \
  -d "$(send_zoom_move -0.5)"

echo
echo "[✓] Done. Check if zoom physically moved."


