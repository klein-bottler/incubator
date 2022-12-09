# What
The Klein bootstrapper is meant to be the entry-point into a rich, fully portable, naive-esk, container based development environment. 

This is known as an embedded [development container](https://code.visualstudio.com/docs/devcontainers/containers).

The bootstrapper is meant to be an entry-point to enter and use rich development containers. Other tools may end up packaged with the bootstrapper (such as the bottler), but we're still figuring out the best way to separate and package our project.

A test build of this bootstrapper container can be found [here](https://quay.io/repository/klein/klein-bootstrapper-test)


Some goals:

- [ ]: Full portability. The only thing you need is `podman`. Currently we *should* work in any headless linux based environment, but more testing is required

  Supported Shells:

    - [X]: Bash-specific support
    - [ ]: POSIX shell support
    - [ ]: Powershell support

- [ ]: Rich Embedding. Is it truly possible to seamlessly use a tool that is embedded in a container? We're not sure either, but we're going to find out.

  Planned features:

    - [X]: Ability to alias arbitrary container commands to seamlessly bring it to the host
    - [X]: Ability to pipe into arbitrary container commands
    - [X]: Commands run in your current working directory
    - [X]: Commands can use relative paths correctly, including paths above your current working directory
    - [X]: Commands interact with the host system as the calling user
    - [X]: Ability to use some relatively privileged commands, such as `podman` from inside the container.


Crazy Ideas (no really, we're not sure if they're good ideas, but we're going to try it anyways):

- [ ]: chroot back into the host. We're already sort of doing this, but this would more explicitly bind us to the host. There's many implications about doing this (most notably we'd break all our container tools), but there's precedent for this type of thing (we'll be looking into Nix based solutions). We still have to sweat the details with `/proc` and `/etc`, and may have to come up with ad-hoc solutions, but this is the most powerful embedding we can think of.
- [ ]: Tunnel back to the host. If we encounter scenarios where the container can't actually do something, this may be yet another option. Make the container execute commands on the host, rather than the other way around.

