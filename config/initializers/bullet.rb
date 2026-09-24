# frozen_string_literal: true

if Rails.env.development?
  Bullet.enable = true
  Bullet.rails_logger = true
  Bullet.add_footer = false
end
