# airfocus dev docs

This repository contains sources of the [https://airfocusio.github.io/dev-docs](https://airfocusio.github.io/dev-docs) website.

## Structure

This project uses [GitHub Pages and Jekyll](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/about-github-pages-and-jekyll) 
with a customized [Just The Docs](https://just-the-docs.github.io/just-the-docs/) theme.<br>
All the sources are located in the `./docs` folder:
- every `docs/*.md` or `docs/*.html` file represents a page on the website
- `docs/_config.yml` file contains the Jekyll configuration of the website
- `docs/assets` folder contains customisations, as well as downloaded Swagger UI assets
- `docs/_sass` contains custom color scheme for the Just The Docs theme

## Development

To serve the website locally:
- install [Ruby and Jekyll](https://jekyllrb.com/docs/installation/)
- open terminal in the root of this project
- run `bundle` and `bundle exec jekyll serve -s docs`
- open the printed URL in your browser
