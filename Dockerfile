FROM ruby:3.1.2 AS base
RUN gem install bundler:2.3.14
COPY Gemfile Gemfile.lock ./
RUN bundle install

FROM base AS build
ENV TZ=Asia/Jakarta
WORKDIR /app
COPY . ./
RUN JEKYLL_ENV=production bundle exec jekyll build
RUN rm /app/_site/Makefile /app/_site/Dockerfile

FROM scratch
WORKDIR /
COPY --from=build /app/_site /
