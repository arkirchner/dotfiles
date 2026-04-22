# Opencode Agents Configuration

When operating in this environment, please proactively utilize the following configured Model Context Protocol (MCP) servers to gather information and context:

- **rails**: Use this MCP when interacting with or querying the local Ruby on Rails environment, codebase, and documentation. For Rails applications, you MUST use the rails MCP for documentation first. Only if you cannot find the necessary information here should you fall back to context7.
- **context7**: Use this MCP to query up-to-date documentation, API references, and code examples for various programming libraries and frameworks.
- **exa**: Use this MCP for web search capabilities to find current information, news, guides, or troubleshooting steps on the internet.
- **nixos**: Use this MCP to query NixOS packages, system options, Home Manager options, Darwin configurations, and Flake inputs.
