# GUI-Kiosk Heroku-style launcher

APP ?= blender
OFFLINE ?= true

build:
        docker compose build --build-arg APP=$(APP)

up:
        docker compose up -d

down:
        docker compose down

logs:
        docker compose logs -f

run: down build up logs

clean:
        docker system prune -af --volumes