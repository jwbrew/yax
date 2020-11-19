# Yax

Yet Another Query Syntax (but X because Elixir)

...for Elixir

......and [Ecto](https://hexdocs.pm/ecto/Ecto.html)

.........and [Bodyguard](https://hexdocs.pm/bodyguard/readme.html)

N.B - you're reading the readme for the very first commit on this project

In no way is this production ready, or even all that good. Even this readme is just some verbal diarrhea, written down. 

This package just explores a few ideas: 

- GraphQL is awesome but integrating it with a Phoenix app is not. You hide 
everything behind a single endpoint and lose all the goodstuff that Plug, 
Phoenix, and HTTP (!) have to offer.

- Data queries are inherently different from mutations. GraphQL models this, 
CQRS does this too. It's nothing earth-shattering, more of just a principal.

- We're only concerned with queries, so mutation permissioning provided 
by the likes of [Canada](https://github.com/jarednorman/canada) are a different
beast altogether.

- Data permissions and scoping are hard, and the current state of Phoenix 
apps makes it very easy to slip up

- Data queries rely on basically the same repeated setup: 
  - Define models 
  - Define access policies
  - Define a bunch of REST routes
  - Create controllers for the routes
  - Wire my new controllers up to the contexts for my datamodel and to the
  policies for the same resource
  - Completely drop the ball and forget to scope or check a policy on a route

Yax does that all for you. Yax converts a URL query schema into a *properly scoped* 
Ecto query. (**Immense** amounts of kudos and respect to the folks behind [Postgrest](http://postgrest.org/en/v7.0.0/api.html) for the API, 
it's the best in its class I've used and heavily inspires the query syntax here. If you need a pure data play, then use Postgrest. If you 
need integration into an application layer...keep reading.

## In The Wild

Let your controllers look like this:

```
defmodule FooWeb.PostController do 
  plug Yax.Plug, Foo.Posts.Post
  def index(conn, _params), do: json(conn, Yax.all(conn))
  def show(conn, _params) do json(conn, Yax.one(conn))
end
```

and let your client decide what they need: 

`https://www.foo.com/api/posts?select=id,title,body,comments(inserted_at),comments.users(avatar,name)`

Yax will introspect your Ecto schemas, preload your assocations, scope everything, and give you back 
just what you asked for. And just what your user is allowed.

Suddenly, your GraphQL Query definitions have turned back into good old Phoenix routes. We can compose them,
add them to pipelines. They become part of the Phoenix ecosystem, not an entity on their own. Yet we still 
retain the consistent schema and reliable response types that GQL offers.

It doesn't end there. (well, it does right now, but this is definitely something that needs to exist:)

Why do we still need controllers? `Phoenix.Router` doesn't ask for them. A controller is just a Plug 
after all. Why not just whack this in your Router.ex? 

What controller?

```
  get("/posts/:id", Yax.Controller, Foo.Posts.Post)
  get("/posts", Yax.Controller, Foo.Posts.Post)
```

I mean really we don't even need that first route. `GET /posts?id=1` is the same as `GET /posts/1`, right?
If anything it's clearer. Well, sort of.

Suddenly it's all disappeared. You've gone from `Ecto model -> Context <-> Policy/Scope -> Controller -> Router -> User`

Why don't we just go `Ecto model -> Router -> User`?

That's Yax.

/brain dump

Like the idea? Get in touch. We're using this for [Codex](https://codex.jbrew.co.uk/), so expect active
development.


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `yax` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:yax, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/yax](https://hexdocs.pm/yax).

