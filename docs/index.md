---
layout: default
title: Home
nav_order: 0
---

# airfocus API

Welcome to the airfocus developer docs, where you'll find technical information about our API.<br>
If you have any questions or feedback about the API, please hollow guides in the [Help](/help) section.<br>
If you're looking for general information about airfocus and its features, please visit our [Help Center](https://help.lucid.co/hc/en-us/categories/14652566349972) or [ask the community](https://community.lucid.co/peer-support-1?utm_source=developer-airfocus&utm_medium=lucid-community&utm_campaign=airfocus-dev-links&utm_content=home-ask-community).<br>

## API overview

### API Schema

Our API schema is defined based on the OpenAPI 3.1 standard.<br>
This website provides a Swagger UI interface (see [Endpoints](/endpoints)) where you can explore the API and try out the requests.
Also, you can use another OpenAPI viewer (e.g. Postman or Intellij IDEA) to explore the API, by providing a URL to the JSON schema.

The raw JSON schema can be found here: [https://developer.airfocus.com/openapi.json](https://developer.airfocus.com/openapi.json), and it always corresponds to the current server capabilities.

### API Versioning

Each published version of OpenAPI schema corresponds to a specific version of the server.
The server version can be found by requesting the `GET /api/version` endpoint.
The schema version can be found:
- in the `info.version` field of the openapi.json
- in the top-left corner of the Swagger UI interface

It's also possible to access schema in its older versions via https://raw.githubusercontent.com/airfocusio/airfocus-api/refs/tags/{version}/docs/openapi.json by replacing `{version}` with the desired version number.

In the [Changelog](/changelog.html) section you can find the history of all schema versions with the list of changes and release dates.

### Rate limits

Server reserves the right to limit the number of requests per minute for each authenticated client (with default 600 requests/minute).
To identify whether there is a rate limit applied to the current client and what's the limit - look for the next headers in the response:
- `X-RateLimit-Limit` - the maximum number of requests that the client is permitted to make in a minute
- `X-RateLimit-Remaining` - the number of requests remaining in the current rate limit window
- `X-RateLimit-Reset` - the time (in UTC epoch seconds) at which the current rate limit window will reset

---
[Next: Details](/details){: .btn }
