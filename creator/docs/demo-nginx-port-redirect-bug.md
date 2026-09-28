# Demo nginx port-stripping redirect bug

## Status

Fixed. The cyber-dojo nginx image now sets `absolute_redirect off;`, so the
`^/$` rewrite emits a relative `Location: /creator/home` and the browser keeps
whatever port it is on. `creator/bin/demo.sh` opens the bare root URL again; the earlier
`/creator/home` workaround has been reverted.

## Symptom

`make creator_demo` (which runs `creator/bin/demo.sh`) brings the creator demo up correctly on
host port 81:

```
$ docker ps
... 0.0.0.0:81->80/tcp, [::]:81->80/tcp   creator-nginx-1
```

But the browser tab it opens lands on `http://localhost/creator/home` (port 80,
no port shown) instead of port 81. With the demo published on 81 (and nothing on
80), that page fails to load.

## Cause

`creator/bin/demo.sh` opened the bare root URL `http://localhost:81`. The cyber-dojo
nginx image rewrites `/` to `/creator/home` and issues it as an absolute 301
built from its own listen port, not the client's `Host` header. Because nginx
listens on 80 inside the container, the redirect target is port 80.

Evidence, taken against the running demo nginx on port 81:

```
$ curl -sSI http://localhost:81/
HTTP/1.1 301 Moved Permanently
Location: http://localhost/creator/home        <-- port 81 dropped

$ curl -sSI http://localhost:81/creator/home
HTTP/1.1 200 OK                                 <-- no redirect, stays on 81
```

Relevant nginx config (from `docker exec creator-nginx-1 nginx -T`):

```
listen 80;
server_name localhost;
rewrite ^/$ /creator/home permanent;
```

Chain of events:

1. `creator/bin/demo.sh` opens `http://localhost:81/`.
2. nginx matches `rewrite ^/$ /creator/home permanent;`.
3. With `absolute_redirect` on (the nginx default), nginx builds an absolute
   `Location` from `server_name` (`localhost`) and its internal listen port
   (`80`), ignoring the client `Host: localhost:81`. Result:
   `http://localhost/creator/home`.
4. The browser follows the 301 to port 80, where the creator demo is not
   published, so the page fails.

This only affects the bare `/` path. `/creator/home` requested directly returns
200 and keeps the port.

## Why it surfaced now

The demo used to publish nginx on host port 80, so the stripped-to-80 redirect
happened to point back at the same demo and worked by accident. Moving the demo
to host port 81 (so the web and creator demos can run side by side without a
port clash) exposed the mismatch between nginx's internal listen port and the
published host port.

## The fix

`absolute_redirect off;` was added to the server block in the cyber-dojo nginx
image (`nginx.conf.template`). All the `permanent` rewrites in that block are
same-host redirects, so relative `Location` headers are correct for each: the
browser keeps whatever scheme, host and port it connected on.

```
absolute_redirect off;

rewrite ^/$              /creator/home permanent;
```

`creator/bin/demo.sh` opens the bare root URL again:

```
open "http://localhost:${CYBER_DOJO_NGINX_HOST_PORT}"
```

### Rejected alternative

`port_in_redirect off;` also fixes this case but is weaker: it drops only the
port and still depends on nginx constructing an absolute URL. `absolute_redirect
off` sidesteps the absolute form entirely.
```
