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

Scopes are a way to limit the access of a token to certain parts of the API. When creating a token, you can select the required scopes for it.
The API server will return a 403 Forbidden error response when trying to access and endpoints which belongs to a scope which was not enabled for the current access token.

Using scopes you can grant either read or write access to the next 3 main domains:
- user domain: access to account data of the current user
- team domain: access to account data of the current team
- workspace domain: access to all the team workspaces with all their contents

## Features

Some core features of the airfocus app are available to all the teams and users, while some other features are available only to the teams with a specific pricing plan.
Hence, some API endpoints may require a specific team-feature to be enabled in order to fulfill the request.<br>
If the current team does not have access to the required feature - the API server will return a 403 Forbidden error response in this case.

How do I know if my team has a specific feature?:<br>
there is a general rule - all the features which are accessible for the team in the airfocus web-app, should be also accessible via API.

## Roles

Role defines a level of access to team's contents:
- `contributor` - can only comment on items
- `editor` - previous + can manage most of the team's contents (workspaces, items, etc.)
- `admin` - previous + can manage the team settings, billing, add/remove users, etc

When accessing the API with a personal access token, the token allows to perform only those actions which are allowed to the role of the user who has created the token.

## Permissions

Permissions define level of access to certain workspaces:
- `read` - can only read workspace data
- `comment` - previous + can add comments
- `write` - previous + can create/update/delete items
- `full` - previous + can manage the workspace settings, install integrations, apps, etc.

Permission to a single workspace for a single user can be defined on 4 different levels:
1. explicitly configured permission for the specific user in the workspace settings
2. default team permission configured in the workspace settings
3. (if workspace belongs to a workspace group) explicitly configured permission for the specific user in the workspace group settings
4. (if workspace belongs to a workspace group) default team permission configured in the workspace group settings

Server always chooses the highest level of permission from the above list.

Example:
- there is a workspace `Tasks` which belongs to a workspace group `Product`
- the workspace `Tasks` has no explicit user permissions
- the workspace `Tasks` has a default team permission `write`
- the workspace group `Product` has an explicit user permission `full` for the current user
- the workspace group `Product` has a default team permission `read`
- as result - the current user will have `full` permission to the workspace `Tasks` (and any other workspace which belongs to the `Product` workspace group)

When accessing the API with a personal access token, the token allows to perform only those actions with workspaces where the user who has created the token has the required permissions.

[Next: API Endpoints](/endpoints){: .btn }
