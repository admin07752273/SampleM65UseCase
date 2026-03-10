import "@typespec/http";
import "@typespec/openapi3";
import "@microsoft/typespec-m365-copilot";
import "./actions/github.tsp";
import "./actions/nasa.tsp";
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
  title: "Getting started",
  text: "How can I get started with Agents Toolkit?"
})

@conversationStarter(#{
  title: "Getting Help",
  text: "How can I get help with Agents Toolkit?"
})
@conversationStarter(#{
  title: "NASA Picture of the Day",
  text: "Get NASA's Astronomy Picture of the Day"
})
namespace Trial1 {  

// Uncomment this part to include custom actions in the agent
op searchIssues is global.GitHubAPI.searchIssues;

op getApod is NasaAPI.getApod;
op getMarsPhotos is NasaAPI.getMarsPhotos;
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