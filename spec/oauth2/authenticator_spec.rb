# frozen_string_literal: true

RSpec.describe OAuth2::Authenticator do
  subject do
    described_class.new(client_id, client_secret, mode)
  end

  let(:client_id) { "foo" }
  let(:client_secret) { "bar" }
  let(:mode) { :undefined }

  it "raises NotImplementedError for unknown authentication mode" do
    expect { subject.apply({}) }.to raise_error(NotImplementedError)
  end

  describe "#apply" do
    context "with parameter-based authentication" do
      let(:mode) { :request_body }

      it "adds client_id and client_secret to params" do
        output = subject.apply({})
        expect(output).to eq("client_id" => "foo", "client_secret" => "bar")
      end

      context "when client_id nil" do
        let(:client_id) { nil }

        it "ignores client_id, but adds client_secret to params" do
          output = subject.apply({})
          expect(output).to eq("client_secret" => "bar")
        end
      end

      it "does not overwrite existing credentials" do
        input = {"client_secret" => "s3cr3t"}
        output = subject.apply(input)
        expect(output).to eq("client_id" => "foo", "client_secret" => "s3cr3t")
      end

      it "preserves other parameters" do
        input = {"state" => "42", :headers => {"A" => "b"}}
        output = subject.apply(input)
        expect(output).to eq(
          "client_id" => "foo",
          "client_secret" => "bar",
          "state" => "42",
          :headers => {"A" => "b"},
        )
      end

      context "passing nil secret" do
        let(:client_secret) { nil }

        it "does not set nil client_secret" do
          output = subject.apply({})
          expect(output).to eq("client_id" => "foo")
        end
      end

      context "using tls client authentication" do
        let(:mode) { :tls_client_auth }

        it "does not add client_secret" do
          output = subject.apply({})
          expect(output).to eq("client_id" => "foo")
        end
      end

      context "using private key jwt authentication" do
        let(:mode) { :private_key_jwt }

        it "does not include client_id or client_secret" do
          output = subject.apply({})
          expect(output).to eq({})
        end
      end
    end

    context "using tls_client_auth" do
      let(:mode) { :tls_client_auth }

      context "when client_id present" do
        let(:client_id) { "foobar" }

        it "adds client_id to params" do
          output = subject.apply({})
          expect(output).to eq("client_id" => "foobar")
        end
      end

      context "when client_id nil" do
        let(:client_id) { nil }

        it "ignores client_id for params" do
          output = subject.apply({})
          expect(output).to eq({})
        end
      end
    end

    context "with Basic authentication" do
      let(:mode) { :basic_auth }
      let(:header) { "Basic #{Base64.strict_encode64("#{client_id}:#{client_secret}")}" }

      it "encodes credentials in headers" do
        output = subject.apply({})
        expect(output).to eq(headers: {"Authorization" => header})
      end

      it "does not overwrite existing credentials" do
        input = {headers: {"Authorization" => "Bearer abc123"}}
        output = subject.apply(input)
        expect(output).to eq(headers: {"Authorization" => "Bearer abc123"})
      end

      it "does not overwrite existing params or headers" do
        input = {"state" => "42", :headers => {"A" => "b"}}
        output = subject.apply(input)
        expect(output).to eq(
          "state" => "42",
          :headers => {"A" => "b", "Authorization" => header},
        )
      end
    end
  end

  describe "#inspect" do
    it "filters secret by default" do
      expect(described_class.filtered_attribute_names).to include(:secret)
    end

    it "filters out the @secret value" do
      expect(subject.inspect).to include("@secret=[FILTERED]")
    end

    context "when filter is changed" do
      before do
        @original_filter = described_class.filtered_attribute_names
        described_class.filtered_attributes :vanilla
      end

      after do
        described_class.filtered_attributes(*@original_filter)
      end

      it "changes the filter" do
        expect(described_class.filtered_attribute_names).to eq([:vanilla])
      end

      it "does not filter out the @secret value" do
        expect(subject.inspect).to include("@secret=\"bar\"")
      end
    end

    context "when filter is empty" do
      before do
        @original_filter = described_class.filtered_attribute_names
        described_class.filtered_attributes
      end

      after do
        described_class.filtered_attributes(*@original_filter)
      end

      it "changes the filter" do
        expect(described_class.filtered_attribute_names).to eq([])
      end

      it "does not filter out the @secret value" do
        expect(subject.inspect).to include("@secret=\"bar\"")
      end
    end
  end
end
