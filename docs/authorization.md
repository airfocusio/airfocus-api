---
layout: default
title: Authorization
nav_order: 20
---
[Prev: Authentication](/authentication){: .btn }

# Authorization Levels

The API operates with 4 different levels of authorization: scopes, features, roles and permissions.
Missing any of them (when being required) will result in an Unauthorized error response.

{: .note }
> Information about required scopes, features, roles and permissions for each endpoint can be found in the descriptions of corresponding endpoints.

## Scopes

Scopes are designed to limit access of a token to certain parts of the API. When creating a token, you can select the required scopes for it.
The API server will return a 403 Forbidden error response when trying to access and endpoints which belongs to a scope which was not enabled for the current access token.

Scopes allow you to grant either read or write access to the next 3 main domains:
- user domain: access to account data of the current user
- team domain: access to account data of the current team
- workspace domain: access to all the team workspaces with all their contents

## Features

Some core features of the airfocus app are available to all the teams and users, while some other features are available only to the teams with a specific pricing plan.
Hence, some API endpoints may require a specific team-feature to be enabled in order to fulfill the request.<br>
If the current team does not have access to the required feature - the API server will return a 403 Forbidden error response in this case.
The rule of thumb is - all the features which are accessible for the team in the airfocus web-app, should be also accessible via API.

## Roles

Role defines a level of access to team's contents:
- `admin` - super-user - can do and change everything.
- `editor` - regular user - can read and write data, but cannot change any team-level settings
- `contributor` - limited user - like editor, but can't have permissions higher than `comment` (see Permissions section below)

When accessing the API with a personal access token, the token allows to perform only those actions which are allowed to the role of the user who has created the token.

## Permissions

Permissions define level of access to certain workspaces and all their contents:
- `read` - can only read workspace data
- `comment` - all above, plus can add comments
- `write` - all above, plus can create/update/delete items
- `full` - all above, plus can manage the workspace settings, install integrations, apps, etc.

You can find more details about permissions and roles in our [Help Center article](https://help.lucid.co/hc/en-us/articles/43100619410452-Manage-members-roles-and-permissions-in-airfocus)

[Next: API Endpoints](/endpoints){: .btn }
