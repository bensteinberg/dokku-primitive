# dokku primitive [![Build Status](https://img.shields.io/github/actions/workflow/status/dokku/dokku-primitive/ci.yml?branch=master&style=flat-square "Build Status")](https://github.com/dokku/dokku-primitive/actions/workflows/ci.yml?query=branch%3Amaster) [![IRC Network](https://img.shields.io/badge/irc-libera-blue.svg?style=flat-square "IRC Libera")](https://webchat.libera.chat/?channels=dokku)

Official primitive plugin for dokku. Currently defaults to installing [registry.lil.tools/harvardlil/primitive 0.02](https://hub.docker.com/r/registry.lil.tools/harvardlil/).

## Requirements

- dokku 0.19.x+
- docker 1.8.x

## Installation

```shell
# on 0.19.x+
sudo dokku plugin:install https://github.com/dokku/dokku-primitive.git primitive
```

## Commands

```
primitive:app-links <app>                          # list all primitive service links for a given app
primitive:create <service> [--create-flags...]     # create a primitive service
primitive:destroy <service> [-f|--force]           # delete the primitive service/data/container if there are no links left
primitive:enter <service>                          # enter or run a command in a running primitive service container
primitive:exists <service>                         # check if the primitive service exists
primitive:expose <service> <ports...>              # expose a primitive service on custom host:port if provided (random port on the 0.0.0.0 interface if otherwise unspecified)
primitive:info <service> [--single-info-flag]      # print the service information
primitive:link <service> <app> [--link-flags...]   # link the primitive service to the app
primitive:linked <service> <app>                   # check if the primitive service is linked to an app
primitive:links <service>                          # list all apps linked to the primitive service
primitive:list                                     # list all primitive services
primitive:logs <service> [-t|--tail] <tail-num-optional> # print the most recent log(s) for this service
primitive:pause <service>                          # pause a running primitive service
primitive:promote <service> <app>                  # promote service <service> as PRIMITIVE_URL in <app>
primitive:restart <service>                        # graceful shutdown and restart of the primitive service container
primitive:set <service> <key> <value>              # set or clear a property for a service
primitive:start <service>                          # start a previously stopped primitive service
primitive:stop <service>                           # stop a running primitive service
primitive:unexpose <service>                       # unexpose a previously exposed primitive service
primitive:unlink <service> <app>                   # unlink the primitive service from the app
primitive:upgrade <service> [--upgrade-flags...]   # upgrade service <service> to the specified versions
```

## Usage

Help for any commands can be displayed by specifying the command as an argument to primitive:help. Plugin help output in conjunction with any files in the `docs/` folder is used to generate the plugin documentation. Please consult the `primitive:help` command for any undocumented commands.

### Basic Usage

### create a primitive service

```shell
# usage
dokku primitive:create <service> [--create-flags...]
```

flags:

- `-c|--config-options "--args --go=here"`: extra arguments to pass to the container create command (default: `None`)
- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-m|--memory MEMORY`: container memory limit in megabytes (default: unlimited)
- `-N|--initial-network INITIAL_NETWORK`: the initial network to attach the service to
- `-p|--password PASSWORD`: override the user-level service password
- `-P|--post-create-network NETWORKS`: a comma-separated list of networks to attach the service container to after service creation
- `-r|--root-password PASSWORD`: override the root-level service password
- `-S|--post-start-network NETWORKS`: a comma-separated list of networks to attach the service container to after service start
- `-s|--shm-size SHM_SIZE`: override shared memory size for primitive docker container

Create a primitive service named lollipop:

```shell
dokku primitive:create lollipop
```

You can also specify the image and image version to use for the service. It *must* be compatible with the registry.lil.tools/harvardlil/primitive image.

```shell
export PRIMITIVE_IMAGE="registry.lil.tools/harvardlil/primitive"
export PRIMITIVE_IMAGE_VERSION="${PLUGIN_IMAGE_VERSION}"
dokku primitive:create lollipop
```

You can also specify custom environment variables to start the primitive service in semicolon-separated form.

```shell
export PRIMITIVE_CUSTOM_ENV="USER=alpha;HOST=beta"
dokku primitive:create lollipop
```

### print the service information

```shell
# usage
dokku primitive:info <service> [--single-info-flag]
```

flags:

- `--config-dir`: show the service configuration directory
- `--data-dir`: show the service data directory
- `--dsn`: show the service DSN
- `--exposed-ports`: show service exposed ports
- `--id`: show the service container id
- `--internal-ip`: show the service internal ip
- `--initial-network`: show the initial network being connected to
- `--links`: show the service app links
- `--post-create-network`: show the networks to attach to after service container creation
- `--post-start-network`: show the networks to attach to after service container start
- `--service-root`: show the service root directory
- `--status`: show the service running status
- `--version`: show the service image version

Get connection information as follows:

```shell
dokku primitive:info lollipop
```

You can also retrieve a specific piece of service info via flags:

```shell
dokku primitive:info lollipop --config-dir
dokku primitive:info lollipop --data-dir
dokku primitive:info lollipop --dsn
dokku primitive:info lollipop --exposed-ports
dokku primitive:info lollipop --id
dokku primitive:info lollipop --internal-ip
dokku primitive:info lollipop --initial-network
dokku primitive:info lollipop --links
dokku primitive:info lollipop --post-create-network
dokku primitive:info lollipop --post-start-network
dokku primitive:info lollipop --service-root
dokku primitive:info lollipop --status
dokku primitive:info lollipop --version
```

### list all primitive services

```shell
# usage
dokku primitive:list
```

List all services:

```shell
dokku primitive:list
```

### print the most recent log(s) for this service

```shell
# usage
dokku primitive:logs <service> [-t|--tail] <tail-num-optional>
```

flags:

- `-t|--tail [<tail-num>]`: do not stop when end of the logs are reached and wait for additional output

You can tail logs for a particular service:

```shell
dokku primitive:logs lollipop
```

By default, logs will not be tailed, but you can do this with the --tail flag:

```shell
dokku primitive:logs lollipop --tail
```

The default tail setting is to show all logs, but an initial count can also be specified:

```shell
dokku primitive:logs lollipop --tail 5
```

### link the primitive service to the app

```shell
# usage
dokku primitive:link <service> <app> [--link-flags...]
```

flags:

- `-a|--alias "BLUE_DATABASE"`: an alternative alias to use for linking to an app via environment variable
- `-q|--querystring "pool=5"`: ampersand delimited querystring arguments to append to the service link
- `-n|--no-restart "false"`: whether or not to restart the app on link (default: true)

A primitive service can be linked to a container. This will use native docker links via the docker-options plugin. Here we link it to our `playground` app.

> NOTE: this will restart your app

```shell
dokku primitive:link lollipop playground
```

The following environment variables will be set automatically by docker (not on the app itself, so they won’t be listed when calling dokku config):

```
DOKKU_PRIMITIVE_LOLLIPOP_NAME=/lollipop/DATABASE
DOKKU_PRIMITIVE_LOLLIPOP_PORT=tcp://172.17.0.1:8000
DOKKU_PRIMITIVE_LOLLIPOP_PORT_8000_TCP=tcp://172.17.0.1:8000
DOKKU_PRIMITIVE_LOLLIPOP_PORT_8000_TCP_PROTO=tcp
DOKKU_PRIMITIVE_LOLLIPOP_PORT_8000_TCP_PORT=8000
DOKKU_PRIMITIVE_LOLLIPOP_PORT_8000_TCP_ADDR=172.17.0.1
```

The following will be set on the linked application by default:

```
PRIMITIVE_URL=httphttp://dokku-primitive-lollipop:8000/lollipop
```

The host exposed here only works internally in docker containers. If you want your container to be reachable from outside, you should use the `expose` subcommand. Another service can be linked to your app:

```shell
dokku primitive:link other_service playground
```

It is possible to change the protocol for `PRIMITIVE_URL` by setting the environment variable `PRIMITIVE_DATABASE_SCHEME` on the app. Doing so will after linking will cause the plugin to think the service is not linked, and we advise you to unlink before proceeding.

```shell
dokku config:set playground PRIMITIVE_DATABASE_SCHEME=http2
dokku primitive:link lollipop playground
```

This will cause `PRIMITIVE_URL` to be set as:

```
http2http://dokku-primitive-lollipop:8000/lollipop
```

### unlink the primitive service from the app

```shell
# usage
dokku primitive:unlink <service> <app>
```

flags:

- `-n|--no-restart "false"`: whether or not to restart the app on unlink (default: true)

You can unlink a primitive service:

> NOTE: this will restart your app and unset related environment variables

```shell
dokku primitive:unlink lollipop playground
```

### set or clear a property for a service

```shell
# usage
dokku primitive:set <service> <key> <value>
```

Set the network to attach after the service container is started:

```shell
dokku primitive:set lollipop post-create-network custom-network
```

Set multiple networks:

```shell
dokku primitive:set lollipop post-create-network custom-network,other-network
```

Unset the post-create-network value:

```shell
dokku primitive:set lollipop post-create-network
```

### Service Lifecycle

The lifecycle of each service can be managed through the following commands:

### enter or run a command in a running primitive service container

```shell
# usage
dokku primitive:enter <service>
```

A bash prompt can be opened against a running service. Filesystem changes will not be saved to disk.

> NOTE: disconnecting from ssh while running this command may leave zombie processes due to moby/moby#9098

```shell
dokku primitive:enter lollipop
```

You may also run a command directly against the service. Filesystem changes will not be saved to disk.

```shell
dokku primitive:enter lollipop touch /tmp/test
```

### expose a primitive service on custom host:port if provided (random port on the 0.0.0.0 interface if otherwise unspecified)

```shell
# usage
dokku primitive:expose <service> <ports...>
```

Expose the service on the service's normal ports, allowing access to it from the public interface (`0.0.0.0`):

```shell
dokku primitive:expose lollipop 8000
```

Expose the service on the service's normal ports, with the first on a specified ip adddress (127.0.0.1):

```shell
dokku primitive:expose lollipop 127.0.0.1:8000
```

### unexpose a previously exposed primitive service

```shell
# usage
dokku primitive:unexpose <service>
```

Unexpose the service, removing access to it from the public interface (`0.0.0.0`):

```shell
dokku primitive:unexpose lollipop
```

### promote service <service> as PRIMITIVE_URL in <app>

```shell
# usage
dokku primitive:promote <service> <app>
```

If you have a primitive service linked to an app and try to link another primitive service another link environment variable will be generated automatically:

```
DOKKU_PRIMITIVE_BLUE_URL=httphttp://dokku-primitive-other-service:8000/other_service
```

You can promote the new service to be the primary one:

> NOTE: this will restart your app

```shell
dokku primitive:promote other_service playground
```

This will replace `PRIMITIVE_URL` with the url from other_service and generate another environment variable to hold the previous value if necessary. You could end up with the following for example:

```
PRIMITIVE_URL=httphttp://dokku-primitive-other-service:8000/other_service
DOKKU_PRIMITIVE_BLUE_URL=httphttp://dokku-primitive-other-service:8000/other_service
DOKKU_PRIMITIVE_SILVER_URL=httphttp://dokku-primitive-lollipop:8000/lollipop
```

### start a previously stopped primitive service

```shell
# usage
dokku primitive:start <service>
```

Start the service:

```shell
dokku primitive:start lollipop
```

### stop a running primitive service

```shell
# usage
dokku primitive:stop <service>
```

Stop the service and removes the running container:

```shell
dokku primitive:stop lollipop
```

### pause a running primitive service

```shell
# usage
dokku primitive:pause <service>
```

Pause the running container for the service:

```shell
dokku primitive:pause lollipop
```

### graceful shutdown and restart of the primitive service container

```shell
# usage
dokku primitive:restart <service>
```

Restart the service:

```shell
dokku primitive:restart lollipop
```

### upgrade service <service> to the specified versions

```shell
# usage
dokku primitive:upgrade <service> [--upgrade-flags...]
```

flags:

- `-c|--config-options "--args --go=here"`: extra arguments to pass to the container create command (default: `None`)
- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-N|--initial-network INITIAL_NETWORK`: the initial network to attach the service to
- `-P|--post-create-network NETWORKS`: a comma-separated list of networks to attach the service container to after service creation
- `-R|--restart-apps "true"`: whether or not to force an app restart (default: false)
- `-S|--post-start-network NETWORKS`: a comma-separated list of networks to attach the service container to after service start
- `-s|--shm-size SHM_SIZE`: override shared memory size for primitive docker container

You can upgrade an existing service to a new image or image-version:

```shell
dokku primitive:upgrade lollipop
```

### Service Automation

Service scripting can be executed using the following commands:

### list all primitive service links for a given app

```shell
# usage
dokku primitive:app-links <app>
```

List all primitive services that are linked to the `playground` app.

```shell
dokku primitive:app-links playground
```

### check if the primitive service exists

```shell
# usage
dokku primitive:exists <service>
```

Here we check if the lollipop primitive service exists.

```shell
dokku primitive:exists lollipop
```

### check if the primitive service is linked to an app

```shell
# usage
dokku primitive:linked <service> <app>
```

Here we check if the lollipop primitive service is linked to the `playground` app.

```shell
dokku primitive:linked lollipop playground
```

### list all apps linked to the primitive service

```shell
# usage
dokku primitive:links <service>
```

List all apps linked to the `lollipop` primitive service.

```shell
dokku primitive:links lollipop
```

### Disabling `docker image pull` calls

If you wish to disable the `docker image pull` calls that the plugin triggers, you may set the `PRIMITIVE_DISABLE_PULL` environment variable to `true`. Once disabled, you will need to pull the service image you wish to deploy as shown in the `stderr` output.

Please ensure the proper images are in place when `docker image pull` is disabled.
