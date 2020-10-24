## Сборка контейнера

docker build --build-arg DUMP_URI=https://edu.postgrespro.ru/demo-small.zip -t postgres-pro-small-demo-db .

## Запуск контейнера

docker run -t -p 5555:5432 -e POSTGRES_PASSWORD=password airbooking