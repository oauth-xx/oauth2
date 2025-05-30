# frozen_string_literal: true

RSpec.describe OAuth2::AccessToken do
  subject { described_class.new(client, token, token_options) }

  let(:base_options) { {site: "https://api.example.com"} }
  let(:token_options) { {} }
  let(:options) { {} }
  let(:token) { "monkey" }
  let(:refresh_body) { JSON.dump(access_token: "refreshed_foo", expires_in: 600, refresh_token: "refresh_bar") }
  let(:client) do
    OAuth2::Client.new("abc", "def", options.merge(base_options)) do |builder|
      builder.request :url_encoded
      builder.adapter :test do |stub|
        VERBS.each do |verb|
          stub.send(verb, "/token/header") { |env| [200, {}, env[:request_headers]["Authorization"]] }
          stub.send(verb, "/token/query?access_token=#{token}") { |env| [200, {}, Addressable::URI.parse(env[:url]).query_values["access_token"]] }
          stub.send(verb, "/token/query_string") { |env| [200, {}, CGI.unescape(Addressable::URI.parse(env[:url]).query)] }
          stub.send(verb, "/token/body") { |env| [200, {}, env[:body]] }
        end
        stub.post("/oauth/token") { |_env| [200, {"Content-Type" => "application/json"}, refresh_body] }
        stub.post("/oauth/revoke") { |env| [200, {"Content-type" => "application/json"}, env[:body]] }
      end
    end
  end

  describe ".from_hash" do
    subject(:target) { described_class.from_hash(client, hash) }

    let(:hash) do
      {
        access_token: token,
        id_token: "confusing bug here",
        refresh_token: "foobar",
        expires_at: Time.now.to_i + 200,
        foo: "bar",
        header_format: "Bearer %",
        mode: :header,
        param_name: "access_token",
      }
    end

    it "return a hash equals to the hash used to initialize access token" do
      expect(target.to_hash).to eq(hash)
    end

    context "with warning for too many tokens" do
      subject(:printed) do
        capture(:stderr) do
          target
        end
      end

      before do
        @original_setw = OAuth2.config.silence_extra_tokens_warning
        OAuth2.config.silence_extra_tokens_warning = false
      end

      after do
        OAuth2.config.silence_extra_tokens_warning = @original_setw
      end

      it "warns on STDERR" do
        skip("Warning output we spit on Hashie without VERSION constant makes this test invalid") unless defined?(Hashie::VERSION)
        msg = <<-MSG.lstrip
            OAuth2::AccessToken.from_hash: `hash` contained more than one 'token' key ([:access_token, :id_token]); using :access_token.
        MSG
        expect(printed).to eq(msg)
      end

      context "when one token" do
        subject(:printed) do
          capture(:stderr) do
            target
          end
        end

        let(:hash) do
          {
            access_token: token,
          }
        end

        before do
          @original_setw = OAuth2.config.silence_extra_tokens_warning
          OAuth2.config.silence_extra_tokens_warning = false
        end

        after do
          OAuth2.config.silence_extra_tokens_warning = @original_setw
        end

        it "does not warn on STDERR" do
          skip("Warning output we spit on Hashie without VERSION constant makes this test invalid") unless defined?(Hashie::VERSION)
          expect(printed).to eq("")
        end
      end

      context "when silenced" do
        subject(:printed) do
          capture(:stderr) do
            target
          end
        end

        before do
          @original_setw = OAuth2.config.silence_extra_tokens_warning
          OAuth2.config.silence_extra_tokens_warning = true
        end

        after do
          OAuth2.config.silence_extra_tokens_warning = @original_setw
        end

        it "does not warn on STDERR" do
          skip("Warning output we spit on Hashie without VERSION constant makes this test invalid") unless defined?(Hashie::VERSION)
          expect(printed).to eq("")
        end
      end
    end

    context "with keys in a different order to the lookup" do
      subject(:printed) do
        capture(:stderr) do
          target
        end
      end

      before do
        @original_setw = OAuth2.config.silence_extra_tokens_warning
        OAuth2.config.silence_extra_tokens_warning = false
      end

      after do
        OAuth2.config.silence_extra_tokens_warning = @original_setw
      end

      let(:hash) do
        {
          id_token: "confusing bug here",
          access_token: token,
        }
      end

      it "warns on STDERR and selects the correct key" do
        skip("Warning output we spit on Hashie without VERSION constant makes this test invalid") unless defined?(Hashie::VERSION)
        msg = <<-MSG.lstrip
            OAuth2::AccessToken.from_hash: `hash` contained more than one 'token' key ([:access_token, :id_token]); using :access_token.
        MSG
        expect(printed).to eq(msg)
      end
    end

    context "with warning for no token keys" do
      subject(:printed) do
        capture(:stderr) do
          target
        end
      end

      before do
        @original_sntw = OAuth2.config.silence_no_tokens_warning
        OAuth2.config.silence_no_tokens_warning = false
      end

      after do
        OAuth2.config.silence_no_tokens_warning = @original_sntw
      end

      let(:options) { {raise_errors: true} }

      let(:hash) do
        {
          blather: "confusing bug here",
          rather: token,
        }
      end

      it "raises an error" do
        block_is_expected.to raise_error(OAuth2::Error)
      end

      context "when not raising errors" do
        let(:options) { {raise_errors: false} }

        it "warns on STDERR" do
          skip("Warning output we spit on Hashie without VERSION constant makes this test invalid") unless defined?(Hashie::VERSION)
          msg = <<-MSG.lstrip
            OAuth2::AccessToken has no token
          MSG
          expect(printed).to eq(msg)
        end

        context "when custom token_name valid" do
          let(:options) { {raise_errors: false} }

          let(:hash) do
            {
              "lollipop" => token,
              :expires_at => Time.now.to_i + 200,
              :foo => "bar",
              :header_format => "Bearer %",
              :mode => :header,
              :param_name => "lollipop",
              :token_name => "lollipop",
            }
          end

          it "finds token" do
            expect(target.token).to eq("monkey")
          end

          it "does not warn when token is found" do
            skip("Warning output we spit on Hashie without VERSION constant makes this test invalid") unless defined?(Hashie::VERSION)
            expect(printed).to eq("")
          end
        end

        context "when custom token_name invalid" do
          let(:options) { {raise_errors: false} }

          let(:hash) do
            {
              "babyshark" => token,
              :expires_at => Time.now.to_i + 200,
              :foo => "bar",
              :header_format => "Bearer %",
              :mode => :header,
              :param_name => "lollipop",
              :token_name => "lollipop",
            }
          end

          context "when silence_no_tokens_warning is false" do
            before do
              @original_sntw = OAuth2.config.silence_no_tokens_warning
              OAuth2.config.silence_no_tokens_warning = false
            end

            after do
              OAuth2.config.silence_no_tokens_warning = @original_sntw
            end

            it "finds no token" do
              expect(target.token).to eq("")
            end

            it "warns when no token is found" do
              skip("Warning output we spit on Hashie without VERSION constant makes this test invalid") unless defined?(Hashie::VERSION)
              expect(printed.each_line.to_a).to eq([
                "\n",
                "OAuth2::AccessToken#from_hash key mismatch.\n",
                %{Custom token_name (lollipop) is not found in (["babyshark", :expires_at, :foo, :header_format, :mode, :param_name, :token_name])\n},
                "You may need to set `snaky: false`. See inline documentation for more info.\n",
                "        \n",
                "OAuth2::AccessToken has no token\n",
              ])
            end
          end

          context "when silence_no_tokens_warning is true" do
            before do
              @original_sntw = OAuth2.config.silence_no_tokens_warning
              OAuth2.config.silence_no_tokens_warning = true
            end

            after do
              OAuth2.config.silence_no_tokens_warning = @original_sntw
            end

            it "finds no token" do
              expect(target.token).to eq("")
            end

            it "does not warn when no token is found" do
              skip("Warning output we spit on Hashie without VERSION constant makes this test invalid") unless defined?(Hashie::VERSION)
              expect(printed.each_line.to_a).to eq([])
            end
          end
        end
      end
    end
  end

  describe "#initialize" do
    it "assigns client and token" do
      expect(subject.client).to eq(client)
      expect(subject.token).to eq(token)
    end

    it "assigns extra params" do
      target = described_class.new(client, token, "foo" => "bar")
      expect(target.params).to include("foo")
      expect(target.params["foo"]).to eq("bar")
    end

    def assert_initialized_token(target)
      expect(target.token).to eq(token)
      expect(target).to be_expires
      expect(target.params.keys).to include("foo")
      expect(target.params["foo"]).to eq("bar")
    end

    it "initializes with a Hash" do
      hash = {:access_token => token, :expires_at => Time.now.to_i + 200, "foo" => "bar"}
      target = described_class.from_hash(client, hash)
      assert_initialized_token(target)
    end

    it "from_hash does not modify opts hash" do
      hash = {access_token: token, expires_at: Time.now.to_i}
      hash_before = hash.dup
      described_class.from_hash(client, hash)
      expect(hash).to eq(hash_before)
    end

    it "initializes with a form-urlencoded key/value string" do
      kvform = "access_token=#{token}&expires_at=#{Time.now.to_i + 200}&foo=bar"
      target = described_class.from_kvform(client, kvform)
      assert_initialized_token(target)
    end

    context "with options" do
      subject(:target) { described_class.new(client, token, options) }

      context "with body mode" do
        let(:mode) { :body }
        let(:options) { {param_name: "foo", header_format: "Bearer %", mode: mode} }

        it "sets options" do
          expect(target.options[:param_name]).to eq("foo")
          expect(target.options[:header_format]).to eq("Bearer %")
          expect(target.options[:mode]).to eq(mode)
        end
      end

      context "with header mode" do
        let(:mode) { :header }
        let(:options) { {headers: {}, mode: mode} }

        it "sets options" do
          expect(target.options[:headers]).to be_nil
          expect(target.options[:mode]).to eq(mode)
        end
      end

      context "with query mode" do
        let(:mode) { :query }
        let(:options) { {params: {}, param_name: "foo", mode: mode} }

        it "sets options" do
          expect(target.options[:param_name]).to eq("foo")
          expect(target.options[:params]).to be_nil
          expect(target.options[:mode]).to eq(mode)
        end
      end

      context "with invalid mode" do
        let(:mode) { :this_is_bad }
        let(:options) { {mode: mode} }

        it "does not raise on initialize" do
          block_is_expected.not_to raise_error
        end

        context "with request" do
          subject(:request) { target.post("/token/header") }

          it "raises" do
            block_is_expected.to raise_error("invalid :mode option of #{mode}")
          end
        end

        context "with client.options[:raise_errors] = true" do
          let(:mode) { :this_is_bad }
          let(:options) { {mode: mode, raise_errors: true} }

          before do
            expect(client.options[:raise_errors]).to be(true)
          end

          context "when there is a token" do
            it "does not raise on initialize" do
              block_is_expected.not_to raise_error
            end

            context "with request" do
              subject(:request) { target.post("/token/header") }

              it "raises" do
                block_is_expected.to raise_error("invalid :mode option of #{mode}")
              end
            end
          end

          context "when there is empty token" do
            let(:token) { "" }

            it "raises on initialize" do
              block_is_expected.to raise_error(OAuth2::Error, {error: "OAuth2::AccessToken has no token", error_description: "Options are: #{{mode: :this_is_bad, raise_errors: true}}"}.to_s)
            end
          end

          context "when there is nil token" do
            let(:token) { nil }

            it "raises on initialize" do
              block_is_expected.to raise_error(OAuth2::Error, {error: "OAuth2::AccessToken has no token", error_description: "Options are: #{{mode: :this_is_bad, raise_errors: true}}"}.to_s)
            end
          end
        end
      end

      context "with client.options[:raise_errors] = false" do
        let(:options) { {raise_errors: false} }

        before do
          expect(client.options[:raise_errors]).to be(false)
        end

        context "when there is a token" do
          let(:token) { "hurdygurdy" }

          it "does not raise on initialize" do
            block_is_expected.not_to raise_error
          end

          it "has token" do
            expect(target.token).to eq(token)
          end

          it "has no refresh_token" do
            expect(target.refresh_token).to be_nil
          end

          context "when there is refresh_token" do
            let(:options) { {raise_errors: false, refresh_token: "zxcv"} }

            it "does not raise on initialize" do
              block_is_expected.not_to raise_error
            end

            it "has token" do
              expect(target.token).to eq(token)
            end

            it "has refresh_token" do
              expect(target.refresh_token).to eq("zxcv")
            end
          end
        end

        context "when there is empty token" do
          let(:token) { "" }

          context "when there is no refresh_token" do
            it "does not raise on initialize" do
              block_is_expected.not_to raise_error
            end

            it "has no token" do
              expect(target.token).to eq("")
            end

            it "has no refresh_token" do
              expect(target.refresh_token).to be_nil
            end

            context "with warning for no token" do
              subject(:printed) do
                capture(:stderr) do
                  target
                end
              end

              before do
                @original_sntw = OAuth2.config.silence_no_tokens_warning
                OAuth2.config.silence_no_tokens_warning = false
              end

              after do
                OAuth2.config.silence_no_tokens_warning = @original_sntw
              end

              it "warns on STDERR" do
                msg = <<-MSG.lstrip
                  OAuth2::AccessToken has no token
                MSG
                expect(printed).to eq(msg)
              end
            end
          end

          context "when there is refresh_token" do
            let(:options) { {raise_errors: false, refresh_token: "qwer"} }

            it "does not raise on initialize" do
              block_is_expected.not_to raise_error
            end

            it "has no token" do
              expect(target.token).to eq("")
            end

            it "has refresh_token" do
              expect(target.refresh_token).to eq("qwer")
            end
          end
        end

        context "when there is nil token" do
          let(:token) { nil }

          before do
            @original_sntw = OAuth2.config.silence_no_tokens_warning
            OAuth2.config.silence_no_tokens_warning = false
          end

          after do
            OAuth2.config.silence_no_tokens_warning = @original_sntw
          end

          context "when there is no refresh_token" do
            it "does not raise on initialize" do
              block_is_expected.not_to raise_error
            end

            it "has no token" do
              expect(target.token).to eq("")
            end

            it "has no refresh_token" do
              expect(target.refresh_token).to be_nil
            end

            context "with warning for no token" do
              subject(:printed) do
                capture(:stderr) do
                  target
                end
              end

              it "warns on STDERR" do
                msg = <<-MSG.lstrip
                  OAuth2::AccessToken has no token
                MSG
                expect(printed).to eq(msg)
              end
            end
          end

          context "when there is refresh_token" do
            let(:options) { {raise_errors: false, refresh_token: "asdf"} }

            it "does not raise on initialize" do
              block_is_expected.not_to raise_error
            end

            it "has no token" do
              expect(target.token).to eq("")
            end

            it "has refresh_token" do
              expect(target.refresh_token).to eq("asdf")
            end
          end
        end
      end

      context "with client.options[:raise_errors] = true" do
        let(:options) { {raise_errors: true} }

        before do
          expect(client.options[:raise_errors]).to be(true)
        end

        context "when there is a token" do
          let(:token) { "hurdygurdy" }

          it "does not raise on initialize" do
            block_is_expected.not_to raise_error
          end

          it "has token" do
            expect(target.token).to eq(token)
          end

          it "has no refresh_token" do
            expect(target.refresh_token).to be_nil
          end

          context "when there is refresh_token" do
            let(:options) { {raise_errors: true, refresh_token: "zxcv"} }

            it "does not raise on initialize" do
              block_is_expected.not_to raise_error
            end

            it "has token" do
              expect(target.token).to eq(token)
            end

            it "has refresh_token" do
              expect(target.refresh_token).to eq("zxcv")
            end
          end
        end

        context "when there is empty token" do
          let(:token) { "" }

          context "when there is no refresh_token" do
            it "raises on initialize" do
              block_is_expected.to raise_error(OAuth2::Error, {error: "OAuth2::AccessToken has no token", error_description: "Options are: #{{raise_errors: true}}"}.to_s)
            end
          end

          context "when there is refresh_token" do
            let(:options) { {raise_errors: true, refresh_token: "qwer"} }

            it "does not raise on initialize" do
              block_is_expected.not_to raise_error
            end

            it "has no token" do
              expect(target.token).to eq("")
            end

            it "has refresh_token" do
              expect(target.refresh_token).to eq("qwer")
            end
          end
        end

        context "when there is nil token" do
          let(:token) { nil }

          context "when there is no refresh_token" do
            it "raises on initialize" do
              block_is_expected.to raise_error(OAuth2::Error, {error: "OAuth2::AccessToken has no token", error_description: "Options are: #{{raise_errors: true}}"}.to_s)
            end
          end

          context "when there is refresh_token" do
            let(:options) { {raise_errors: true, refresh_token: "asdf"} }

            it "does not raise on initialize" do
              block_is_expected.not_to raise_error
            end

            it "has no token" do
              expect(target.token).to eq("")
            end

            it "has refresh_token" do
              expect(target.refresh_token).to eq("asdf")
            end
          end
        end
      end
    end

    it "does not modify opts hash" do
      opts = {param_name: "foo", header_format: "Bearer %", mode: :body}
      opts_before = opts.dup
      described_class.new(client, token, opts)
      expect(opts).to eq(opts_before)
    end

    describe "expires_at" do
      let(:expires_at) { 1_361_396_829 }
      let(:hash) do
        {
          :access_token => token,
          :expires_at => expires_at.to_s,
          "foo" => "bar",
        }
      end

      it "initializes with an integer timestamp expires_at" do
        target = described_class.from_hash(client, hash.merge(expires_at: expires_at))
        assert_initialized_token(target)
        expect(target.expires_at).to eql(expires_at)
      end

      it "initializes with a string timestamp expires_at" do
        target = described_class.from_hash(client, hash)
        assert_initialized_token(target)
        expect(target.expires_at).to eql(expires_at)
      end

      it "initializes with a string time expires_at" do
        target = described_class.from_hash(client, hash.merge(expires_at: Time.at(expires_at).iso8601))
        assert_initialized_token(target)
        expect(target.expires_at).to eql(expires_at)
      end
    end

    describe "expires_latency" do
      let(:expires_at) { 1_530_000_000 }
      let(:expires_in) { 100 }
      let(:expires_latency) { 10 }
      let(:hash) do
        {
          access_token: token,
          expires_latency: expires_latency,
          expires_in: expires_in,
        }
      end

      it "sets it via options" do
        target = described_class.from_hash(client, hash.merge(expires_latency: expires_latency.to_s))
        expect(target.expires_latency).to eq expires_latency
      end

      it "sets it nil by default" do
        hash.delete(:expires_latency)
        target = described_class.from_hash(client, hash)
        expect(target.expires_latency).to be_nil
      end

      it "reduces expires_at by the given amount" do
        allow(Time).to receive(:now).and_return(expires_at)
        target = described_class.from_hash(client, hash)
        expect(target.expires_at).to eq(expires_at + expires_in - expires_latency)
      end

      it "reduces expires_at by the given amount if expires_at is provided as option" do
        target = described_class.from_hash(client, hash.merge(expires_at: expires_at))
        expect(target.expires_at).to eq(expires_at - expires_latency)
      end
    end
  end

  describe "#request" do
    context "with :mode => :header" do
      before do
        subject.options[:mode] = :header
      end

      VERBS.each do |verb|
        it "sends the token in the Authorization header for a #{verb.to_s.upcase} request" do
          expect(subject.post("/token/header").body).to include(token)
        end
      end
    end

    context "with :mode => :query" do
      before do
        subject.options[:mode] = :query
      end

      VERBS.each do |verb|
        it "sends the token in the body for a #{verb.to_s.upcase} request" do
          expect(subject.post("/token/query").body).to eq(token)
        end

        it "sends a #{verb.to_s.upcase} request and options[:param_name] include [number]." do
          subject.options[:param_name] = "auth[1]"
          expect(subject.__send__(verb, "/token/query_string").body).to include("auth[1]=#{token}")
        end
      end
    end

    context "with :mode => :body" do
      before do
        subject.options[:mode] = :body
      end

      VERBS.each do |verb|
        it "sends the token in the body for a #{verb.to_s.upcase} request" do
          expect(subject.post("/token/body").body.split("=").last).to eq(token)
        end

        context "when options[:param_name] include [number]" do
          it "sends a #{verb.to_s.upcase} request when body is a hash" do
            subject.options[:param_name] = "auth[1]"
            expect(subject.__send__(verb, "/token/body", body: {hi: "there"}).body).to include("auth%5B1%5D=#{token}")
          end

          it "sends a #{verb.to_s.upcase} request when body is overridden as string" do
            subject.options[:param_name] = "snoo[1]"
            expect(subject.__send__(verb, "/token/body", body: "hi_there").body).to include("hi_there&snoo[1]=#{token}")
          end
        end
      end
    end

    context "params include [number]" do
      VERBS.each do |verb|
        it "sends #{verb.to_s.upcase} correct query" do
          expect(subject.__send__(verb, "/token/query_string", params: {"foo[bar][1]" => "val"}).body).to include("foo[bar][1]=val")
        end
      end
    end
  end

  describe "#expires?" do
    it "is false if there is no expires_at" do
      expect(described_class.new(client, token)).not_to be_expires
    end

    it "is true if there is an expires_in" do
      expect(described_class.new(client, token, refresh_token: "abaca", expires_in: 600)).to be_expires
    end

    it "is true if there is an expires_at" do
      expect(described_class.new(client, token, refresh_token: "abaca", expires_in: Time.now.getutc.to_i + 600)).to be_expires
    end
  end

  describe "#expired?" do
    it "is false if there is no expires_in or expires_at" do
      expect(described_class.new(client, token)).not_to be_expired
    end

    it "is false if expires_in is 0 (token is permanent)" do
      expect(described_class.new(client, token, refresh_token: "abaca", expires_in: 0)).not_to be_expired
    end

    it "is false if expires_in is in the future" do
      expect(described_class.new(client, token, refresh_token: "abaca", expires_in: 10_800)).not_to be_expired
    end

    it "is true if expires_at is in the past" do
      access = described_class.new(client, token, refresh_token: "abaca", expires_in: 600)
      @now = Time.now + 10_800
      allow(Time).to receive(:now).and_return(@now)
      expect(access).to be_expired
    end

    it "is true if expires_at is now" do
      @now = Time.now
      access = described_class.new(client, token, refresh_token: "abaca", expires_at: @now.to_i)
      allow(Time).to receive(:now).and_return(@now)
      expect(access).to be_expired
    end
  end

  describe "#refresh" do
    let(:options) { {access_token_class: access_token_class} }
    let(:access_token_class) { NewAccessToken }
    let(:access) do
      described_class.new(
        client,
        token,
        refresh_token: "abaca",
        expires_in: 600,
        param_name: "o_param",
        access_token_class: access_token_class,
      )
    end
    let(:new_access) do
      NewAccessToken.new(client, token, refresh_token: "abaca")
    end

    before do
      custom_class = Class.new(described_class) do
        def self.from_hash(client, hash)
          new(client, hash.delete("access_token"), hash)
        end

        def self.contains_token?(hash)
          hash.key?("refresh_token")
        end
      end

      stub_const("NewAccessToken", custom_class)
    end

    context "without refresh_token" do
      subject(:no_refresh) { no_access.refresh }

      let(:no_access) do
        described_class.new(
          client,
          token,
          refresh_token: nil,
          expires_in: 600,
          param_name: "o_param",
          access_token_class: access_token_class,
        )
      end

      it "raises when no refresh_token" do
        block_is_expected.to raise_error(OAuth2::Error, {error: "A refresh_token is not available"}.to_s)
      end
    end

    it "returns a refresh token with appropriate values carried over" do
      refreshed = access.refresh
      expect(access.client).to eq(refreshed.client)
      expect(access.options[:param_name]).to eq(refreshed.options[:param_name])
    end

    it "returns a refresh token of the same access token class" do
      refreshed = new_access.refresh!
      expect(new_access.class).to eq(refreshed.class)
    end

    context "with a nil refresh_token in the response" do
      let(:refresh_body) { JSON.dump(access_token: "refreshed_foo", expires_in: 600, refresh_token: nil) }

      it "copies the refresh_token from the original token" do
        refreshed = access.refresh

        expect(refreshed.refresh_token).to eq(access.refresh_token)
      end
    end

    context "with a not-nil refresh_token in the response" do
      let(:refresh_body) { JSON.dump(access_token: "refreshed_foo", expires_in: 600, refresh_token: "qerwer") }

      it "copies the refresh_token from the original token" do
        refreshed = access.refresh

        expect(refreshed.token).to eq("refreshed_foo")
        expect(refreshed.refresh_token).to eq("qerwer")
      end
    end

    context "with a not-nil, not camel case, refresh_token in the response" do
      let(:refresh_body) { JSON.dump(accessToken: "refreshed_foo", expires_in: 600, refreshToken: "qerwer") }

      it "copies the refresh_token from the original token" do
        refreshed = access.refresh

        expect(refreshed.token).to eq("refreshed_foo")
        expect(refreshed.refresh_token).to eq("qerwer")
      end
    end

    context "with a custom access_token_class" do
      let(:access_token_class) { NewAccessToken }

      it "returns a refresh token of NewAccessToken" do
        refreshed = access.refresh!

        expect(new_access.class).to eq(refreshed.class)
      end
    end
  end

  describe "#revoke" do
    let(:token) { "monkey123" }
    let(:refresh_token) { "refreshmonkey123" }
    let(:access_token) { described_class.new(client, token, refresh_token: refresh_token) }

    context "with no token_type_hint specified" do
      it "revokes the access token by default" do
        expect(access_token.revoke.status).to eq(200)
      end
    end

    context "with access_token token_type_hint" do
      it "revokes the access token" do
        expect {
          access_token.revoke(token_type_hint: "access_token")
        }.not_to raise_error
      end
    end

    context "with refresh_token token_type_hint" do
      it "revokes the refresh token" do
        expect {
          access_token.revoke(token_type_hint: "refresh_token")
        }.not_to raise_error
      end
    end

    context "with invalid token_type_hint" do
      it "raises an OAuth2::Error" do
        expect {
          access_token.revoke(token_type_hint: "invalid_type")
        }.to raise_error(OAuth2::Error, /token_type_hint must be one of/)
      end
    end

    context "when refresh_token is specified but not available" do
      let(:access_token) { described_class.new(client, "abc", refresh_token: nil) }

      it "raises an OAuth2::Error" do
        expect {
          access_token.revoke(token_type_hint: "refresh_token")
        }.to raise_error(OAuth2::Error, /refresh_token is not available for revoking/)
      end
    end

    context "when refresh_token is, but access_token is not, available" do
      let(:access_token) { described_class.new(client, "abc", refresh_token: refresh_token) }

      before do
        allow(client).to receive(:revoke_token).
          with(refresh_token, "refresh_token", {}).
          and_return(OAuth2::Response.new(double(status: 200)))
        # The code path being tested shouldn't be reachable... so this is hacky.
        # Testing it for anal level compliance. Revoking a refresh token without an access token is valid.
        # In other words, the implementation of AccessToken doesn't allow instantiation without an access token.
        # But in a revocation scenario it should theoretically work.
        # It is intended that AccessToken be subclassed, so this is worth testing, as subclasses may change behavior.
        allow(access_token).to receive(:token).and_return(nil)
      end

      it "revokes refresh_token" do
        expect {
          access_token.revoke
        }.not_to raise_error
      end
    end

    context "when no tokens are available" do
      let(:access_token) { described_class.new(client, "abc", refresh_token: nil) }

      before do
        # The code path being tested shouldn't be reachable... so this is hacky.
        # Testing it for anal level compliance. Revoking a refresh token without an access token is valid.
        # In other words, the implementation of AccessToken doesn't allow instantiation without an access token.
        # But in a revocation scenario it should theoretically work.
        # It is intended that AccessToken be subclassed, so this is worth testing, as subclasses may change behavior.
        allow(access_token).to receive(:token).and_return(nil)
      end

      it "raises an OAuth2::Error" do
        expect {
          access_token.revoke
        }.to raise_error(OAuth2::Error, /unknown token type is not available for revoking/)
      end
    end

    context "with additional params" do
      before do
        allow(client).to receive(:revoke_token).
          with(token, "access_token", {extra: "param"}).
          and_return(OAuth2::Response.new(double(status: 200)))
      end

      it "passes them to the client" do
        expect {
          access_token.revoke({extra: "param"})
        }.not_to raise_error
      end
    end

    context "with a block" do
      it "passes the block to the client" do
        expect {
          access_token.revoke do |_req|
            puts "Hello from the other side"
          end
        }.not_to raise_error
      end

      it "has status 200" do
        expect(
          access_token.revoke do |_req|
            puts "Hello again"
          end.status,
        ).to eq(200)
      end

      it "executes the block" do
        @apple = 0
        access_token.revoke do |_req|
          @apple += 1
        end
        expect(@apple).to eq(1)
      end
    end
  end

  describe "#to_hash" do
    it "return a hash equal to the hash used to initialize access token" do
      hash = {
        access_token: token,
        refresh_token: "foobar",
        expires_at: Time.now.to_i + 200,
        header_format: "Bearer %",
        mode: :header,
        param_name: "access_token",
        foo: "bar",
      }
      access_token = described_class.from_hash(client, hash.clone)
      expect(access_token.to_hash).to eq(hash)
    end

    context "with token_name" do
      it "return a hash equal to the hash used to initialize access token" do
        hash = {
          access_token: "",
          refresh_token: "foobar",
          expires_at: Time.now.to_i + 200,
          header_format: "Bearer %",
          mode: :header,
          param_name: "access_token",
          token_name: "banana_face",
          foo: "bar",
        }
        access_token = described_class.from_hash(client, hash.clone)
        expect(access_token.to_hash).to eq(hash)
      end
    end
  end

  describe "#inspect" do
    let(:inspect_result) { described_class.new(nil, "secret-token", {refresh_token: "secret-refresh-token"}).inspect }

    it "filters out the @token value" do
      expect(inspect_result).to include("@token=[FILTERED]")
    end

    it "filters out the @refresh_token value" do
      expect(inspect_result).to include("@refresh_token=[FILTERED]")
    end
  end
end
