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
  descriptionForModel: "Use this action to chat with the Copilot Studio agent via Direct Line. Flow: 1) generateToken to get a short-lived token, 2) startConversation to open a session, 3) sendMessage to post user text, 4) getActivities to poll for the bot reply."
})
@useAuth(ApiKeyAuth<ApiKeyLocation.header, "Authorization">)
namespace CopilotStudioAPI {

  // --- Step 1: Generate a short-lived token ---
  /** Exchange the Direct Line secret for a short-lived token. Use this token for subsequent API calls instead of exposing the secret. */
  @route("/v3/directline/tokens/generate")
  @post
  op generateToken(): TokenResponse | ErrorResponse;

  // --- Step 2: Start a conversation ---
  /** Start a new Direct Line conversation using the Direct Line secret or token. Returns a conversationId, token, and streamUrl. */
  @route("/v3/directline/conversations")
  @post
  op startConversation(): ConversationResponse | ErrorResponse;

  // --- Step 3: Send a message to the bot ---
  /** Send a user message into the conversation. */
  @route("/v3/directline/conversations/{conversationId}/activities")
  @post
  op sendMessage(
    @path conversationId: string,
    @body activity: ActivityRequest
  ): SendActivityResponse | ErrorResponse;

  // --- Step 4: Get activities (bot replies) ---
  /** Retrieve all activities in the conversation. Pass watermark to get only new activities since the last poll. */
  @route("/v3/directline/conversations/{conversationId}/activities")
  @get
  op getActivities(
    @path conversationId: string,
    @query watermark?: string
  ): ActivitySet | ErrorResponse;

  // --- Request Models ---

  model ActivityRequest {
    type: "message";
    from: ActivityFrom;
    text: string;
    locale?: string;
  }

  model ActivityFrom {
    /** User or bot ID. For users, must start with "dl_". */
    id: string;
    name?: string;
    role?: string;
  }

  // --- Response Models ---

  model TokenResponse {
    conversationId: string;
    token: string;
    expires_in: int32;
  }

  model ConversationResponse {
    conversationId: string;
    token: string;
    expires_in: int32;
    streamUrl?: string;
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
    channelId?: string;
    from?: ActivityFrom;
    conversation?: ConversationRef;
    text?: string;
    locale?: string;
    inputHint?: string;
    replyToId?: string;
    serviceUrl?: string;
    attachments?: Attachment[];
  }

  model ConversationRef {
    id: string;
  }

  model Attachment {
    contentType: string;
    content?: string;
  }

  // --- Error Model ---

  model ErrorResponse {
    @statusCode statusCode: 400 | 401 | 403 | 404 | 500;
    error: ErrorDetail;
  }

  model ErrorDetail {
    code: string;
    message: string;
  }
}