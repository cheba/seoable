module Seoable
  module ActsAsSeoable
    extend ActiveSupport::Concern

    included do
      cattr_accessor :acts_as_seoable

      extend FriendlyId
      friendly_id :slug, use: :finders

      default_scope { joins_seo_detail }
      scope :joins_seo_detail, -> { includes(:seo_detail) }

      delegate :meta_title, to: :seo_detail, allow_nil: true
      delegate :meta_title=, to: :seo_detail, allow_nil: true
      delegate :meta_description, to: :seo_detail, allow_nil: true
      delegate :meta_description=, to: :seo_detail, allow_nil: true
      delegate :slug, to: :seo_detail, allow_nil: true
      delegate :slug=, to: :seo_detail, allow_nil: true

      after_save do
        seo_detail.save
      end

      after_destroy do
        seo_detail.destroy
      end

      validate do
        if seo_detail.invalid?
          errors.add(:seo_detail, :invalid)
        end
      end
    end

    def seo_detail
      @seo_detail ||= SeoDetail.where(seoable: self).first_or_initialize(seo_detail_attributes)
    end

    def seo_detail_attributes
      {
        meta_title: sluggable,
        seoable: self,
        slug: sluggable.to_slug
      }
    end

    private

      def sluggable
        attribute = Seoable.configuration
                    .sluggable_attributes.find do |sluggable_attribute|
                      self.respond_to?(sluggable_attribute)
                    end
        send(attribute).to_s
      end
  end
end

module FriendlyId
  module FinderMethods
    def first_by_friendly_id(id)
      find_by('"seo_details".' + friendly_id_config.query_field => id)
    end
  end
end

class String
  def to_slug
    parameterize
  end
end
