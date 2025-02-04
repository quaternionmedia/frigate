podman run \
  --name frigate \
  --replace \
  --mount type=tmpfs,target=/tmp/cache,tmpfs-size=1000000000 \
  --device /dev/bus/usb:/dev/bus/usb \
  --device /dev/dri/renderD128 \
  --shm-size=64m \
  -v /home/harpo/frigate/storage/:/media/frigate/ \
  -v /home/harpo/frigate/config/:/config/ \
  -v /etc/localtime:/etc/localtime:ro \
  -e FRIGATE_RTSP_PASSWORD='password' \
  -p 8971:8971 \
  -p 8555:8555/tcp \
  -p 8555:8555/udp \
  -p 5000:5000 \
  ghcr.io/blakeblackshear/frigate:stable

