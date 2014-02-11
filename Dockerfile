# A PostgresSQL 9.3 installation
FROM ubuntu
MAINTAINER Sjoerd <sdevries@gmail.com>

# Adding sources
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
# And get up to date
RUN apt-get update
RUN apt-get upgrade -y

# Install packages ->
#RUN apt-get -y install python-software-properties software-properties-common
ADD https://www.postgresql.org/media/keys/ACCC4CF8.asc /tmp/ACCC4CF8.asc
RUN apt-key add  /tmp/ACCC4CF8.asc

#RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN apt-get update
RUN apt-get -y install postgresql-9.3 postgresql-client-9.3 postgresql-contrib-9.3

# Config change for insecurity
RUN sed -i -e 's/host[ ]*all[ ]*all[ ]*127.0.0.1\/32[ ]*md5/host  all  all  0.0.0.0\/0  md5/' /etc/postgresql/9.3/main/pg_hba.conf
RUN sed -i -e 's/^#listen_addresses\s\=\s'\''localhost'\''/listen_addresses\ \= '\''*'\''/' /etc/postgresql/9.3/main/postgresql.conf

# Create user and test database
RUN echo "CREATE ROLE docker WITH LOGIN SUPERUSER CREATEDB CREATEROLE PASSWORD 'docker' ;" > /tmp/user_creds
RUN service postgresql start && su postgres -c "cat /tmp/user_creds | psql -U postgres" && service postgresql stop
RUN service postgresql start && su postgres -c "createdb -O docker docker" && service postgresql stop
RUN rm -f /tmp/user_creds

# Expose the service port (default is tcp)
EXPOSE 5432

# Run our service
CMD ["/bin/su","postgres","-c","/usr/lib/postgresql/9.3/bin/postgres -D /var/lib/postgresql/9.3/main -c config_file=/etc/postgresql/9.3/main/postgresql.conf"]

## Building ##
# sudo docker build -t postgres .

## Running ##
# sudo docker run -p 5432:5432 postgres
