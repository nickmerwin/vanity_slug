# VanitySlug

[![Test Coverage](https://coveralls.io/repos/nickmerwin/vanity_slug/badge.png?branch=master)](https://coveralls.io/r/nickmerwin/vanity_slug) 

Add unique vanity urls to any model without use of redirects. Middleware matches routes that don't resolve with the Rails router and checks if they match a slug from any vanity-slug enabled model. If found, the `env["PATH_INFO"]` is changed like so:

    Given a Post with slug "my-post-title" and id 1, and a Category with slug "the-category" and id 2:

    "/my-post-title" => "/posts/1"
    "/the-category" => "/category/2"

This lets Rails do the rest of the work.

## Installation

Add this line to your application's Gemfile:

    gem 'vanity_slug'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vanity_slug

## Usage

    has_vanity_slug

### Options
  
  * action: route vanity slug will resolve to (default: RESTful show route i.e. "/posts/:id"). Route must be defined.
  * field_to_slug: which column to use in vanity slug generation (default: :name).
  * slug_field: which column to store generated slug (default: :slug).
  * uniqueness_scope: method or attribute to use as uniqueness scope in slug
    generation (default: nil).

#### Config

  ```ruby
    VanitySlug.path_scope Proc.new { |env| { } }
  ```

Use to scope the finder based on rack env, i.e. host parameter. Should return a hash suitable for a `where` relational argument.

### Gotchas

  * no catch all routes may be used in Rails, otherwise the route collision check
    will always find a matching route

## Examples:

  ```ruby
    class Post < ActiveRecord::Base
      attr_accesible :title

      has_vanity_slug field_to_slug: :title, uniqueness_scope: :site_id

      belongs_to :site
    end

    class Category < ActiveRecord::Base
      attr_accesible :name

      has_vanity_slug action: "/categories/:id/slug", slug_field: :permalink

      belongs_to :site
    end

    class Site < ActiveRecord::Base
      attr_accessible :domain
    end
  ```

### Initializer:

  ```ruby
    VanitySlug.path_scope = Proc.new{|env|
      { site_id: Site.find_by_domain(env["HTTP_HOST"]).try(:id) }
    }
  ```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request



