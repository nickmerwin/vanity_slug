module VanitySlug
  class VanityRouter
    def initialize(app)
      @app = app
    end

    def call(env)
      begin
        Rails.application.routes.recognize_path env["PATH_INFO"] 
      rescue
        if path = VanitySlug.find(env)
          env["PATH_INFO"] = path
        end
      end

      @app.call(env)
    end
  end
end