FROM ubuntu:16.04

# Download and unpack source, as described in instructions at
# https://www.tug.org/texlive/acquire-netinstall.html
#
RUN apt-get update
RUN apt-get install --yes wget
RUN wget "http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz"
RUN tar --extract --gzip --file=install-tl-unx.tar.gz

# The name of the unpacked file is something like /install-tl-20180714.
# Since that name looks liable to change, create a symlink for portability.
RUN mv $(find / -type d -name 'install-tl-*') /install-tl
WORKDIR /install-tl

# https://www.tug.org/texlive/quickinstall.html
#
# You need perl-modules installed, or you get errors such as
#
#     Can't locate Pod/Usage.pm in @INC (you may need to install the
#     Pod::Usage module) (@INC contains: ...) at ./install-tl line 47.
#     BEGIN failed--compilation aborted at ./install-tl line 47.
#
RUN apt-get install --yes perl-modules
COPY texlive.profile /texlive.profile
RUN ./install-tl --profile=/texlive.profile

# Required for XeLaTeX to work, or you get errors such as
#
#     xelatex: error while loading shared libraries: libfontconfig.so.1:
#     cannot open shared object file: No such file or directory
#
RUN apt-get install --yes libfontconfig1

# Install any extra fonts so they're available to XeLaTeX.
#
# fontconfig is required to get fc-cache.
#
RUN apt-get install --yes fontconfig
COPY fonts /usr/local/share/fonts/my_fonts
RUN fc-cache

ENV PATH=/usr/local/texlive/2018/bin/x86_64-linux:$PATH

VOLUME ["/data"]
WORKDIR /data
