# frozen_string_literal: true

# includes modules from stdlib
require "cgi"
require "time"

# third party gems
require "snaky_hash"
require "version_gem"

# includes gem files
require_relative "oauth2/version"
require_relative "oauth2/filtered_attributes"
require_relative "oauth2/error"
require_relative "oauth2/authenticator"
require_relative "oauth2/client"
require_relative "oauth2/strategy/base"
require_relative "oauth2/strategy/auth_code"
require_relative "oauth2/strategy/implicit"
require_relative "oauth2/strategy/password"
require_relative "oauth2/strategy/client_credentials"
require_relative "oauth2/strategy/assertion"
require_relative "oauth2/access_token"
require_relative "oauth2/response"

# The namespace of this library
module OAuth2
  OAUTH_DEBUG = ENV.fetch("OAUTH_DEBUG", "false").casecmp("true").zero?
  DEFAULT_CONFIG = SnakyHash::SymbolKeyed.new(
    silence_extra_tokens_warning: true,
    silence_no_tokens_warning: true,
  )
  @config = DEFAULT_CONFIG.dup
  class << self
    attr_reader :config
  end
  def configure
    yield @config
  end
  module_function :configure
end

OAuth2::Version.class_eval do
  extend VersionGem::Basic
end
