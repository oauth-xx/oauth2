# encoding: utf-8
# frozen_string_literal: true

gem_version =
  if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.1")
    # Loading version into an anonymous module allows version.rb to get code coverage from SimpleCov!
    # See: https://github.com/simplecov-ruby/simplecov/issues/557#issuecomment-2630782358
    Module.new.tap { |mod| Kernel.load("lib/oauth2/version.rb", mod) }::OAuth2::Version::VERSION
  else
    require_relative "lib/oauth2/version"
    OAuth2::Version::VERSION
  end

Gem::Specification.new do |spec|
  # Linux distros may package ruby gems differently,
  #   and securely certify them independently via alternate package management systems.
  # Ref: https://gitlab.com/oauth-xx/version_gem/-/issues/3
  # Hence, only enable signing if the cert_file is present.
  # See CONTRIBUTING.md
  default_user_cert = "certs/#{ENV.fetch("GEM_CERT_USER", ENV["USER"])}.pem"
  default_user_cert_path = File.join(__dir__, default_user_cert)
  cert_file_path = ENV.fetch("GEM_CERT_PATH", default_user_cert_path)
  cert_chain = cert_file_path.split(",")
  if cert_file_path && cert_chain.map { |fp| File.exist?(fp) }
    spec.cert_chain = cert_chain
    if $PROGRAM_NAME.end_with?("gem", "rake") && ARGV[0] == "build"
      spec.signing_key = File.expand_path("~/.ssh/gem-private_key.pem")
    end
  end

  spec.authors = ["Peter Boling", "Erik Michaels-Ober", "Michael Bleigh"]
  spec.summary = "OAuth 2.0 Core Ruby implementation"
  spec.description = "A Ruby wrapper for the OAuth 2.0 protocol built with a similar style to the original OAuth spec."
  spec.email = ["peter.boling@gmail.com", "oauth-ruby@googlegroups.com"]
  spec.homepage = "https://gitlab.com/oauth-xx/oauth2"
  spec.licenses = "MIT"
  spec.name = "oauth2"
  spec.required_ruby_version = ">= 2.2.0"
  spec.version = gem_version
  spec.post_install_message = %{
You have installed oauth2 version #{gem_version}, congratulations!

There are BREAKING changes if you are upgrading from < v2, but most will not encounter them, and updating your code should be easy!
Please see:
• #{spec.homepage}/-/blob/main/SECURITY.md
• #{spec.homepage}/-/blob/v#{spec.version}/CHANGELOG.md#200-2022-06-21-tag
• Summary of most important breaking changes: #{spec.homepage}#what-is-new-for-v20

There are BUGFIXES in v2.0.10, which depending on how you relied on them instead of reporting and fixing them, may be BREAKING for you.
For more information please see:
https://railsbling.com/tags/oauth2

Important News:
1. Google Group is "active" (again)!
• https://groups.google.com/g/oauth-ruby/c/QA_dtrXWXaE
2. Non-commercial support for the 2.x series will end by April, 2026. Please make a plan to upgrade to the next version prior to that date.
Support will be dropped for Ruby 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 3.0, 3.1 and any other Ruby versions which will also have reached EOL by then.
3. Gem releases are now cryptographically signed with a 20-year cert, with checksums by stone_checksums.
4. I need your support.

If you are sentient, please consider a donation as I move toward supporting myself with Open Source work:
• https://liberapay.com/pboling
• https://ko-fi.com/pboling
• https://www.buymeacoffee.com/pboling
• https://github.com/sponsors/pboling

If you are a corporation, please consider supporting this project, and open source work generally, with a TideLift subscription.
• https://tidelift.com/funding/github/rubygems/oauth
• Or hire me. I am looking for a job!

Please report issues, and star the project!

Thanks, |7eter l-|. l3oling
}

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "#{spec.homepage}/-/tree/v#{spec.version}"
  spec.metadata["changelog_uri"] = "#{spec.homepage}/-/blob/v#{spec.version}/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/-/issues"
  spec.metadata["documentation_uri"] = "https://www.rubydoc.info/gems/#{spec.name}/#{spec.version}"
  spec.metadata["wiki_uri"] = "#{spec.homepage}/-/wiki"
  spec.metadata["mailing_list_uri"] = "https://groups.google.com/g/oauth-ruby"
  spec.metadata["news_uri"] = "https://www.railsbling.com/tags/#{spec.name}"
  spec.metadata["funding_uri"] = "https://liberapay.com/pboling"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir[
    # Splats (alphabetical)
    "lib/**/*",
  ]
  # Automatically included with gem package, no need to list again in files.
  spec.extra_rdoc_files = Dir[
    # Files (alphabetical)
    "CHANGELOG.md",
    "CODE_OF_CONDUCT.md",
    "CONTRIBUTING.md",
    "LICENSE.txt",
    "README.md",
    "SECURITY.md",
  ]
  spec.rdoc_options += [
    "--title",
    "#{spec.name} - #{spec.summary}",
    "--main",
    "README.md",
    "--line-numbers",
    "--inline-source",
    "--quiet",
  ]
  spec.require_paths = ["lib"]
  spec.bindir = "exe"
  spec.executables = []

  spec.add_dependency("faraday", [">= 0.17.3", "< 3.0"])
  spec.add_dependency("jwt", [">= 1.0", "< 3.0"])
  spec.add_dependency("multi_xml", "~> 0.5")
  spec.add_dependency("rack", [">= 1.2", "< 4"])
  spec.add_dependency("snaky_hash", "~> 2.0")
  spec.add_dependency("version_gem", ">= 1.1.8", "< 3") # Ruby >= 2.2.0

  spec.add_development_dependency("addressable", ">= 2")
  spec.add_development_dependency("backports", ">= 3")
  spec.add_development_dependency("nkf", "~> 0.2")
  spec.add_development_dependency("rake", ">= 12")
  spec.add_development_dependency("rexml", ">= 3")
  spec.add_development_dependency("rspec", ">= 3")
  spec.add_development_dependency("rspec-block_is_expected")
  spec.add_development_dependency("rspec-pending_for")
  spec.add_development_dependency("rspec-stubbed_env")
  spec.add_development_dependency("silent_stream")
end
