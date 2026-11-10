# Helpers for images/<name>/check.sh. Each published guest port P is reachable
# at $(addr P), on 127.0.0.1.
addr() { local v="ADDR_$1"; echo "${!v:?port $1 is not published (PORTS)}"; }

# http <port> <path> [curl args...]: the body of a successful response.
http() {
	local port="$1" path="$2"
	shift 2
	curl -fsS --max-time 10 "$@" "http://$(addr "${port}")${path}"
}

# http_status <port> <path> [curl args...]: the response's status code.
http_status() {
	local port="$1" path="$2"
	shift 2
	curl -sS --max-time 10 -o /dev/null -w '%{http_code}' "$@" "http://$(addr "${port}")${path}"
}

# expect <haystack> <needle> [what]: fails, showing both, unless haystack
# contains needle.
expect() {
	case "$1" in
	*"$2"*) ;;
	*) echo "expected ${3:-output} to contain: $2" >&2; printf '%s\n' "$1" | head -c 2000 >&2; echo >&2; return 1 ;;
	esac
}

# tcp <port> <bytes> [seconds]: sends bytes (printf format) and prints what
# comes back until the peer is quiet for the given seconds (default 1).
tcp() {
	python3 - "$(addr "$1")" "$2" "${3:-1}" <<'PY'
import socket,sys
host,port=sys.argv[1].rsplit(':',1)
data=sys.argv[2].encode().decode('unicode_escape').encode('latin-1')
with socket.create_connection((host,int(port)),timeout=10) as s:
    s.sendall(data)
    s.settimeout(float(sys.argv[3]))
    out=b''
    try:
        while True:
            b=s.recv(65536)
            if not b:break
            out+=b
    except socket.timeout:
        pass
sys.stdout.write(out.decode('latin-1'))
PY
}

# udp <port> <hex payload>: sends one datagram and prints the reply as hex.
udp() {
	python3 - "$(addr "$1")" "$2" <<'PY'
import socket,sys
host,port=sys.argv[1].rsplit(':',1)
with socket.socket(socket.AF_INET,socket.SOCK_DGRAM) as s:
    s.settimeout(5)
    s.sendto(bytes.fromhex(sys.argv[2]),(host,int(port)))
    print(s.recvfrom(65535)[0].hex())
PY
}

# resp <port> <command...>: sends Redis/Valkey inline commands, one per
# argument, and prints the replies.
resp() {
	local port="$1" payload=""
	shift
	for c in "$@"; do payload+="${c}\r\n"; done
	tcp "${port}" "${payload}"
}

# wait_for <seconds> <command...>: runs the command until it succeeds.
wait_for() {
	local limit="$1" start=${SECONDS}
	shift
	until "$@"; do
		[ $((SECONDS - start)) -lt "${limit}" ] || { echo "timed out after ${limit}s: $*" >&2; return 1; }
		sleep 1
	done
}

# dns_query <port> <name> [type]: one UDP query (type A by default); prints
# the reply as hex.
dns_query() {
	local hex
	hex="$(python3 - "$2" "${3:-1}" <<'PY'
import struct,sys
name,qtype=sys.argv[1],int(sys.argv[2])
q=struct.pack('>HHHHHH',0x4a42,0x0100,1,0,0,0)
for label in name.rstrip('.').split('.'):
    q+=bytes([len(label)])+label.encode()
q+=b'\0'+struct.pack('>HH',qtype,1)
print(q.hex())
PY
)"
	udp "$1" "${hex}"
}

# oci_push <port> <repository> <tag>: pushes a one-layer OCI image through
# the distribution API (a blob upload each, then the manifest).
# oci_pull <port> <repository> <tag>: fetches the manifest and the layer back
# and checks the layer's content.
oci() { python3 - "$(addr "$1")" "$2" "$3" "$4" <<'PY'
import hashlib,json,sys,urllib.request
addr,repo,tag,mode=sys.argv[1:]
base=f'http://{addr}/v2/{repo}'
layer=b'jerboa official image test layer\n'
config=json.dumps({'architecture':'amd64','os':'linux','rootfs':{'type':'layers','diff_ids':['sha256:'+hashlib.sha256(layer).hexdigest()]}}).encode()
def d(b):return 'sha256:'+hashlib.sha256(b).hexdigest()
def req(method,url,data=None,headers={}):
    r=urllib.request.Request(url,data=data,method=method,headers=headers)
    return urllib.request.urlopen(r,timeout=30)
manifest=json.dumps({'schemaVersion':2,'mediaType':'application/vnd.oci.image.manifest.v1+json',
  'config':{'mediaType':'application/vnd.oci.image.config.v1+json','digest':d(config),'size':len(config)},
  'layers':[{'mediaType':'application/vnd.oci.image.layer.v1.tar','digest':d(layer),'size':len(layer)}]}).encode()
if mode=='push':
    for blob in (layer,config):
        loc=req('POST',base+'/blobs/uploads/').headers['Location']
        if loc.startswith('/'):loc=f'http://{addr}'+loc
        sep='&' if '?' in loc else '?'
        req('PUT',loc+sep+'digest='+d(blob),blob,{'Content-Type':'application/octet-stream'})
    req('PUT',f'{base}/manifests/{tag}',manifest,{'Content-Type':'application/vnd.oci.image.manifest.v1+json'})
    print('pushed',repo+':'+tag,d(manifest))
else:
    m=json.load(req('GET',f'{base}/manifests/{tag}',headers={'Accept':'application/vnd.oci.image.manifest.v1+json'}))
    got=req('GET',base+'/blobs/'+m['layers'][0]['digest']).read()
    assert got==layer,'layer content differs'
    print('pulled',repo+':'+tag)
PY
}
oci_push() { oci "$1" "$2" "$3" push; }
oci_pull() { oci "$1" "$2" "$3" pull; }
