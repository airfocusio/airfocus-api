---
layout: default
title: Authentication
nav_order: 10
---
[Prev: Home](/){: .btn }

# Authentication

The API provides [OAuth 2.0](https://oauth.net/2/) authentication and expects clients to supply each request with an `Authorization: Bearer <token>` header 
with a valid access token.

## Personal access tokens

Personal access tokens allow to authenticate as the user who created the token.<br>
The next rules apply to personal access tokens:
- they are bound to the user who has created it
- they have the same permissions as the user
- any operations performed with such token will be recorded as they were performed by the user

Creating personal access tokens:
- open the airfocus app
- in the bottom-left corner click on your name
- go to "Account settings" > "API keys"
- click on "Add API key", give it a name and select the required scopes, then click "Create"

## Impersonated access tokens

{: .important }
> At the moment this feature is not supported, but plan to add it in the nearest future.

When implementing an integration with API, it's often useful to not authenticate as a specific user, but rather as some kind of application or bot,
which allows to identify actions performed by the integration. 
Personal access tokens are not suitable for this, because they act on behalf of the user who has created them.
And so we plan to add a feature which will allow to create impersonated access tokens which act on behalf of a bot-user.

## Safety and data protection

At airfocus one of our primary goals is to keep your data safe and secure. 
However, with the personal access tokens part of this safety is in your hands.

**So please keep in mind the next points when working with access tokens:**
- treat access tokens like passwords and keep them secure. Don't share them with anyone and don't store them in public places
- when creating a token, enable only those access scopes which are required for your application to work properly.
  Over-granting scopes increases security risks if the token gets compromised
- for security reasons it's not possible to access the token after leaving the creation dialog, so make sure to copy it and store it in a safe place
  before leaving the dialog
- if you suspect that your token has been compromised - delete it immediately and create a new one. 
  In order to do this, go to your "Account settings" > "API keys" and click on the "Delete" button next to the token
- give your access tokens meaningful names, so you can easily identify them later and decide which ones to delete
- do not use the same token for different applications or services. 
  Instead, create a separate token for each application or service, so you can easily revoke access to one of them if needed

[Next: Authorization](/authorization){: .btn }