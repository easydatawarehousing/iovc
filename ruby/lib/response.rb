# frozen_string_literal: true

# Parse response from openai gem
# Extract json if present
class Response

  attr_reader :id, :created_at, :llm_model_name, :prompt_tokens, :completion_tokens, :total_tokens, :message, :json

  def initialize(response_data)
    @prompt_tokens = @completion_tokens = @total_tokens = 0
    parse_openai_api_response(response_data)
  end

  def inspect
    [
      "Response:     #{@id}",
      "  created_at: #{@created_at ? Time.at(@created_at) : nil}",
      "  model_name: #{@llm_model_name}",
      "  tokens:     prompt: #{@prompt_tokens.to_i} + completion: #{@completion_tokens.to_i} = #{@total_tokens.to_i}}",
      "  #{@message.to_s.gsub("\n", '\n ')}",
    ].compact.join("\n")
  end

  private

  def parse_openai_api_response(response_data)
    raise response_data['error'].to_s if response_data.key?('error')

    @id                = response_data.dig('id')
    @created_at        = response_data.dig('created')
    @llm_model_name    = response_data.dig('model')
    @prompt_tokens     = response_data.dig('usage', 'prompt_tokens')
    @completion_tokens = response_data.dig('usage', 'completion_tokens')
    @total_tokens      = response_data.dig('usage', 'total_tokens')
    @message           = response_data.dig('choices', 0, 'message', 'content').to_s.strip

    parse_json
  end

  def parse_json
    @json = JSON.parse(@message)
  rescue => e
    puts "Error parsing JSON response!", e.message
    @json = nil
  end
end
