FROM centos:7
ARG workshop_name=example-workshop
ENV WORKSHOP_NAME=$workshop_name
ENV STUDENT_NAME='example student'
ENV BASTION_HOST='bastion.example.com'
ENV MASTER_URL='ocp.example.com'
ENV APP_DOMAIN='apps.example.com'
RUN yum -y install epel-release; yum -y install python-devel python-setuptools python-pip make; yum -y clean all
COPY requirements.txt entrypoint.sh workshops/$workshop_name /opt/docs/
WORKDIR /opt/docs
RUN pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org --upgrade pip
RUN pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org -r requirements.txt
EXPOSE 8080
CMD ["/opt/docs/entrypoint.sh"]
LABEL maintainer="creynold@redhat.com"
RUN chmod -R u+x /opt/docs && \
    chgrp -R 0 /opt/docs && \
    chmod -R g=u /opt/docs
USER 10001
