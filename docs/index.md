---
layout: default
title: Home
nav_order: 0
---

# airfocus API

Welcome to the airfocus developer docs, where you'll find technical information about our API.<br>
If you have any questions or feedback about the API, please hollow guides in the [Help](/help) section.<br>
If you're looking for general information about airfocus and its features, please visit our [Help Center](https://help.airfocus.com).<br>

## API overview

{: .important }
> The current API in version v0.* is a subject to change until it reaches stable v1.0.<br>
> We plan the next two major changes for 2024/2025:
> - changed/simplified path names for the endpoints
> - new format of the returned embedded data: better structure of the embedded data, and clients will be able to control which embedded data
>   should be returned
>
> ### How breaking changes will be communicated
> Before we introduce a breaking change, we will analyze the usage of the affected part of API for the last month:
> - if there will be zero usages - then we can decide to deploy the breaking change without any notice
> - if there will be small amount of usages - then we can consider contacting the affected clients and asking if they're willing to migrate to the new version
> - otherwise we will introduce the breaking change in a new version of the API, and the old version will be still available for some time (marked as deprecated)

### General conventions

1. all the endpoints always accept and return JSON (including error responses)
2. most of the retrieve/search endpoints return resources with additional embedded data, injected into the resource as `_embedded` field, and that the moment
  clients can not control which embedded data is returned. This will be changed/improved in the future (see the notes above).
3. at the moment API shares the same schema-type for both read and write operations in most of the resources.
  However, server reserves the right to ignore some read-only fields in the request (e.g. `id`, `createdAt`, `updatedAt`, etc.).
  We will gradually improve it in the future by defining separated schemas for read and write operations.
4. HTTP 404 is returned when client tries to access a non-existing endpoint (invalid path)
5. HTTP 400 is returned when client tries to access a non-existing resource (valid path, but invalid ID)
6. each response includes an `X-Request-Id` header, which can be included as an additional info when reporting bugs to airfocus team -
   this will help us investigate the issue faster

### API Schema

Our API schema is defined using the OpenAPI 3.1 standard.<br>
This website provides a Swagger UI interface (see [Endpoints](/endpoints)) where you can explore the API and try out the requests.
Also, you can use another OpenAPI viewer (e.g. Postman or Intellij IDEA) to explore the API, by providing a URL to the JSON schema.

There are 2 sources of the schema:
1. our server provides an up-to-date schema which always matches its current API: [https://app.airfocus.com/api/docs/openapi.json](https://app.airfocus.com/api/docs/openapi.json)
2. this website serves a static file, which is a snapshot of the schema at the time of the latest deployment: [https://developer.airfocus.com/openapi.json](https://developer.airfocus.com/openapi.json)

Use the 1st source if you want to be sure that the schema matches the current server capabilities.<br>
Use the 2nd source if you want to have more stable source of schema, for example for code generation.

{: .note }
> The 2nd source has additional benefits:
> - you can use the [source code of the JSON schema](https://github.com/airfocusio/airfocus-api/blob/main/docs/openapi.json) when you need to reference to its specific parts (e.g. when reporting bugs)
> - as this schema is under VCS, you can see the history of its changes and switch between different versions

### Rate limits

Server reserves the right to limit the number of requests per minute for each authenticated client (with default 600 requests/minute).
To identify whether there is a rate limit applied to the current client and what's the limit - look for the next headers in the response:
- `X-RateLimit-Limit` - the maximum number of requests that the client is permitted to make in a minute
- `X-RateLimit-Remaining` - the number of requests remaining in the current rate limit window
- `X-RateLimit-Reset` - the time (in UTC epoch seconds) at which the current rate limit window will reset

### Error responses

All error responses contain a JSON payload with the following fields:
- `code` - a machine-readable error code, e.g. `invalid_request`, `not_found`, `rate_limit_exceeded`, etc.
- `message` - a human-readable error message explaining the problem
- `data` - an additional optional machine-readable JSON data about the error

For the sake of data protection, we do not return detailed messages for most of the internal server errors (HTTP 500).

### Rich-text formatting

Resources which include `RichText` (e.g. `Item` with its `description` field) can be optionally handled by the server in Markdown format:
- to send a request payload which includes Markdown-formatted `RichText`, change `Content-Type` header to `application/json+markdown`
- to receive a response payload which includes `RichText` formatted as Markdown, change `Accept` header to `application/json+markdown`

{: .note }
> The `application/json+markdown` media-type can be only used with endpoints which support rich-text formatting.
> For all the other endpoints using this media-type will result in `HTTP 406 Not Acceptable` response.

---
[Next: Authentication](/authentication){: .btn }
