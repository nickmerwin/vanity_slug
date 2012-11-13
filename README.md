# VanitySlug

Add unique vanity urls to any model without use of redirects. 
Routing trickery via middleware like so:

    "/my-post-title" => "/posts/1"
    "/the-category" => "/category/2"

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
  
  * action: route vanity slug will resolve to, "/posts/:id"
  * field_to_slug: which column to use in vanity slug generation
  * slug_field: which column to store generated slug
  * uniqueness_scope: method or attribute to use as uniqueness check in slug
    generation

#### Config

  ```ruby
    VanitySlug.path_scope Proc.new { |env| { } }
  ```

Use to scope the finder based on rack env, i.e. host parameter.

## Examples:

  ```ruby
    class Post < ActiveRecord::Base
      attr_accessible :title, :site

      has_vanity_slug action: "/posts/:id", 
        field_to_slug: :title, 
        uniqueness_scope: :site_id

      belongs_to :site
    end

    class Category < ActiveRecord::Base
      attr_accessible :name, :site

      has_vanity_slug action: "/categories/:id/slug", 
        slug_field: :permalink

      belongs_to :site
    end

    class Site < ActiveRecord::Base
      attr_accessible :domain
    end
  ```

### Initializer:

  ```ruby
    VanitySlug.path_scope = Proc.new{|env|
      { organization_id: Organization.find_by_host(env["HTTP_HOST"]).try(:id) }
    }
  ```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
