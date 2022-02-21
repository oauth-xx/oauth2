# frozen_string_literal: true

module OAuth2
  # Hash which allow assign string key in camel case
  # and query on both camel and snake case
  class SnakyHash < ::Hashie::Mash::Rash
  end
end
