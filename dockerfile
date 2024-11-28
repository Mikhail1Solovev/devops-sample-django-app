# Используем базовый образ Python 3.10 на базе Debian Bullseye
FROM python:3.10-slim-bullseye

# Устанавливаем переменную окружения для отключения буферизации вывода Python
ENV PYTHONUNBUFFERED 1

# Устанавливаем рабочую директорию
WORKDIR /app

# Устанавливаем системные зависимости
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем переменную окружения DJANGO_DEBUG
ENV DJANGO_DEBUG=False

# Копируем файл зависимостей
COPY requirements.txt /app/

# Устанавливаем зависимости Python
RUN pip install --no-cache-dir -r requirements.txt

# Копируем код приложения
COPY . /app/

# Сборка статических файлов
RUN python manage.py collectstatic --noinput

# Открываем порт
EXPOSE 8000

# Команда запуска приложения через uWSGI
CMD ["uwsgi", "--http", "0.0.0.0:8000", "--module", "parrotsite.wsgi:application", "--master", "--processes", "4", "--threads", "2"]
