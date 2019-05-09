Usage
-----

[Install Wireguard first](https://github.com/subspacecloud/subspace#install-wireguard-on-the-host)

Build docker container:
```
docker build -t subspace https://github.com/ilyaglow/docker-subspace.git
```

Run container:
```
docker run -itd \
    --name subspace \
    --restart always \
    --network host \
    --cap-add NET_ADMIN \
    --volume /usr/bin/wg:/usr/bin/wg \
    --volume ./data:/data \
    --env SUBSPACE_HTTP_HOST=subspace.example.com \
    subspace
```
