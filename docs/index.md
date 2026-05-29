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

### General conventions

1. All the endpoints always accept and return JSON (including error responses). The only exception is the attachment endpoints which work with binary files.
2. Most of the retrieve/search endpoints return resources with additional embedded data, injected into the resource as `_embedded` field. There is no way to control what data is returned, i.e. they always return the full data. However, some endpoints (like item-search) have an alternative "partial" version, which allows requesting only specific fields. It's recommented to use the "partial" endpoints if possible, to reduce the amount of data transferred and improve performance.
3. At the moment we have multiple API endpoints which share the same schema-type for both read and write operations in most of the resources.
  However, server reserves the right to ignore some read-only fields during write-operations - e.g. fields `id`, `createdAt`, `updatedAt`, etc. are ignored when updating a resource.
  We will gradually improve it in the future by defining separated schemas for read and write operations.
4. HTTP response code conventions:
   - 404 is returned when trying to access a non-existing endpoint (invalid path)
   - 400 is returned when trying to access a non-existing resource (valid path, but invalid resource ID)
5. each response includes an `X-Request-Id` header, which can be included as an additional info when reporting bugs to airfocus team -
   this will help us with issue investigation and debugging.

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

### Error responses

All error responses contain a JSON payload with the following fields:
- `code` - a machine-readable error code, e.g. `invalid_request`, `not_found`, `rate_limit_exceeded`, etc.
- `message` - a human-readable error message explaining the problem
- `data` - an additional optional machine-readable JSON data about the error

For the sake of data protection, we do not return detailed messages for most of the internal server errors (HTTP 500).

### Rich-text formatting

Resources which include `RichText` (e.g. `Item` with its `description` field) can be optionally handled by the server in Markdown format:
- to send a request payload which includes Markdown-formatted `RichText`, change `Content-Type` header to `application/vnd.airfocus.markdown+json`
- to receive a response payload which includes `RichText` formatted as Markdown, change `Accept` header to `application/vnd.airfocus.markdown+json`

{: .note }
> The `application/vnd.airfocus.markdown+json` media-type can be only used with endpoints which support rich-text formatting.
> For all the other endpoints using this media-type will result in `HTTP 406 Not Acceptable` response.

The Markdown response returned by using the `application/vnd.airfocus.markdown+json` has the following structure:
```json
{
  "markdown": "Markdown text here. This is **bold**.",
  "richText": true
}
```

### Enums with discriminator field

Swagger UI can be not very intuitive when it comes to displaying enums with discriminator fields.<br>
When you explore the schema, you may see some data-types described as `One of` followed by a list of possible types, and an additional `Discriminator` field.<br>
Here is how to understand it (see the example screenshot below):
- all objects in the list share one common field, called the discriminator field
- to know which of the fields is the discriminator field, look for the `Discriminator` section in the schema, which includes the name of this field in the first row (in this case it's `type`)
- therefore, each object in the list must have this field defined with a unique fixed value, which corresponds to this object
- then find the name of the specific object (for example `ItemConstraintIntegrationPushForbidden`), and then find it on the right side in the `Discriminator` section
- then the value on the left side will be the fixed value for the discriminator field (in this case it's `integrationPushForbidden`)
- therefore, the full JSON value would look like this:
```json
{
  "extensionId": "...",
  "type": "integrationPushForbidden"
}
```
![enum-example.png](assets/enum-example.png)

---
[Next: Authentication](/authentication){: .btn }
