export DOCKER_ORG=$(shell yq -c --raw-output '.env.global[]' .travis.yml | awk -F "=" '/DOCKER_ORG/{print $$NF}')

build:
	bash .travis/before_install
	bash .travis/before_script
	bash .travis/script
	bash .travis/cleanup

meta:
	bash .travis/meta before_install

cron:
	bash .travis/cron before_install
