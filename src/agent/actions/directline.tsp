import "@typespec/http";
import "@microsoft/typespec-m365-copilot";
import "../env.tsp";

using TypeSpec.Http;
using TypeSpec.M365.Copilot.Actions;

@service
@server("https://directline.botframework.com", "Bot Framework Direct Line API")
@actions(#{
  nameForHuman: "Copilot Studio AI Assistant",
  descriptionForHuman: "Chat with the Generative AI Query Assistant powered by Copilot Studio via Direct Line.",
  descriptionForModel: "Use this action to send queries to the Copilot Studio Generative AI Query Assistant via Direct Line. Call startConversation first to get a conversationId, then call sendQuery with the conversationId and the user's question, then call getResponse with the conversationId to retrieve the bot's reply."
})
@useAuth(BearerAuth)
namespace CopilotStudioAPI {
  /** Start a new Direct Line conversation. Returns a conversationId and token for subsequent calls. */
  @route("/v3/directline/conversations")
  @post
  op startConversation(): ConversationResponse;

  /** Send a user message to an active Direct Line conversation. */
  @route("/v3/directline/conversations/{conversationId}/activities")
  @post
  op sendQuery(
    @path conversationId: string,
    @body activity: ActivityRequest
  ): SendActivityResponse;

  /** Retrieve activities (including bot responses) from a Direct Line conversation. Use the watermark to get only new activities. */
  @route("/v3/directline/conversations/{conversationId}/activities")
  @get
  op getResponse(
    @path conversationId: string,
    @query watermark?: string
  ): ActivitySet;

  model ConversationResponse {
    conversationId: string;
    token: string;
    expires_in: int32;
    streamUrl?: string;
  }

  model ActivityRequest {
    type: "message";
    from: ActivityFrom;
    text: string;
  }

  model ActivityFrom {
    id: string;
    name?: string;
  }

  model SendActivityResponse {
    id: string;
  }

  model ActivitySet {
    activities: Activity[];
    watermark: string;
  }

  model Activity {
    type: string;
    id?: string;
    timestamp?: string;
    from?: ActivityFrom;
    text?: string;
    replyToId?: string;
    attachments?: Attachment[];
  }

  model Attachment {
    contentType: string;
    content?: string;
  }
}