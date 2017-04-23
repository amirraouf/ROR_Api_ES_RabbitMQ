class App < ApplicationRecord
  has_secure_token

  has_many :bugs, class_name: 'Bug', primary_key: 'id', foreign_key: :token
end
