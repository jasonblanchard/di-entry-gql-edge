.PHONY: build tag push deploy

IMAGE_NAME=di-gql-edge
GIT_SHA = $(shell git rev-parse HEAD)
IMAGE_REPO=jasonblanchard/${IMAGE_NAME}
LOCAL_TAG = ${IMAGE_REPO}
LATEST_TAG= ${IMAGE_REPO}:latest
SHA_TAG = ${IMAGE_REPO}:${GIT_SHA}

build:
	docker build -t ${LOCAL_TAG} .

build_dev:
	docker build -t ${LOCAL_TAG}:dev --target build .

tag: build
	docker tag ${LOCAL_TAG} ${SHA_TAG}

push: tag
	docker push ${LATEST_TAG}
	docker push ${SHA_TAG}

deploy:
	cd ./deploy/base; kustomize edit set image ${SHA_TAG}; \
	cd ..; \
	kubectl apply -k ./overlays/development; \
	cd base; \
	kustomize edit set image ${LATEST_TAG}

clean_k8s:
	kubectl delete -k ./deploy/overlays/development

swap:
	telepresence --swap-deployment gql-edge-production --namespace di-production --expose 4000 --run bash -c "PORT=4000 npm run watch"
