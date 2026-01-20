.PHONY: build
build:
	@JEKYLL_ENV=production bundle exec jekyll build

.PHONY: serve
serve:
	@bundle exec jekyll serve

.PHONY: build-docker
build-docker:
	rm -rf ./_site
	docker build --output=./_site/ .
