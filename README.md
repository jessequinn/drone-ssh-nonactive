# drone-ssh
## Docker
Build the docker image by running:

```bash
docker build --rm=true -t damasu/drone-ssh .
```

## Usage
Execute from the working directory (assuming you have an SSH server running on 127.0.0.1:22):

```bash
docker run --rm \
  -e PLUGIN_KEY=$(cat some-private-key) \
  -e PLUGIN_HOSTS="127.0.0.1, 127.0.0.2, 127.0.0.3" \
  -e PLUGIN_PORTS="22, 23, 24" \
  -e PLUGIN_USER="admin" \
  -e PLUGIN_SCRIPT="echo \"Script Done!\"" \
  -v $(pwd):$(pwd) \
  -w $(pwd) \
  damasu/drone-ssh
```
