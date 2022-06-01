.PHONY: build
build:
	@JEKYLL_ENV=production bundle exec jekyll build

.PHONY: serve
serve:
	@bundle exec jekyll serve
