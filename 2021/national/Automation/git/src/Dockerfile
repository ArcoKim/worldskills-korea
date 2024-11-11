FROM public.ecr.aws/docker/library/python:3.7-alpine

WORKDIR /app
COPY app.pyc ./

RUN pip3 install flask

CMD ["python3", "app.pyc"]
