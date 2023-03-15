FROM ubuntu:22.04

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
	&& apt-get update \
	&& apt-get upgrade -y

RUN apt-get install -y \
		curl \
		fonts-noto-color-emoji \
		libsecret-1-0 \
		pulseaudio \
		wget \
	&& curl -L "https://web.archive.org/web/20220907132309if_/https://packages.microsoft.com/repos/ms-teams/pool/main/t/teams/teams_1.5.00.23861_amd64.deb" > /tmp/teams.deb \
	&& apt-get install -y /tmp/teams.deb \
	&& rm /tmp/teams.deb

COPY xdg-open /usr/local/bin/

CMD /usr/share/teams/teams
