// Patches the generated Azure OpenAI API plugin to use its own auth registration ID
// instead of the shared APIKEYAUTH_REGISTRATION_ID.
const fs = require("fs");
const path = require("path");

const pluginPath = path.join(
  __dirname,
  "..",
  "appPackage",
  ".generated",
  "azureopenaiapi-apiplugin.json"
);

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
