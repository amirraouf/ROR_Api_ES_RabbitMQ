class State < ApplicationRecord
  belongs_to :bug
  validates :device, :bug_id, :os, presence: true
  validates :memory, :storage,  numericality: { only_integer: true }
end
