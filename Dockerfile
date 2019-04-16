FROM centos
ARG workshop_name=dcmetromap
ENV WORKSHOP_NAME=$workshop_name
ENV STUDENT_NAME='example student'
ENV BASTION_HOST='bastion.example.com'
ENV MASTER_URL='ocp.example.com'
ENV APP_DOMAIN='apps.example.com'
RUN yum -y update
RUN yum -y install epel-release; yum -y install python-devel python-setuptools python-pip make; yum -y clean all
COPY requirements.txt deploy.sh workshops/$workshop_name /opt/docs/
WORKDIR /opt/docs
RUN pip install --upgrade pip
RUN pip install -r requirements.txt
EXPOSE 8080
CMD ["/opt/docs/entrypoint.sh"]
LABEL maintainer="jduncan@redhat.com"
