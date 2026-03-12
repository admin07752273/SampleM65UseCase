import "@typespec/http";
import "@microsoft/typespec-m365-copilot";
import "../env.tsp";

using TypeSpec.Http;
using TypeSpec.M365.Copilot.Actions;

@service
@server(AzureOpenAIAPI.SERVER_URL, "Azure OpenAI Service hosted in Azure AI Foundry")
@actions(#{
  nameForHuman: "Azure OpenAI",
  descriptionForHuman: "Chat with your Azure AI Foundry model for intelligent responses, reasoning, and content generation.",
  descriptionForModel: "Use this action to send a chat completion request to the Azure OpenAI model hosted in Azure AI Foundry. Call chatCompletion with the user's prompt text. The model will return generated text responses.",
})
@useAuth(ApiKeyAuth<ApiKeyLocation.header, "api-key">)
namespace AzureOpenAIAPI {

  const SERVER_URL = Environment.AZURE_OPENAI_ENDPOINT;

  /**
   * Send a chat completion request to the Azure OpenAI model.
   * @param deployment The model deployment name.
   * @param api_version The API version to use.
   */
  @route("/openai/deployments/{deployment}/chat/completions")
  @post
  op chatCompletion(
    @path deployment: string = Environment.AZURE_OPENAI_DEPLOYMENT,
    @query(#{ name: "api-version" }) api_version: string = Environment.AZURE_OPENAI_API_VERSION,
    @body body: ChatCompletionRequest,
  ): ChatCompletionResponse | ErrorResponse;

  // --- Request Models ---

  model ChatCompletionRequest {
    @doc("The list of messages in the conversation.")
    messages: ChatMessage[];

    @doc("Sampling temperature between 0 and 2. Lower values are more focused, higher values more creative.")
    temperature?: float64;

    @doc("Maximum number of tokens to generate in the response.")
    max_tokens?: int32;
  }

  model ChatMessage {
    @doc("The role of the message author: system, user, or assistant.")
    role: "system" | "user" | "assistant";

    @doc("The content of the message.")
    content: string;
  }

  // --- Response Models ---

  model ChatCompletionResponse {
    @doc("Unique identifier for the completion.")
    id: string;

    @doc("The list of completion choices.")
    choices: ChatChoice[];
  }

  model ChatChoice {
    @doc("Index of the choice.")
    index: int32;

    @doc("The generated message.")
    message: ChatResponseMessage;

    @doc("The reason the model stopped generating (e.g., stop, length).")
    finish_reason: string;
  }

  model ChatResponseMessage {
    @doc("The role of the response message author.")
    role: string;

    @doc("The generated content.")
    content: string;
  }

  // --- Error Model ---

  model ErrorResponse {
    @statusCode statusCode: 400 | 401 | 403 | 404 | 429 | 500;
    error: ErrorDetail;
  }

  model ErrorDetail {
    @doc("Error code.")
    code: string;

    @doc("Human-readable error message.")
    message: string;
  }
}
