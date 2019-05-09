cat "${1}" | sed "s%^Content-Length:.*%Content-Length: $(./content-length.sh)%"
