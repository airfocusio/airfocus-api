---
layout: default
title: Home
nav_order: 0
---

# airfocus dev docs

Welcome to the airfocus developer docs, where you'll find technical information about our API.<br>
If you have any questions or feedback about the API, please hollow guides in the [Help](/help) section.<br>
If you're looking for general information about airfocus and its features, please visit our [Help Center](https://help.airfocus.com).<br>

## API overview

{: .important }
> The current API in version v0.* is a subject to change. We plan two major changes for 2024/2025:
> - changed/simplified path names for the endpoints
> - new format of the returned embedded data: better structure of the embedded data, and clients will be able to control which embedded data
>   should be returned

### Basic principles

1. airfocus server provides the actual up-to-date OpenAPI 3.1 schema at [https://app.airfocus.com/api/docs/openapi.json](https://app.airfocus.com/api/docs/openapi.json).
   Open it in your favourite OpenAPI viewer (e.g. Swagger UI or Postman) or go to [API Endpoints](/endpoints) to explore the API.
2. all the endpoints always accept and return JSON (including error responses)
3. most of the retrieve/search endpoints return resources with additional embedded data, injected into the resource as `_embedded` field, and that the moment
  clients can not control which embedded data is returned. This will be changed/improved in the future (see the notes above).
4. at the moment API shares the same schema-type for both read and write operations in most of the resources.
  However, server reserves the right to ignore some read-only fields in the request (e.g. `id`, `createdAt`, `updatedAt`, etc.).
  We will gradually improve it in the future by defining separated schemas for read and write operations.
5. HTTP 404 is returned when client tries to access a non-existing endpoint (invalid path)
6. HTTP 400 is returned when client tries to access a non-existing resource (valid path, but invalid ID)
7. each response includes an `X-Request-Id` header, which can be included as an additional info when reporting bugs to airfocus team -
   this will help us investigate the issue faster

### Rate limits

Server reserves the right to limit the number of requests per minute for each authenticated client.
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
[Next: Authentication](/auth){: .btn }
