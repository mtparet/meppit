module Contributable
  extend ActiveSupport::Concern

  included do
    has_many :contributings, :foreign_key => :contributable_id
    has_many :contributors, :through => :contributings

    def contributors_count
      contributors.size
    end
  end
end
