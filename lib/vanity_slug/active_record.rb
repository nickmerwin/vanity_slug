ActiveSupport.on_load :active_record do
  module VanitySlug
    module ActiveRecord
      def has_vanity_slug(opts={})
        unless opts[:do_not_set]
          validate :check_vanity_slug
          before_validation :set_vanity_slug, on: :create
        end

        opts = {
          field_to_slug: :name,
          slug_field: :slug,
          action: "/#{self.to_s.tableize}/:id"
        }.merge opts

        class_attribute :has_vanity_slug_opts
        self.has_vanity_slug_opts = opts

        class_attribute :field_to_slug
        self.field_to_slug = opts[:field_to_slug]

        class_attribute :slug_field
        self.slug_field = opts[:slug_field]

        class_attribute :vanity_action
        self.vanity_action = opts[:vanity_action]

        VanitySlug.add_class self

        include InstanceMethods
      end

      module InstanceMethods

        def get_vanity_action
          action = self.class.has_vanity_slug_opts[:action]

          if action.is_a?(Proc)
            self.instance_eval &action
          else
            action.gsub(/:(.+?)(?=\/|$)/){ |s| send s[1..-1] }
          end
        end

        def set_vanity_slug
          potential_slug = send(self.class.field_to_slug).parameterize
          i = 1

          if vanity_slug_exists?(potential_slug)
            potential_slug += "-#{i}"

            while vanity_slug_exists?(potential_slug)
              potential_slug.gsub!(/-\d$/, "-#{i += 1}")
            end
          end

          self.send "#{self.class.slug_field}=", potential_slug
        end

        def check_vanity_slug
          slug_to_check = send(self.class.slug_field)

          exists = VanitySlug.classes.any? do |klass|
            scope = klass.has_vanity_slug_opts[:uniqueness_scope]
            conditions = scope ? { scope => send(scope) } : {}

            finder = klass.where(conditions.merge({
              klass.slug_field => slug_to_check
            }))

            finder = finder.where("id != ?", self.id) if klass.to_s == self.class.to_s
            finder.count > 0
          end

          if exists
            errors.add :slug, "already exists"
          end

          if VanitySlug.check_route_collision(slug_to_check)
            errors.add :slug, "conflicts with another url"
          end
        end

        def vanity_slug_exists?(potential_slug)
          return true if VanitySlug.check_route_collision(potential_slug)

          VanitySlug.classes.any? do |klass|
            scope = klass.has_vanity_slug_opts[:uniqueness_scope]
            conditions = scope ? { scope => send(scope) } : {}
            klass.exists? conditions.merge({ klass.slug_field => potential_slug })
          end
        end
      end
    end

    class << self
      attr_accessor :path_scope
      attr_accessor :classes

      def add_class(klass)
        @classes ||= []
        @classes << klass unless @classes.include?(klass)
      end

      def find(env)
        path = env["PATH_INFO"]
        base_path = File.basename path, ".*"

        slug = base_path.gsub(/^\//,'')

        conditions = @path_scope ? @path_scope.call(env) : {}

        obj = nil
        @classes.any? do |klass|
          obj = klass.where(conditions.merge({ klass.slug_field => slug }))
            .first
        end
        return false unless obj

        obj.get_vanity_action + File.extname(path)
      end

      def check_route_collision(path)
        if defined?(Rails)
          begin
            return true if Rails.application.routes.recognize_path(path) || Rails.application.routes.recognize_path(path, method: :post)
          rescue ActionController::RoutingError
            false
          end
        end
      end

    end
  end

  ActiveRecord::Base.extend VanitySlug::ActiveRecord
end
