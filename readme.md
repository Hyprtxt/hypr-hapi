# Facebook Lead Gen -> Acton

Redis Password: 7DB.syK7JXktkUbrK[fm

Tunnel local site to internet with SSL `ssh -R 8080:localhost:8100 ht`

* User must accept: [Leadgen TOS](https://www.facebook.com/ads/leadgen/tos)
* [Leadgen Ads API Docs](https://developers.facebook.com/docs/marketing-api/guides/lead-ads/v2.5)

# @todo

1. How are Act On lists segmented? Will data be overwritten by CRM, are more fields required?
1. Complete Process with CURL
1. Manage Token Expiration
1. Auto Update from Real FB Data, check that subscription is working.
1. Deploy!

```
NASM Page Access Token: CAACEdEose0cBAG2UdMv6YnR93J7cBaWYoqktpODmsKg0BDhRb5tcsXHxTQwZBHZBp3xTgMID4yfRz0tOHZC8UAGb6BKjj2GlZCbW60riZBC2ZBWlAZBGLYT0yCYhaiMZB2mo6nZCwra83s3Qa38tPlZCWJEvX9uPPL10yKrDeZBC8alcZCi3gAuejmvUGO1X64ol9ZAf56xDHZBXni9QZDZD
```




```
curl \
-F "access_token=" \
"https://graph.facebook.com/v2.5/50318073949/subscribed_apps"
```

## Notes

* AD ID - 6030653854460
* app_id: '1513710378927269'
* app_secret: 'b7741bad6244c28f34d6bdc2e9116def'

* NASM Page ID - 50318073949

# Facebook Stuff

* [Realtime Client Examples](https://github.com/fbsamples/real-time-updates-samples)
* [Subscriptions Graph API Docs](https://developers.facebook.com/docs/graph-api/reference/v2.5/app/subscriptions)

### Get List of Leadgen Forms - Using User Access token

```
curl -G \
-d 'access_token=CAAVgtiltxKUBAJ237XpSU1ZClYDaD4zw3nhZAOsiaWxstRdMUI8vitUhzelerozZCjRhipTCKLoBUYP8deSCgZB1IQ8uvnD3FASAJJSKRSn2oofZCbsRDveuaBeHuHaTkE4b6gmlT4bNaFmbsgZBItrZAi0gph1vTqobTlh440aydanHr9GKyvq5yqG4JkwlZAUZD' \
"https://graph.facebook.com/v2.5/50318073949/leadgen_forms"
```



### Get App Access Token

Login with oauth to get a user token

```
curl \
-F "client_id=1513710378927269" \
-F "client_secret=b7741bad6244c28f34d6bdc2e9116def" \
-F "grant_type=client_credentials" \
https://graph.facebook.com/oauth/access_token
```

### Setup Callback Subscription


Leadgen

```
curl -X POST \
-F "object=page" \
-F "callback_url=https://tunnel.hyprtxt.com/realtime" \
-F "fields=leadgen" \
-F "access_token=1513710378927269|ekxRolnHjwt8BzUxKpOwOVthWJ0" \
-F "verify_token=verify1234" \
https://graph.facebook.com/v2.5/1513710378927269/subscriptions
```

Feed - Page activity, just trying to get some realtime pings going.

```
curl -X POST \
-F "object=page" \
-F "callback_url=https://tunnel.hyprtxt.com/realtime" \
-F "fields=feed" \
-F "access_token=1513710378927269|ekxRolnHjwt8BzUxKpOwOVthWJ0" \
-F "verify_token=verify1234" \
https://graph.facebook.com/v2.5/1513710378927269/subscriptions
```

### Read Subscriptions

```
curl -i -X GET \
"https://graph.facebook.com/v2.5/subscriptions?access_token=1513710378927269%7CekxRolnHjwt8BzUxKpOwOVthWJ0"
```

### Delete Subscriptions

```
curl -X DELETE \
-F "object=page" \
-F "access_token=1513710378927269|ekxRolnHjwt8BzUxKpOwOVthWJ0" \
https://graph.facebook.com/v2.5/1513710378927269/subscriptions
```

### Send Test Data

```
curl -X POST \
-F "object=page" \
-F "fields=leadgen" \
-F "access_token=1513710378927269|ekxRolnHjwt8BzUxKpOwOVthWJ0" \
https://graph.facebook.com/v2.5/1513710378927269/subscriptions_sample
```

### Download CSV

User Token Here!

```
curl -G \
-d "access_token=CAAVgtiltxKUBAJWlX45KH2qCRKN4EK5ZA061aZBpr3OUyxT9Da89ZA9zw04PQCKHI2R78hMvefZBgzEtslChqmHI7TGocw42XSPhMOg7OGPdVJ7fIDXA239jvbpImZBAZAZAa3Kv3TLWFqPaoZAfD1D3UDZA9T3NDcwDDKtquWAZCLEtxRq2ZBDCLasX3yiPcBlljAZD" \
https://graph.facebook.com/v2.5/50318073949/leadgen_forms
```

### Get Lead Data

```
curl -G \
-d "access_token=CAAVgtiltxKUBAJWlX45KH2qCRKN4EK5ZA061aZBpr3OUyxT9Da89ZA9zw04PQCKHI2R78hMvefZBgzEtslChqmHI7TGocw42XSPhMOg7OGPdVJ7fIDXA239jvbpImZBAZAZAa3Kv3TLWFqPaoZAfD1D3UDZA9T3NDcwDDKtquWAZCLEtxRq2ZBDCLasX3yiPcBlljAZD" \
https://graph.facebook.com/v2.5/6030653854460/leads
```

### Send Sample Data

not working? "App must be on whitelist"

```
curl \
-F "object=page" \
-F "field=leadgen" \
-F "access_token=1513710378927269|ekxRolnHjwt8BzUxKpOwOVthWJ0" \
https://graph.facebook.com/v2.5/50318073949/subscriptions_sample
```

# Acton Endpoint

`https://restapi.actonsoftware.com/token`

Use oauth2 to get a user token

Facebook Leads Target List: `l-dyn-lead-004b`

Facebook Empty Test List: `l-0068` (Does not work, not setup, just a folder???)

Taylor's Test List: `l-0086`

### Acton Get List of Lists

```
curl -X GET \
-H "Authorization: Bearer 1321794d98e6725e656b9b6fc3e2fd3" \
-H "Cache-Control: no-cache" \
https://restapi.actonsoftware.com/api/1/list?listingtype=CONTACT_LIST
```
### Acton Download List

```
curl -X GET \
-H "Authorization: Bearer 1321794d98e6725e656b9b6fc3e2fd3" \
-H "Cache-Control: no-cache" \
https://restapi.actonsoftware.com/api/1/list/l-0086
```

### Acton Add to List

Upload a file? This is cray cray...

```
curl -X PUT
-H "Authorization: Bearer 1321794d98e6725e656b9b6fc3e2fd3" \
-H "Cache-Control: no-cache" \
-H "Content-Type: multipart/form-data" \
-F "listname=InvitationTokens" \
-F "headings=Y" \
-F "fieldseperator=COMMA" \
-F "quotecharacter=NONE" \
-F "uploadspecs=[{"columnHeading":"Email","ignoreColumn":"N","columnIndex":0,"columnType":"EMAIL"},{"columnHeading":"First Name","ignoreColumn":"N","columnIndex":1},{"columnHeading":"Last Name","ignoreColumn":"N","columnIndex":2},{"columnHeading":"Company","ignoreColumn":"N","columnIndex":3}]" \
-F "file=" \
-F "foldername=nil" \
-F "mergespecs=[{"dstListId":"l-08fd","mergeMode":"UPSERT","columnMap":[]}]" \
-F "listId=l-08fd" \
https://restapi.actonsoftware.com/api/1/list/l-08fd
```

### Acton Add Contact

```
curl -X POST \
-H "Authorization: Bearer 1321794d98e6725e656b9b6fc3e2fd3" \
-H "Content-Type: application/json" \
-H "Cache-Control: no-cache" \
-d '{"Email":"taylor.young@ascendlearning.com","First Name":"Taylor","Last Name":"Young"}' \
https://restapi.actonsoftware.com/api/1/list/l-0086/record
```

```
curl -X POST \
-H "Authorization: Bearer 1321794d98e6725e656b9b6fc3e2fd3" \
-H "Content-Type: application/json" \
-H "Cache-Control: no-cache" \
-d '{"Email":"taylor.young@ascendlearning.com","Name":"Taylor Young","First Name":"Taylor","Last Name":"Young"}' \
https://restapi.actonsoftware.com/api/1/list/l-dyn-lead-004b/record
```

```
curl -X POST -H "Authorization: Bearer d46940913759bf58f4c1778ed54e43" -H "Content-Type: application/json" -H "Cache-Control: no-cache" -d '{"Email":"john.doe@somedomain.com","Test1":"John","Test2":"Doe"}' https://restapi.actonsoftware.com/api/1/list/l-0003/record
```

## Interesting TLDs

* .coach
* .fit
* .fitness
* .golf
* .fans
* .football
* .guide
* .info
* .news
* .training
* .yoga

## Interesting Domains

* sportsmedicine.net
* sportsmedicine.guide
* sportsmedicine.training
* sportsmedicine.fitness
* sportsmedicine.coach
* afaa.fitness
* afaa.guide
* afaa.guru
* afaa.coach
* afaa.academy
* afaa.training
* nasm.guide
* nasm.email
* bethe.coach
* sports.coach (premium $820 @ google)
* physicalfitness.training
* physicalfitness.guide
* physicalfitness.coach
* physicalfitness.academy
