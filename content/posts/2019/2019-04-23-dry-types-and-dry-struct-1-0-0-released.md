---
title: "dry-types and dry-struct 1.0.0 released"
date: 2019-04-23 12:00 UTC
author: Peter Solnica
---

We're very happy to announce the release of `dry-types` and `dry-struct` 1.0.0! `dry-types` is one of the most important and foundational gem in the dry-rb organization. It powers attributes in `dry-struct`, handles coercion in `dry-schema`, and is used extensively in [`rom-rb`](https://rom-rb.org/)'s relation schemas. With this 1.0.0 release, we hope it will be adopted by more projects. `dry-struct` was originally extracted from `dry-types` and it provides the famous `attribute` API for your PORO objects.

Huge props go to [Nikita Shilnikov](https://github.com/flash-gordon) who has worked so hard to finalize these releases which bring a lot of improvements. Let's look at some of the highlights.

### Configurable types module

Previously you could include all built-in types into your own module via `include Dry::Types.module`. This was changed to a configurable module builder. Now you can cherry-pick which type namespaced categories you want, which types should be used by default and even rename namespaces. Here are some examples:

``` ruby
# Cherry-pick which categories you want
module Types
  include Dry.Types(:strict, :nominal, :coercible)
end

Types::String
# => #<Dry::Types[Constrained<Nominal<String> rule=[type?(String)]>]>

Types.constants
# => [:Strict, :Nominal, :Coercible]

# Change default category to be `:coercible`
module Types
  include Dry.Types(default: :coercible)
end

Types::String
# => #<Dry::Types[Constructor<Nominal<String> fn=Kernel.String>]>

# Rename default categories
module Types
  include Dry.Types(strict: :Strong, coercible: :Kernel)
end

Types::Kernel::String
=> #<Dry::Types[Constructor<Nominal<String> fn=Kernel.String>]>
```

### Constructors support prepending and appending

Previously it was only possible to append a constructor function. This was too limiting because it wasn't easy to extend and re-use existing constructors. Now it's possible to either append or prepend a new constructor:

``` ruby
to_int = Types::Coercible::Integer
inc = to_int.append { |x| x + 2 }
inc.("1") # => "1" -> 1 -> 3

inc = to_int.prepend { |x| x + "2" }
inc.("1") # => "1" -> "12" -> 12
```

This feature should be very useful in places like rom-rb's schemas or dry-schema, where you may want to pre-process data and then re-use existing coercion logic.

### Shortcut syntax for optional keys in Hash schemas

You can now use key names ending with `?` to denote an optional key. Here's how it looks in practice in a struct definition:

``` ruby
hash_schema = Types::Hash.schema(email: Types::String, name?: Types::String, age?: Types::Integer)

hash_schema[email: 'jane@doe.org']
# => {:email=>"jane@doe.org"}

hash_schema[email: 'jane@doe.org', name: 'Jane', age: 31]
# => {:email=>"jane@doe.org", :name=>"Jane", :age=>31}
```

### Type-safe coercions by default and Lax types

All the built-in coercion types have been changed to *raise exceptions on unexpected input*. If you want to get back the original input when coercion fails, rather than getting an exception, you can use `Lax` types, which will rescue known type-related errors:

``` ruby
Types::Params::Float['oops']
# Dry::Types::CoercionError: invalid value for Float(): "oops"

lax_float = Types::Params::Float.lax
lax_float['oops']
=> "oops"
```

### ...and more

There are a lot of other features, improvements, optimizations and fixes in this release. *Please refer to the CHANGELOGS* for a full overview:

* [`dry-types 1.0.0 CHANGELOG`](https://github.com/dry-rb/dry-types/blob/main/CHANGELOG.md#100-2019-04-23)
* [`dry-struct 1.0.0 CHANGELOG`](https://github.com/dry-rb/dry-struct/blob/main/CHANGELOG.md#100-2019-04-23)

Please give it a go and let us know what you think!

We're also wrapping up `dry-validation` and `dry-schema` 1.0.0, stay tuned for more good news :)
