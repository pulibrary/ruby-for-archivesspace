# REST Application Programming Interfaces (APIs)

REST (REpresentative State Transfer) exists as an architectural design pattern for transferring data using web application software. Providing an overview of REST is nearly impossible without providing an overview of server-client architecture, and the HTTP.

## Client-Server Architecture

The network protocols providing the underlying fabric which constitutes local
networks and the World Wide Web requires that data be accessed and transferred
between network nodes labeled as `clients` and `servers`. While data is
exchanged between both nodes, this architecture requires that only one or many
`clients` request some content resource from one and only one `server` node. The
`server`, in turn, provides a response to each `client` which has transmitted a
request.

## Hypertext Transfer Protocol

While many of layers of the network fabric underlying this client-server model
is primary constituted in order to provide stable and scalable connectivity
between the `client` and `server` nodes, it is actually the HTTP which provides
the standards for exchanging the data between `clients` and `servers`. For the
purposes of clarification, exchanging data between network nodes without using
the HTTP (or, other, similar protocols) can remove the concept of `client` and
`server` (as is the case with Bitcoin and cryptocurrencies, where there are
neither `clients` nor `servers`, but network nodes are just `peers`).

Hence, the importance of the HTTP cannot be overstated, and understanding its
design is fundamental to understanding REST APIs.

### HTTP Requests

The structure of an HTTP request is the following:

```bash
> GET /en-US/docs/Web/HTTP/Messages HTTP/2
> Host: developer.mozilla.org
> User-Agent: curl/7.64.1
> Accept: */*
```

- Start line
  - HTTP method
- Headers
- Body (optional)

(Please see https://developer.mozilla.org/en-US/docs/Web/HTTP/Messages#http_requests for a more thorough overview of the HTTP requests.)

### HTTP Responses

The structure of an HTTP response from a server is the following:

```bash
< HTTP/2 200
< content-type: text/html; charset=utf-8
< content-length: 137486
< last-modified: Mon, 07 Feb 2022 01:53:31 GMT
< server: AmazonS3
< x-frame-options: DENY
< x-xss-protection: 1; mode=block
< x-content-type-options: nosniff
< strict-transport-security: max-age=63072000
[...]
< date: Mon, 14 Feb 2022 15:50:29 GMT
< cache-control: max-age=86400, public
< etag: "5d2f685bfb0dba4c8d9602174d011a34"
< vary: Accept-Encoding
< x-cache: Hit from cloudfront
< via: 1.1 b078462cffa3a81b6e262ef7f6040412.cloudfront.net (CloudFront)
< x-amz-cf-pop: EWR52-C2
< x-amz-cf-id: oONoSE0N5d5GGXUW1sjr0rGmCVP3Ww0TH-X9XNZ0Qfk3ypfzWq2Vow==
< age: 5
<
<!DOCTYPE html><html lang="en-US" prefix="og: https://ogp.me/ns#"><head>[...]
```

- Status line
  - Protocol version
  - Status code
  - Status text
- Headers
- Body

(Please see https://developer.mozilla.org/en-US/docs/Web/HTTP/Messages#http_responses for a more thorough overview of the HTTP requests.)

## HTTP Client
[httparty](https://github.com/jnunemaker/httparty)

Ruby provides a number of Gems for send and handling HTTP requests, and for the
purposes of this workshop, `httparty` will be selected for an example. Using the
underlying network libraries of the operating systems, one can send HTTP requests
from within the Ruby interpreter environment. For example, for a `GET` request:

```ruby
> require 'httparty'
> uri = 'https://developer.mozilla.org/en-US/docs/Web/HTTP/Messages#http_responses'
> response = HTTParty.get(uri)
```

One can inspect the response status code and headers for the response with the following:
```ruby
> response.code
[...]
> response.headers
[...]
> response.headers.inspect
[...]
```

...and one can view the HTTP response body with the following:
```ruby
> response.body
```

### HTTP Content Negotiation

As one can observe, HTTP responses are, by default, represented as resources encoding using HTML (hypertext markup language):

```html
<!DOCTYPE html><html lang="en-US" prefix="og: https://ogp.me/ns#"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><link rel="icon" href="/favicon-48x48.97046865.png"><link rel="apple-touch-icon" href="/apple-touch-icon.0ea0fa02.png"><meta name="theme-color" content="#ffffff"><link rel="manifest" href="/manifest.56b1cedc.json"><link rel="search" type="application/opensearchdescription+xml" href="/opensearch.xml" title="MDN Web Docs">
```

However, using content negotiation, one can request a different representation. One example is the JavaScript Object Notation (JSON). One does this by specifying a value for the header `Content-Type`:

```bash
> require 'httparty'
> uri = 'http://api.stackexchange.com/2.2/questions?site=stackoverflow'
> response = HTTParty.get(uri, { headers: { 'Content-Type': 'application/json' } })
```

One will then find that the response is, instead, a representation encoded in JSON:

```bash
> json_object = JSON.parse(response.body)
```

The result of parsing this JSON response body yields a `Hash` object:

```bash
> json_object.class
=> Hash
> json_object.keys
=> ["items", "has_more", "quota_max", "quota_remaining"]
```

Unlike handling the HTML responses of the server, JSON responses can be parsed into native Ruby data structures. This renders it unnecessary for Ruby clients to parse responses encoded in HTML into native data structures.

## REST APIs

REST APIs are essentially a set of URL paths structures to return JSON responses in a predictable pattern. An example of this is the following:

```
GET blog.com/articles
POST blog.com/articles
GET blog.com/articles/1
PATCH blog.com/articles/1
DELETE blog.com/articles/1
GET blog.com/articles/2
[...]
GET blog.com/articles
POST blog.com/articles
GET blog.com/articles/1
PATCH blog.com/articles/1
DELETE blog.com/articles/1
GET blog.com/articles/2
[...]
```

Here, the `GET` methods are used in requests for `/articles` will retrieve all
`article` objects encoded in `JSON`, while `/article/1` will retrieve a single `article`
object with the ID of `1`. One can readily see how this may be mapped to a
database underlying the API server (where `articles` is a database table, and the
`id` column is used to retrieve individual records).

`POST` methods are used to request the creation of a new `article` object in the
server (this would be mapped into an `INSERT` database statement). Further, this
also requires a `POST` request to have a body specifying the fields:

```ruby
> HTTParty.post(
    'https://blog.com/articles',
    headers: { 'Content-Type': 'application/json' },
    body: {
      title: 'My Title',
      author: 'Jane Smith'
    }
  )
```

`PATCH` methods are used to request the updating of an existing `article` object in the
server (this would be mapped into an `UPDATE` database statement). This also requires
a `PATCH` request to have a body specifying the fields:

```ruby
> HTTParty.patch(
    'https://blog.com/articles',
    headers: { 'Content-Type': 'application/json' },
    body: {
      title: 'My Updated Title',
    }
  )
```

`DELETE` methods are used to request the deletion of an existing `article` object in the
server. This does not require a body, and often only returns a status code with
an empty body in the response.
