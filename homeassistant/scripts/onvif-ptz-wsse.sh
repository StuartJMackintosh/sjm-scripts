#!/bin/bash

# --- Camera Configuration ---
CAMERA_IP="C200.home.mackintosh.me"
USERNAME="homeassistant"
PASSWORD="secret"
CAMERA_PORT="2020"
PROFILE_TOKEN="Profile_1"  # You can dynamically fetch this if needed

# --- Endpoint ---
PTZ_URL="http://$CAMERA_IP:$CAMERA_PORT/onvif/ptz_service"

# --- Movement Duration ---
MOVE_TIME=1.0

# --- Generate WS-Security Header ---

generate_wsse() {
  NONCE_RAW=$(openssl rand -hex 16)                             # 16-byte nonce in hex
  NONCE_BIN=$(echo "$NONCE_RAW" | xxd -r -p)                    # convert hex to binary
  NONCE_B64=$(echo -n "$NONCE_BIN" | base64)                    # base64 for header
  CREATED=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  # Digest = Base64( SHA1( nonce_bin + created + password ) )
  DIGEST=$( (echo -n "$NONCE_BIN"; echo -n "$CREATED$PASSWORD") | openssl dgst -sha1 -binary | base64)

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

# --- Build SOAP Envelope ---
build_ptz_move_request() {
  local pan="$1"
  local tilt="$2"
  local zoom="$3"
  local wsse_header=$(generate_wsse)

  cat <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope"
               xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"
               xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"
               xmlns:tt="http://www.onvif.org/ver10/schema"
               xmlns:ptz="http://www.onvif.org/ver20/ptz/wsdl">
  <soap:Header>
    $wsse_header
  </soap:Header>
  <soap:Body>
    <ptz:ContinuousMove>
      <ptz:ProfileToken>$PROFILE_TOKEN</ptz:ProfileToken>
      <ptz:Velocity>
        <tt:PanTilt x="$pan" y="$tilt"/>
        <tt:Zoom x="$zoom"/>
      </ptz:Velocity>
    </ptz:ContinuousMove>
  </soap:Body>
</soap:Envelope>
EOF
}

build_ptz_stop_request() {
  local wsse_header=$(generate_wsse)

  cat <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope"
               xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"
               xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"
               xmlns:ptz="http://www.onvif.org/ver20/ptz/wsdl">
  <soap:Header>
    $wsse_header
  </soap:Header>
  <soap:Body>
    <ptz:Stop>
      <ptz:ProfileToken>$PROFILE_TOKEN</ptz:ProfileToken>
      <ptz:PanTilt>true</ptz:PanTilt>
      <ptz:Zoom>true</ptz:Zoom>
    </ptz:Stop>
  </soap:Body>
</soap:Envelope>
EOF
}

send_ptz_command() {
  local body="$1"
  curl -s -X POST "$PTZ_URL" \
    -H "Content-Type: application/soap+xml; charset=utf-8" \
    -d "$body"
}

move_and_stop() {
  local pan="$1"
  local tilt="$2"
  local zoom="$3"
  echo "[*] Moving: pan=$pan, tilt=$tilt, zoom=$zoom"
  send_ptz_command "$(build_ptz_move_request "$pan" "$tilt" "$zoom")"
  sleep "$MOVE_TIME"
  send_ptz_command "$(build_ptz_stop_request)"
}

# --- Command-Line Parsing ---
case "$1" in
  --left)      move_and_stop -0.3  0.0  0.0 ;;
  --right)     move_and_stop  0.3  0.0  0.0 ;;
  --up)        move_and_stop  0.0  0.5  0.0 ;;
  --down)      move_and_stop  0.0 -0.5  0.0 ;;
  --zoom-in)   move_and_stop  0.0  0.0  0.5 ;;
  --zoom-out)  move_and_stop  0.0  0.0 -0.5 ;;
  --help|-h)
    echo "Usage: $0 [--left|--right|--up|--down|--zoom-in|--zoom-out]"
    exit 0
    ;;
  *)
    echo "[!] Unknown or missing argument"
    echo "Usage: $0 [--left|--right|--up|--down|--zoom-in|--zoom-out]"
    exit 1
    ;;
esac


