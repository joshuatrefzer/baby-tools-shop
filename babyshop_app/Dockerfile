
FROM python:3.10-alpine

WORKDIR /app

COPY . .


COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN python -m pip install --no-cache-dir -r requirements.txt

EXPOSE 8000

ENTRYPOINT ["/entrypoint.sh"]

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]


