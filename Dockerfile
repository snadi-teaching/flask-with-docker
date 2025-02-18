FROM python:3.10-alpine

COPY . .

EXPOSE 6969

RUN chmod +x gunicorn_starter.sh

ENTRYPOINT ["sh", "./gunicorn_starter.sh"]