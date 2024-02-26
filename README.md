# airfocus API

This repository contains sources of the airfocus API documentation, served at the [https://developer.airfocus.com](https://developer.airfocus.com)

## Structure

This project uses [GitHub Pages and Jekyll](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/about-github-pages-and-jekyll)
with a customized [Just The Docs](https://just-the-docs.github.io/just-the-docs/) theme.<br>
All the sources are located in the `./docs` folder:
- every `docs/*.md` or `docs/*.html` file represents a page on the website
- `docs/_config.yml` file contains the Jekyll configuration of the website
- `docs/assets` folder contains customisations, as well as downloaded Swagger UI assets
- `docs/_sass` contains custom color scheme for the Just The Docs theme

## Development

### Serving the website locally

- install Docker if you don't have it yet
- open terminal in the root of this project
- run `docker-compose up -d`
- watch the logs (`docker-compose logs -f`) until you see the message ` Server running... press ctrl-c to stop`.
  This can take a few minutes, as it needs to install all the ruby dependencies.
- open http://127.0.0.1:4000 in your browser (the printed URL in the logs may not work)

Any changes in the `./docs` folder (except  the `_config.yml` file) will be automatically recompiled.<br>
If you change the `_config.yml` file, then you need to restart the server `docker-compose restart`.
