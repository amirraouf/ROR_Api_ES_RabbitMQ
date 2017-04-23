require 'elasticsearch/model'

class Bug < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  belongs_to :app, touch: true
  has_one :state, dependent: :destroy

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

end
