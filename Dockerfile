FROM perl
WORKDIR /opt/cloud_diary
COPY . .
RUN cpanm --installdeps -n .
EXPOSE 3000
CMD ./script/cloud_diary prefork
