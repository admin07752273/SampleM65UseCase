// Patches the generated Azure OpenAI API files to use a distinct auth name
// ("AzureOpenAIApiKeyAuth") so it doesn't collide with CopilotStudioAPI's "ApiKeyAuth"
// in the Teams-portal API-key registration.
const fs = require("fs");
const path = require("path");

const generatedDir = path.join(__dirname, "..", "appPackage", ".generated");

// 1. Rename the security scheme in the OpenAPI spec
const openapiPath = path.join(generatedDir, "azureopenaiapi-openapi.yml");
let openapi = fs.readFileSync(openapiPath, "utf8");
const patchedOpenapi = openapi
  .replace(/^(\s+)ApiKeyAuth:/m, "$1AzureOpenAIApiKeyAuth:")
  .replace(/- ApiKeyAuth: \[ \]/g, "- AzureOpenAIApiKeyAuth: [ ]");

if (openapi !== patchedOpenapi) {
  fs.writeFileSync(openapiPath, patchedOpenapi, "utf8");
  console.log("Patched azureopenaiapi-openapi.yml security scheme name.");
} else {
  console.log("azureopenaiapi-openapi.yml already has correct scheme name.");
}

// 2. Update the plugin registration reference
const pluginPath = path.join(generatedDir, "azureopenaiapi-apiplugin.json");
const content = fs.readFileSync(pluginPath, "utf8");
const patched = content.replace(
  /\$\{\{APIKEYAUTH_REGISTRATION_ID\}\}/g,
  "${{AZURE_OPENAI_AUTH_REGISTRATION_ID}}"
);

if (content !== patched) {
  fs.writeFileSync(pluginPath, patched, "utf8");
  console.log("Patched azureopenaiapi-apiplugin.json auth reference.");
} else {
  console.log("azureopenaiapi-apiplugin.json already has correct auth reference.");
}
