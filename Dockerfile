FROM perl:slim

RUN apt-get update && apt-get install -y alpine-pico emacs nano neovim vim neovim
