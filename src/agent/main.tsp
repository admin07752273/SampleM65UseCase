import "@typespec/http";
import "@typespec/openapi3";
import "@microsoft/typespec-m365-copilot";
import "./actions/github.tsp";
import "./actions/nasa.tsp";
import "./actions/githubAuth.tsp";
import "./actions/directline.tsp";
import "./actions/azureOpenAI.tsp";
import "./prompts/instructions.tsp";
import "./env.tsp";

using TypeSpec.M365.Copilot.Agents;

@agent(
  "Trial1",
  "Declarative agent created with Microsoft 365 Agents Toolkit and TypeSpec for Microsoft 365 Copilot."
)
@instructions(Prompts.INSTRUCTIONS)

// This will be shown to the user when the agent is first created.
// max limit - 12
@conversationStarter(#{
  title: "Get latest issues",
  text: "Get the latest issues from GitHub" 
})
@conversationStarter(#{
  title: "Getting Help",
  text: "How can I get help with Agents Toolkit?"
})
@conversationStarter(#{
  title: "NASA Picture of the Day2",
  text: "Get NASA's Astronomy Picture of the Day"
})
@conversationStarter(#{
  title: "Ask AI Assistant",
  text: "Ask the Copilot Studio AI assistant a question"
})
@conversationStarter(#{
  title: "Ask Azure OpenAI",
  text: "Use my Azure AI Foundry model to answer a question"
})
namespace Trial1 {  

  // API without authentication
op searchIssues is global.GitHubAPI.searchIssues;

// Authenticated API 
op createIssue is GitHubAuthAPI.createIssue;
op getIssues is GitHubAuthAPI.getIssues;
op updateIssue is GitHubAuthAPI.updateIssue;
op getPullRequests is GitHubAuthAPI.getPullRequests;
op createPullRequest is GitHubAuthAPI.createPullRequest;
op mergePullRequest is GitHubAuthAPI.mergePullRequest;
op getProjectInsights is GitHubAuthAPI.getProjectInsights;

// Copilot Studio AI Assistant (via Direct Line)
op startConversation is CopilotStudioAPI.startConversation;
op sendMessage is CopilotStudioAPI.sendMessage;
op getActivities is CopilotStudioAPI.getActivities;

op getApod is NasaAPI.getApod;
op getMarsPhotos is NasaAPI.getMarsPhotos;

// Azure OpenAI (Azure AI Foundry)
op chatCompletion is AzureOpenAIAPI.chatCompletion;
// Enable web search capability
// op webSearch is AgentCapabilities.WebSearch;

// Enable code interpreter capability
op codeInterpreter is AgentCapabilities.CodeInterpreter;
//max limit 4

//   op webSearch is AgentCapabilities.WebSearch<TSites = [
//   { url: "https://learn.microsoft.com" },
//   { url: "https://github.com" }
// ]>;

  op od_sp is AgentCapabilities.OneDriveAndSharePoint;

  // Copilot Connector - Adaptive Cards website
  op copilotConnectors is AgentCapabilities.CopilotConnectors<Connections = [
    { connectionId: "IntranetSitesCloud2603090858" }
  ]>;

  // op od_sp is AgentCapabilities.OneDriveAndSharePoint<ItemsByUrl = [
  //   {
  //     url: "https://m365x07752273.sharepoint.com/sites/USSales"
  //   }
  // ]>;
}