# Garden Env

Locally reproduce the environment used on [clerk.garden](https://clerk.garden):

1. Install [nix](https://nixos.org/download.html)

2. Configure nix `echo "extra-experimental-features = nix-command flakes" | sudo tee /etc/nix/nix.conf`

3. Build your notebook locally with the same dependencies as available on clerk.garden: `nix run github:nextjournal/garden-env#build`


To enter an interactive shell with the same dependencies as available on clerk.garden, run `nix run github:nextjournal/garden-env`
