# frozen_string_literal: true

require 'json'
require 'sequel'

module ISSInternship
  # Models a interview
  class Interview < Sequel::Model
    many_to_one :owner, class: :'ISSInternship::Account'

    plugin :uuid, field: :id
    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :position, :time, :interview_location, :level, :recruit_source,
                        :rating, :result, :description, :waiting_result_time, :advice,
                        :iss_module, :company_name, :non_anonymous

    # Secure getters and setters
    def description
      SecureDB.decrypt(description_secure)
    end

    def description=(plaintext)
      self.description_secure = SecureDB.encrypt(plaintext)
    end

    def advice
      SecureDB.decrypt(advice_secure)
    end

    def advice=(plaintext)
      self.advice_secure = SecureDB.encrypt(plaintext)
    end

    # rubocop:disable Metrics/MethodLength
    def to_h
      {
        type: 'interview',
        attributes: {
          id: id,
          position: position,
          time: time,
          interview_location: interview_location,
          level: level,
          recruit_source: recruit_source,
          rating: rating,
          result: result,
          description: description,
          waiting_result_time: waiting_result_time,
          advice: advice,
          iss_module: iss_module,
          company_name: company_name,
          non_anonymous: non_anonymous,
          author: author_name
        }
      }
    end
    # rubocop:enable Metrics/MethodLength

    def full_details
      to_h.merge(
        relationships: {
          owner: owner
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end

    def author_name
      if non_anonymous
        owner.username
      else
        'Anonymous'
      end
    end
  end
end
