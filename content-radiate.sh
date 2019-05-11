cat "${1}" | sed "s%^Content-Length:.*%Content-Length: $(./content-length.sh)%; s%Last-Modified:.*%Last-Modified: $(./content-modified.sh)%; "
