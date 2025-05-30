---
title: dry-validation 0.8.0 released
date: 2016-07-01 12:00 UTC
author: Peter Solnica
---

After 2 months of hard work we are happy to announce the release of dry-validation 0.8.0! This release includes many new features, performance improvements and important bug fixes.

## Upgrading

If you are upgrading from 0.7.x you should see plenty of deprecation warnings related to renamed macros and predicates. Updating it is pretty straightforward, but if you don’t feel like doing it now and warnings are annoying while you’re running your tests, just configure deprecation logger and revisit the output later:

``` ruby
Dry::Validation::Deprecations.configure do |config|
  config.logger = Logger.new(SPEC_ROOT.join('../log/deprecations.log'))
end
```

If you use customized error messages, you may have to update some of them as a couple of tokens have been renamed. Please [see recent history](https://github.com/dry-rb/dry-validation/commits/main/config/errors.yml) of the built-in errors.yml for more details.

If you use custom predicates modules, there’s a new interface for configuring it and **the old one no longer works**:

``` ruby
Dry::Validation.Schema do
  configure { predicates(MyCustomPredicates) }
end
```

Please also notice that this release **depends on latest dry-types and dry-logic**.

Let’s take a look at a couple of highlights of this release.

## New macros

We have refined existing macros and added a couple of new ones to allow rule compositions which were not possible before.

The new `filled` macro (which replaces `required`) and the `maybe` macro now support blocks too, and both are based on a simpler, new macro called `value`.

The `key` macro has been renamed to `required` which makes it easier to understand the difference between defining required or optional keys and rules for their values.

Here’s an example:

``` ruby
Dry::Validation.Schema do
  required(:name).filled(:str?, min_size?: 3)
  required(:age).filled(:int?, gt?: 18)
  optional(:phone_number).filled(:str?)
end
```

Now you can also use blocks:

``` ruby
Dry::Validation.Schema do
  required(:data).maybe(type?: Array) { size?(2) | size?(4) }
  required(:logs).value { type?(Array) | type?(Hash) }
end
```

This allows you to define each rules with additional rules for the value itself. For example let’s define a rule where the `:data` key is required and its value must be an array with 3 elements - where every element is an integer:

``` ruby
Dry::Validation.Schema do
  required(:data).value(type?: Array, min_size?: 3) { each(:int?) }
end
```

## New predicates

A bunch of useful predicates have been added:

- `:included_in?` when a value must be one of the specified values
- `:excluded_from?` the opposite of `:included_in?`
- `:not_eql?` when a value must not equal given value
- `:odd?` and `:even?`

Here are some examples:

``` ruby
Dry::Validation.Schema do
  required(:tags).filled(:str?, included_in?: %w(red green blue))
  required(:num).filled(:int?, not_eql?: 10)
end
```

## Customizable hints

In addition to a number of bug fixes, we've added support for defining a seperate message for hints and error messages. This allows you to customize messages when a value didn’t pass basic checks and you want to display additional messages that are different than errors:

To make use of this feature you need to tweak your `errors.yml` as follows:

``` yaml
en:
  errors:
    min_size?:
      failure: "size can't be less than %{num}"
      hint: "please make sure it has at least %{num} chars"
```

Now hints will be different than actual validation errors:

``` ruby
UserSchema = Dry::Validation.Schema do
  required(:login).filled(:str?, min_size?: 3)
end

UserSchema.(login: "").messages
# {:login=>["must be filled", "please make sure it has at least 3 chars"]}

UserSchema.(login: "fo").messages
{:login=>["size can't be less than 3"]}
```

## Root-level rules

A root-level rule is applied to an input **before** any other rules in your schema. It's a useful feature for cases where you can't guarantee that the input will be the correct type (i.e. you don’t know if it will always be a hash).

Usage is very simple:

``` ruby
UserSchema = Dry::Validation.Schema do
  input :hash? # our root-level rule

  required(:name).filled(:str?)
end

UserSchema.(nil).messages # ["must be a hash"]
```

Notice that when a root-level rule fails, `messages` returns a flat array rather than a hash.

## Support for zero-arity predicates

For context-aware schemas you can now define rules with predicates that rely on a schema’s state and don’t need any arguments.

Let’s say we want to make sure that `:login_time` exists for users that are logged in. We can verify this by checking if `current_user[:id]` exists using the following custom predicate:

``` ruby
UserSchema = Dry::Validation.Schema do
  configure do
    option :current_user, {}

    def current_user?
      current_user && current_user[:id]
    end
  end

  required(:login_time).maybe(:date_time?)

  rule(require_login_time: [:login_time]) do |login_time|
    current_user?.then(login_time.filled?)
  end
end

UserSchema.(name: "Jane", login_time: nil).messages
# {}

schema = UserSchema.with(current_user: { id: 1 })

schema.(name: "Jane", login_time: DateTime.now).messages
# {}

schema.(name: "Jane", login_time: nil).messages
# {:login_time=>["must be filled"]}
```

## Improved messages

Messages now have access to **all** predicate arguments by default. If you add a custom predicate with arguments, the argument values will be available in your message templates using the name of the argument as the token.

For example:

``` yaml
en:
  errors:
    source_valid?: "my message has access to %{source} and %{target} :D"
```

``` ruby
UserSchema = Dry::Validation.Schema do
  configure do
    def source_valid?(source, target)
      false
    end
  end

  required(:data).value(source_valid?: "TADA")
end

UserSchema.(data: "w00t").messages
# {:data=>["my message has access to TADA and w00t :D"]}
```

## New way of configuring coercions

The default behavior for coercions is to automatically infer them from rule definitions. It’s smart and reduces code duplication; however, it turned out to be extremely slow. Furthermore, it's behaviour was a little too magical for our liking. That’s why we have decided to separate coercions from validation rules as of version 1.0.0. This release is the first step in that direction. The current API is not finalised so ideas and feedback are much appreciated!

For more details on this feature [see our guide here](/gems/dry-validation/0.13/type-specs).

## Extendible DSL

You can now provide your own methods to DRY up your schema definitions:

``` ruby
module MyMacros
  def maybe_int(name, *predicates, &block)
    required(name).maybe(:int?, *predicates, &block)
  end
end

Dry::Validation::Schema.configure do |config|
  config.dsl_extensions = MyMacros
end

Dry::Validation.Schema do
  maybe_int(:age, gt?: 18)
end
```

Feel free to experiment with this and if you discover any common patterns let us know by reporting an issue. It might be a good candidate to be added to dry-validation!

## …and more!

Yes, there’s more :) For detailed information about the changes and improvements please read the [CHANGELOG](https://github.com/dry-rb/dry-validation/blob/main/CHANGELOG.md#v080-2016-07-01).

Check out dry-validation and [tell us what you think](https://dry-rb.zulipchat.com)!
