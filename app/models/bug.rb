require 'elasticsearch/model'

class Bug < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  belongs_to :app, touch: true
  has_one :state, dependent: :destroy
  before_create :auto_assign_number
  status_opts = [['New', 'new'], ['In-progress', 'inprogress'], ['Closed', 'closed']]
  priority_opts = [['Minor', 'minor'], ['Major', 'major'], ['Critical', 'critical']]

  validates_inclusion_of :status, :in => status_opts
  validates_inclusion_of :priority, :in => priority_opts

  def self.search(q)
    __elasticsearch__.search({
       query: {
           match_phrase: {
               query: q[:query],
               fields: ['number', 'status', 'priority']
           },
           match: {
               query: q[:query],
               fields: ['comment']
           }

       },
       }
    ).records.all

  end

  def auto_assign_number(token)
    self.number ||= Bug.next_bug_number(token)
  end

  # There're two cache stores for the case of rolling back
  def self.next_bug_number(application_token)
    number_cache_key = "bug_number:#{application_token}"
    # I should've fetch the record then increment it, this code may counter a problem in the else part
    if Rails.cache.exist?(number_cache_key, raw: true)
      Rails.cache.increment(number_cache_key)
    else
      last_bug = Bug.where("application_token = ?", application_token).last
      last_bug = last_bug ? last_bug.number : 0
      Rails.cache.write(number_cache_key,
                        last_bug + 1,
                        raw: true)
    end
    Rails.cache.read(number_cache_key, raw: true).to_i
  end

end
