#!/bin/bash
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin $(echo $1 | cut -d '/' -f1)
docker build -t $1 ./content/$(echo $1 | cut -d '/' -f2)
docker push $1