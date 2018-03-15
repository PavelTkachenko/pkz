# frozen_string_literal: true

module PKZ
  module Payment
    # This class provides ability to initiate payment. It will create
    # transaction on processing.kz server with PENDING_CUSTOMER_INPUT
    # status.
    class Start
      # Validation schema for parameters
      SCHEMA = Dry::Validation.Schema do
        required(:merchant_id).value(size?: 15)
        required(:currency_code).value(included_in?: [398, 643, 840])
      end

      def initialize(defaults: {}, xml_builder: Nokogiri::XML::Builder.new)
        @defaults = defaults
        @xml_builder = xml_builder
      end

      # Executes request to processing.kz server.
      #
      # @param [Hash] params the options to create a message with.
      # @option params [String] :merchant_id unique merchant id
      # @option params [Number] :currency_code ISO_4217 numeric code
      # @option params [String] :language_code *ru*, *en* or *kz*
      # @option params [String] :description order description
      # @return [Success, Failure]
      def call(params = {})
        request_params = @defaults.merge(params)
        validation_errors = validate(request_params).messages
        raise ArgumentError, validation_errors if validation_errors.any?
        request!(request_params)
      end

      private

      def validate(hash)
        SCHEMA.call(hash)
      end

      def request!(_params)
        xml = @xml_builder.new
        xml.instruct!(:xml, encoding: 'UTF-8')
        xml.x(:Envelope,
              'xmlns:x' => 'http://schemas.xmlsoap.org/soap/envelope/',
              'xmlns:ws' => 'http://score.ws.creditinfo.com/') do
          xml.x :Header do
            xml.ws :CigWsHeader do
              xml.ws :Culture,  @culture
              xml.ws :UserName, @user_name
              xml.ws :Password, @password
            end
          end
          xml.x :Body do
            xml.ws :Score do
              xml.ws :ScoreCard, 'BehaviorScoring'
              xml.ws :attributes do
                xml.ws :name, 'ConsentConfirmed'
                xml.ws :value, 1
              end
              xml.ws :attributes do
                xml.ws :name, 'IIN'
                xml.ws :value, iin
              end
            end
          end
        end
      end
    end
  end
end
