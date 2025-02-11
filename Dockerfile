FROM alpine:latest

RUN apk update
RUN apk add --no-cache python3-dev 
RUN apk add py-pip

COPY . .

EXPOSE 6969

RUN chmod +x gunicorn_starter.sh

ENTRYPOINT ["sh", "./gunicorn_starter.sh"]