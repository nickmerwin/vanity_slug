require 'spec_helper'
require 'support/active_record'

VanitySlug.path_scope = Proc.new{|env|
  { site_id: Site.find_by_domain(env["HTTP_HOST"]).try(:id) }
}

class Post < ActiveRecord::Base
  attr_accessible :title, :site

  has_vanity_slug field_to_slug: :title,
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

describe VanitySlug do
  let(:str) { "slug me" }
  let(:str_slugged) { "slug-me" }

  before do
    @site_1 = Site.create domain: "a.com"
    @site_2 = Site.create domain: "b.com"

    @post_1 = Post.create title: str, site: @site_1
    @post_2 = Post.create title: str, site: @site_1
    @post_3 = Post.create title: str, site: @site_2

    10.times do
      Post.create title: str, site: @site_1
    end

    @category_1 = Category.create name: str, site: @site_1
    @category_2 = Category.create name: str, site: @site_2
  end

  context "setting slugs" do

    it { @post_1.slug.should eq str_slugged }
    it { @post_2.slug.should eq str_slugged+"-1" }
    it { @post_3.slug.should eq str_slugged }
    it { @category_1.permalink.should eq str_slugged+"-12" }
    it { @category_2.permalink.should eq str_slugged+"-1" }

    it { Post.last.slug.should eq str_slugged + "-11" }

    it do
      env = {"HTTP_HOST" => @site_1.domain, "PATH_INFO" => "/#{@post_1.slug}"}
      VanitySlug.find(env).should eq "/posts/#{@post_1.id}"
    end

    it do
      env = {"HTTP_HOST" => @site_1.domain, "PATH_INFO" => "/#{@post_2.slug}"}
      VanitySlug.find(env).should eq "/posts/#{@post_2.id}"
    end

    it do
      env = {"HTTP_HOST" => @site_2.domain, "PATH_INFO" => "/#{@post_3.slug}"}
      VanitySlug.find(env).should eq "/posts/#{@post_3.id}"
    end

    it do
      env = {"HTTP_HOST" => @site_1.domain, "PATH_INFO" => "/#{@category_1.permalink}"}
      VanitySlug.find(env).should eq "/categories/#{@category_1.id}/slug"
    end

    it do
      env = {"HTTP_HOST" => @site_2.domain, "PATH_INFO" => "/#{@category_2.permalink}"}
      VanitySlug.find(env).should eq "/categories/#{@category_2.id}/slug"
    end

    it do
      env = {"HTTP_HOST" => "c.com", "PATH_INFO" => "/#{@category_2.permalink}"}
      VanitySlug.find(env).should be false
    end
  end

  context "updating slug source column" do
    let(:new_title) { "#{str} edit" }
    before do
      @post_1.update_attributes title: new_title
    end

    it { @post_1.should be_valid }
    it { @post_1.title.should eq new_title }
  end
end
