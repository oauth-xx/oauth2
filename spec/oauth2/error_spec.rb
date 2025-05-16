# encoding: utf-8
# frozen_string_literal: true

class StirredHash < Hash
  def to_str
    '{"hello":"� Cool � StirredHash"}'
  end
end

class XmledString < String
  XML = '
<things>
<thing id="101">
<name>� Cool � XmledString</name>
</thing>
</things>
'
  def to_str
    XML
  end
end

RSpec.describe OAuth2::Error do
  subject { described_class.new(response) }

  let(:response) do
    raw_response = Faraday::Response.new(
      status: 418,
      response_headers: response_headers,
      body: response_body,
    )

    OAuth2::Response.new(raw_response)
  end

  let(:response_headers) { {"Content-Type" => "application/json"} }
  let(:response_body) { {text: "Coffee brewing failed"}.to_json }

  it "sets the response object to #response on self" do
    error = described_class.new(response)
    expect(error.response).to equal(response)
  end

  describe "attr_readers" do
    it "has code" do
      expect(subject).to respond_to(:code)
    end

    it "has description" do
      expect(subject).to respond_to(:description)
    end

    it "has response" do
      expect(subject).to respond_to(:response)
    end
  end

  context "when the response is parsed" do
    let(:response_body) { response_hash.to_json }
    let(:response_hash) { {text: "Coffee brewing failed"} }

    context "when the response has an error and error_description" do
      before do
        response_hash["error_description"] = "Short and stout"
        response_hash["error"] = "i_am_a_teapot"
      end

      it "sets the code attribute" do
        expect(subject.code).to eq("i_am_a_teapot")
      end

      it "sets the description attribute" do
        expect(subject.description).to eq("Short and stout")
      end

      it "prepends to the error message with a return character" do
        expect(subject.message.each_line.to_a).to eq(
          [
            "i_am_a_teapot: Short and stout\n",
            '{"text":"Coffee brewing failed","error_description":"Short and stout","error":"i_am_a_teapot"}',
          ],
        )
      end

      context "when the response needs to be encoded" do
        let(:response_body) { JSON.dump(response_hash).force_encoding("ASCII-8BIT") }

        context "with invalid characters present" do
          before do
            response_body.gsub!("stout", "\255 invalid \255")
          end

          it "replaces them" do
            # See https://bibwild.wordpress.com/2013/03/12/removing-illegal-bytes-for-encoding-in-ruby-1-9-strings/
            raise "Invalid characters not replaced" unless subject.message.include?("� invalid �")
            # This will fail if {:invalid => replace} is not passed into `encode`
          end
        end

        context "with undefined characters present" do
          before do
            response_hash["error_description"] += ": 'A magical voyage of tea 🍵'"
          end

          it "replaces them" do
            raise "Undefined characters not replaced" unless subject.message.include?("tea �")
            # This will fail if {:undef => replace} is not passed into `encode`
          end
        end
      end

      context "when the response is not an encodable thing" do
        let(:response_headers) { {"Content-Type" => "who knows"} }
        let(:response_body) { {text: "Coffee brewing failed"} }

        before do
          expect(response_body).not_to respond_to(:encode)
          # i.e. a Ruby hash
        end

        it "does not try to encode the message string" do
          expect(subject.message).to eq(response_body.to_s)
        end
      end

      context "when using :json parser with non-encodable data" do
        let(:response_headers) { {"Content-Type" => "application/hal+json"} }
        let(:response_body) do
          StirredHash[
            "_links": {
              "self": {"href": "/orders/523"},
              "warehouse": {"href": "/warehouse/56"},
              "invoice": {"href": "/invoices/873"},
            },
            "currency": "USD",
            "status": "shipped",
            "total": 10.20,
          ]
        end

        before do
          expect(response_body).not_to respond_to(:force_encoding)
          expect(response_body).to respond_to(:to_str)
        end

        it "does not force encode the message" do
          expect(subject.message).to eq('{"hello":"� Cool � StirredHash"}')
        end
      end

      context "when using :xml parser" do
        let(:response_headers) { {"Content-Type" => "text/xml"} }
        let(:response_body) do
          XmledString.new(XmledString::XML)
        end

        before do
          expect(response_body).to respond_to(:to_str)
        end

        it "parses the XML" do
          expect(subject.message).to eq(XmledString::XML)
        end
      end

      context "when using :xml parser with non-String-like thing" do
        let(:response_headers) { {"Content-Type" => "text/xml"} }
        let(:response_body) { {hello: :world} }

        before do
          expect(response_body).not_to respond_to(:to_str)
        end

        it "just returns the thing if it can" do
          expect(subject.message).to eq({hello: :world}.to_s)
        end
      end
    end

    it "sets the code attribute to nil" do
      expect(subject.code).to be_nil
    end

    it "sets the description attribute" do
      expect(subject.description).to be_nil
    end

    context "when there is no error description" do
      before do
        expect(response_hash).not_to have_key("error")
        expect(response_hash).not_to have_key("error_description")
      end

      it "does not prepend anything to the message" do
        expect(subject.message.lines.count).to eq(1)
        expect(subject.message).to eq '{"text":"Coffee brewing failed"}'
      end

      it "does not set code" do
        expect(subject.code).to be_nil
      end

      it "does not set description" do
        expect(subject.description).to be_nil
      end
    end

    context "when there is code (error)" do
      before do
        response_hash["error_description"] = "Short and stout"
        response_hash["error"] = "i_am_a_teapot"
        response_hash["status"] = "418"
      end

      it "prepends to the error message with a return character" do
        expect(subject.message.each_line.to_a).to eq(
          [
            "i_am_a_teapot: Short and stout\n",
            {
              "text": "Coffee brewing failed",
              "error_description": "Short and stout",
              "error": "i_am_a_teapot",
              "status": "418",
            }.to_json,
          ],
        )
      end

      context "when the response needs to be encoded" do
        let(:response_body) { JSON.dump(response_hash).force_encoding("ASCII-8BIT") }

        context "with invalid characters present" do
          before do
            response_body.gsub!("stout", "\255 invalid \255")
          end

          it "replaces them" do
            # The skip can be removed once support for < 2.1 is dropped.
            encoding = {reason: "encode/scrub only works as of Ruby 2.1"}
            skip_for(encoding.merge(engine: "jruby"))
            # See https://bibwild.wordpress.com/2013/03/12/removing-illegal-bytes-for-encoding-in-ruby-1-9-strings/

            raise "Invalid characters not replaced" unless subject.message.include?("� invalid �")
            # This will fail if {:invalid => replace} is not passed into `encode`
          end
        end

        context "with undefined characters present" do
          before do
            response_hash["error_description"] += ": 'A magical voyage of tea 🍵'"
          end

          it "replaces them" do
            raise "Undefined characters not replaced" unless subject.message.include?("tea �")
            # This will fail if {:undef => replace} is not passed into `encode`
          end
        end
      end

      context "when the response is not an encodable thing" do
        let(:response_headers) { {"Content-Type" => "who knows"} }
        let(:response_body) { {text: "Coffee brewing failed"} }

        before do
          expect(response_body).not_to respond_to(:encode)
          # i.e. a Ruby hash
        end

        it "does not try to encode the message string" do
          expect(subject.message).to eq(response_body.to_s)
        end
      end

      it "sets the code attribute" do
        expect(subject.code).to eq("i_am_a_teapot")
      end

      it "sets the description attribute" do
        expect(subject.description).to eq("Short and stout")
      end
    end

    context "when there is code (error) but no error_description" do
      before do
        response_hash.delete("error_description")
        response_hash["error"] = "i_am_a_teapot"
        response_hash["status"] = "418"
      end

      it "prepends to the error message with a return character" do
        expect(subject.message.each_line.to_a).to eq(
          [
            "i_am_a_teapot: \n",
            {
              "text": "Coffee brewing failed",
              "error": "i_am_a_teapot",
              "status": "418",
            }.to_json,
          ],
        )
      end

      context "when the response needs to be encoded" do
        let(:response_body) { JSON.dump(response_hash).force_encoding("ASCII-8BIT") }

        context "with invalid characters present" do
          before do
            response_body.gsub!("brewing", "\255 invalid \255")
          end

          it "replaces them" do
            # The skip can be removed once support for < 2.1 is dropped.
            encoding = {reason: "encode/scrub only works as of Ruby 2.1"}
            skip_for(encoding.merge(engine: "jruby"))
            # See https://bibwild.wordpress.com/2013/03/12/removing-illegal-bytes-for-encoding-in-ruby-1-9-strings/

            raise "Invalid characters not replaced" unless subject.message.include?("� invalid �")
            # This will fail if {:invalid => replace} is not passed into `encode`
          end
        end
      end

      context "when the response is not an encodable thing" do
        let(:response_headers) { {"Content-Type" => "who knows"} }
        let(:response_body) { {text: "Coffee brewing failed"} }

        before do
          expect(response_body).not_to respond_to(:encode)
          # i.e. a Ruby hash
        end

        it "does not try to encode the message string" do
          expect(subject.message).to eq(response_body.to_s)
        end
      end

      it "sets the code attribute from error" do
        expect(subject.code).to eq("i_am_a_teapot")
      end

      it "does not set the description attribute" do
        expect(subject.description).to be_nil
      end
    end

    context "when there is error_description but no code (error)" do
      before do
        response_hash["error_description"] = "Short and stout"
        response_hash.delete("error")
      end

      it "prepends to the error message with a return character" do
        expect(subject.message.each_line.to_a).to eq(
          [
            "Short and stout\n",
            {
              "text": "Coffee brewing failed",
              "error_description": "Short and stout",
            }.to_json,
          ],
        )
      end

      context "when the response needs to be encoded" do
        let(:response_body) { JSON.dump(response_hash).force_encoding("ASCII-8BIT") }

        context "with invalid characters present" do
          before do
            response_body.gsub!("stout", "\255 invalid \255")
          end

          it "replaces them" do
            # The skip can be removed once support for < 2.1 is dropped.
            encoding = {reason: "encode/scrub only works as of Ruby 2.1"}
            skip_for(encoding.merge(engine: "jruby"))
            # See https://bibwild.wordpress.com/2013/03/12/removing-illegal-bytes-for-encoding-in-ruby-1-9-strings/

            raise "Invalid characters not replaced" unless subject.message.include?("� invalid �")
            # This will fail if {:invalid => replace} is not passed into `encode`
          end
        end

        context "with undefined characters present" do
          before do
            response_hash["error_description"] += ": 'A magical voyage of tea 🍵'"
          end

          it "replaces them" do
            raise "Undefined characters not replaced" unless subject.message.include?("tea �")
            # This will fail if {:undef => replace} is not passed into `encode`
          end
        end
      end

      context "when the response is not an encodable thing" do
        let(:response_headers) { {"Content-Type" => "who knows"} }
        let(:response_body) { {text: "Coffee brewing failed"} }

        before do
          expect(response_body).not_to respond_to(:encode)
          # i.e. a Ruby hash
        end

        it "does not try to encode the message string" do
          expect(subject.message).to eq(response_body.to_s)
        end
      end

      it "sets the code attribute" do
        expect(subject.code).to be_nil
      end

      it "sets the description attribute" do
        expect(subject.description).to eq("Short and stout")
      end
    end
  end

  context "when the response is simple hash, not parsed" do
    subject { described_class.new(response_hash) }

    let(:response_hash) { {text: "Coffee brewing failed"} }

    it "sets the code attribute to nil" do
      expect(subject.code).to be_nil
    end

    it "sets the description attribute" do
      expect(subject.description).to be_nil
    end

    context "when the response has an error and error_description" do
      before do
        response_hash["error_description"] = "Short and stout"
        response_hash["error"] = "i_am_a_teapot"
      end

      it "sets the code attribute" do
        expect(subject.code).to eq("i_am_a_teapot")
      end

      it "sets the description attribute" do
        expect(subject.description).to eq("Short and stout")
      end

      it "prepends to the error message with a return character" do
        expect(subject.message.each_line.to_a).to eq(
          [
            "i_am_a_teapot: Short and stout\n",
            {:text => "Coffee brewing failed", "error_description" => "Short and stout", "error" => "i_am_a_teapot"}.to_s,
          ],
        )
      end

      context "when using :xml parser with non-String-like thing" do
        let(:response_headers) { {"Content-Type" => "text/xml"} }
        let(:response_hash) { {hello: :world} }

        before do
          expect(response_hash).not_to respond_to(:to_str)
        end

        it "just returns whatever it can" do
          expect(subject.message.each_line.to_a).to eq(
            [
              "i_am_a_teapot: Short and stout\n",
              {:hello => :world, "error_description" => "Short and stout", "error" => "i_am_a_teapot"}.to_s,
            ],
          )
        end
      end
    end

    context "when using :xml parser with non-String-like thing" do
      let(:response_headers) { {"Content-Type" => "text/xml"} }
      let(:response_hash) { {hello: :world} }

      before do
        expect(response_hash).not_to respond_to(:to_str)
      end

      it "just returns the thing if it can" do
        expect(subject.message).to eq({hello: :world}.to_s)
      end
    end

    context "when there is no error description" do
      before do
        expect(response_hash).not_to have_key("error")
        expect(response_hash).not_to have_key("error_description")
      end

      it "does not prepend anything to the message" do
        expect(subject.message.lines.count).to eq(1)
        expect(subject.message).to eq({text: "Coffee brewing failed"}.to_s)
      end

      it "does not set code" do
        expect(subject.code).to be_nil
      end

      it "does not set description" do
        expect(subject.description).to be_nil
      end
    end

    context "when there is code (error)" do
      before do
        response_hash["error_description"] = "Short and stout"
        response_hash["error"] = "i_am_a_teapot"
        response_hash["status"] = "418"
      end

      it "prepends to the error message with a return character" do
        expect(subject.message.each_line.to_a).to eq(
          [
            "i_am_a_teapot: Short and stout\n",
            {:text => "Coffee brewing failed", "error_description" => "Short and stout", "error" => "i_am_a_teapot", "status" => "418"}.to_s,
          ],
        )
      end

      it "sets the code attribute" do
        expect(subject.code).to eq("i_am_a_teapot")
      end

      it "sets the description attribute" do
        expect(subject.description).to eq("Short and stout")
      end
    end

    context "when there is code (error) but no error_description" do
      before do
        response_hash.delete("error_description")
        response_hash["error"] = "i_am_a_teapot"
        response_hash["status"] = "418"
      end

      it "sets the code attribute from error" do
        expect(subject.code).to eq("i_am_a_teapot")
      end

      it "does not set the description attribute" do
        expect(subject.description).to be_nil
      end

      it "prepends to the error message with a return character" do
        expect(subject.message.each_line.to_a).to eq(
          [
            "i_am_a_teapot: \n",
            {:text => "Coffee brewing failed", "error" => "i_am_a_teapot", "status" => "418"}.to_s,
          ],
        )
      end
    end

    context "when there is error_description but no code (error)" do
      before do
        response_hash["error_description"] = "Short and stout"
        response_hash.delete("error")
      end

      it "prepends to the error message with a return character" do
        expect(subject.message.each_line.to_a).to eq(
          [
            "Short and stout\n",
            {:text => "Coffee brewing failed", "error_description" => "Short and stout"}.to_s,
          ],
        )
      end

      context "when the response is not an encodable thing" do
        let(:response_headers) { {"Content-Type" => "who knows"} }
        let(:response_hash) { {text: "Coffee brewing failed"} }

        before do
          expect(response_hash).not_to respond_to(:encode)
          # i.e. a Ruby hash
        end

        it "does not try to encode the message string" do
          expect(subject.message.each_line.to_a).to eq(
            [
              "Short and stout\n",
              {:text => "Coffee brewing failed", "error_description" => "Short and stout"}.to_s,
            ],
          )
        end
      end

      it "sets the code attribute" do
        expect(subject.code).to be_nil
      end

      it "sets the description attribute" do
        expect(subject.description).to eq("Short and stout")
      end
    end
  end

  context "when the response is not a hash, not parsed" do
    subject { described_class.new(response_thing) }

    let(:response_thing) { [200, "Success"] }

    it "sets the code attribute to nil" do
      expect(subject.code).to be_nil
    end

    it "sets the description attribute" do
      expect(subject.description).to be_nil
    end

    it "sets the body attribute" do
      expect(subject.body).to eq(response_thing)
    end

    it "sets the response attribute" do
      expect(subject.response).to eq(response_thing)
    end
  end

  context "when the response does not parse to a hash" do
    let(:response_headers) { {"Content-Type" => "text/html"} }
    let(:response_body) { "<!DOCTYPE html><html><head>Hello, I am a teapot</head><body></body></html>" }

    before do
      expect(response.parsed).not_to be_a(Hash)
    end

    it "does not do anything to the message" do
      expect(subject.message.lines.count).to eq(1)
      expect(subject.message).to eq(response_body)
    end

    it "does not set code" do
      expect(subject.code).to be_nil
    end

    it "does not set description" do
      expect(subject.description).to be_nil
    end
  end

  describe "parsing json" do
    it "does not blow up" do
      expect { subject.to_json }.not_to raise_error
      expect { subject.response.to_json }.not_to raise_error
    end
  end
end
