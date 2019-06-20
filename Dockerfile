FROM perl:5.28

RUN apt-get update && apt-get install -y alpine-pico emacs nano neovim vim neovim

COPY . .
RUN cpanm --notest App::cpm && cpm install -g --workers $(grep -c ^processor /proc/cpuinfo) --mirror https://cpan.metacpan.org --cpanfile cpanfile
