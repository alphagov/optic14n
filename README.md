# Optic14n

Canonicalises URLs.

## Installation

Add this line to your application's Gemfile:

    gem 'optic14n'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install optic14n

## Usage

Parse a `BLURI` like this:

```ruby
  bluri = BLURI('http://somewhere.com/?a=1&b=2&c=3')
```

Canonicalize it according to the [Previously-Established Rules](#the-previously-established-rules) thusly:

```ruby
  bluri.canonicalize!
```

You can also do site-specific stuff if you know some of the querystring will be valuable
```ruby
  bluri.canonicalize!(allow_query: :all)
```

```ruby
  bluri.canonicalize!(allow_query: [:a, :c])
  # or
  bluri.canonicalize!(allow_query: ['a', 'c'])
```

### The previously-established rules

This is a gem for canonicalising HTTP URIs such that we can boil our input set of URIs down to something that is much
smaller than it would otherwise be. We do this aggressively by:

* lowercasing URIs
* removing query strings (unless told otherwise)
* removing fragments
* escaping and unescaping various characters and escape sequences according to RFC3986

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Licence

[MIT License](LICENCE)
