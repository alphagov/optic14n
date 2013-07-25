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

Canonicalize it according to the Previously-Established Rules thusly:

```ruby
  bluri.canonicalize!
```

While you can also do things like

```ruby
  bluri.delete_keys(:a)
```

and

```ruby
  bluri['a'] = 99
```

these are a hangover from a previous use case and may not stick around.



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
