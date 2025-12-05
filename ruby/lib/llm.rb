# frozen_string_literal: true

require "openai"

class Llm

  include Utils

  LLM_TEMPERATURE  = 0.5

  LLM_MODEL_NAMES = {
    guide: "gpt-oss:20b",
    code:  "qwen3:14b", # Other good options: qwen2.5-coder:14b, qwen3-coder:30b
  }.freeze

  API_URL          = "http://localhost:11434"
  API_TIMEOUT      = 120 # A higher value may be needed when running Ollama without a GPU
  API_ACCESS_TOKEN = ""  # Use something like: ENV.fetch("IOVC_API_ACCESS_TOKEN", "")

  def ask(model, system_prompt, user_prompt)
    Response.new(chat(model, [system_message(system_prompt), user_message(user_prompt)]))
  end

  private

  def system_message(content) = { role: "system", content: content }
  def user_message(content)   = { role: "user",   content: content }

  def chat(model, messages)
    raise "No model for '#{model}'" if !LLM_MODEL_NAMES.key?(model)

    log(:request, model, messages.last[:content])

    response = client.chat(parameters: {
      temperature:     LLM_TEMPERATURE,
      model:           LLM_MODEL_NAMES[model],
      messages:        messages,
      response_format: { type: "json_object" }
    })

    log(:response, model, response.dig('choices', 0, 'message', 'content').to_s.strip)
    response
  end

  def client
    @client ||= OpenAI::Client.new(
      uri_base:        API_URL,
      request_timeout: API_TIMEOUT,
      access_token:    API_ACCESS_TOKEN,
      log_errors:      false)
  end
end
