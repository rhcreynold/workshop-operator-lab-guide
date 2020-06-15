FROM centos:latest
LABEL maintainer="creynold@redhat.com"

ARG workshop_name=example-workshop
ENV WORKSHOP_NAME=$workshop_name \
    STUDENT_NAME='example student' \
    BASTION_HOST='bastion.example.com' \
    MASTER_URL='ocp.example.com' \
    APP_DOMAIN='apps.example.com'

COPY requirements.txt entrypoint.sh workshops/$workshop_name /opt/docs/
RUN chmod -R u+x /opt/docs && \
    chgrp -R 0 /opt/docs && \
    chmod -R g=u /opt/docs && \
    yum -y install epel-release && \
    yum -y install python3-devel python3-setuptools python3-pip make && \
    yum -y update && \
    yum -y clean all --enablerepo='*'

WORKDIR /opt/docs
RUN pip3 install --trusted-host pypi.org --trusted-host files.pythonhosted.org --upgrade pip setuptools && \
    pip3 install --trusted-host pypi.org --trusted-host files.pythonhosted.org -r requirements.txt

EXPOSE 8080
CMD ["/opt/docs/entrypoint.sh"]
USER 10001
