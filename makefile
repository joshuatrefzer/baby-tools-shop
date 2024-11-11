
IMAGE_NAME = babyshop

PORT = 8025

CONTAINER_NAME = babyshop

container:
	docker build -t $(IMAGE_NAME) . && \
	docker run -it --name $(CONTAINER_NAME) --rm \
	    --mount source=db_volume,target=/app \
	    --env-file .docker-env \
	    -p $(PORT):$(PORT) \
	    $(IMAGE_NAME)

build:
	docker build -t $(IMAGE_NAME) .

run:
	docker run -it --name $(CONTAINER_NAME) --restart on-failure \
	    --mount source=db_volume,target=/app \
	    --env-file .docker-env \
	    -p $(PORT):$(PORT) \
	    $(IMAGE_NAME)

superuser:
	docker exec -it $(CONTAINER_NAME) sh -c "python create_superuser.py"


