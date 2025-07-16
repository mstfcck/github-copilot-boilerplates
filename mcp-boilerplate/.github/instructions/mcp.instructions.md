---
applyTo: '**'
---
MCP SDKs, reference servers, and coding standards that AI should follow.

# MCP Instructions

This document outlines the SDKs, reference servers, and coding standards for the Model Context Protocol (MCP). It serves as a guide for developers to ensure consistency and quality in MCP applications.

## MCP SDKs

- [C# MCP SDK](https://github.com/modelcontextprotocol/csharp-sdk)
- [Java MCP SDK](https://github.com/modelcontextprotocol/java-sdk)
- [Kotlin MCP SDK](https://github.com/modelcontextprotocol/kotlin-sdk)
- [Python MCP SDK](https://github.com/modelcontextprotocol/python-sdk)
- [Typescript MCP SDK](https://github.com/modelcontextprotocol/typescript-sdk)

## Reference MCP Servers

These servers aim to demonstrate MCP features and the official SDKs.

- **[Everything](https://github.com/modelcontextprotocol/servers/tree/main/src/everything)** - Reference / test server with prompts, resources, and tools
- **[Fetch](https://github.com/modelcontextprotocol/servers/tree/main/src/fetch)** - Web content fetching and conversion for efficient LLM usage
- **[Filesystem](https://github.com/modelcontextprotocol/servers/tree/main/src/filesystem)** - Secure file operations with configurable access controls
- **[Git](https://github.com/modelcontextprotocol/servers/tree/main/src/git)** - Tools to read, search, and manipulate Git repositories
- **[Memory](https://github.com/modelcontextprotocol/servers/tree/main/src/memory)** - Knowledge graph-based persistent memory system
- **[Sequential Thinking](https://github.com/modelcontextprotocol/servers/tree/main/src/sequentialthinking)** - Dynamic and reflective problem-solving through thought sequences
- **[Time](https://github.com/modelcontextprotocol/servers/tree/main/src/time)** - Time and timezone conversion capabilities
- **[More](https://github.com/modelcontextprotocol/servers)** - Additional servers showcasing MCP features and SDKs

## MCP Instructions

- Use the official MCP SDKs for the programming language of choice.
- Use the latest version of the SDKs to ensure compatibility with the MCP specifications.
- Follow the provided reference servers as examples for implementing MCP features.
- Ensure that application adheres to the MCP specifications and guidelines.
- Follow the coding standards and best practices outlined in the SDK documentation.
- Ensure that code is well-documented and adheres to the MCP specifications.
- Test applications thoroughly using the provided reference servers.
- Encourage the use of consistent naming conventions and code formatting.
- Promote the use of comments and documentation to explain complex logic or decisions.
- Ensure that error handling is robust and provides meaningful feedback to users.
- Use appropriate logging mechanisms to track application behavior and issues.
- Follow security best practices, especially when handling sensitive data or user inputs.
- Maintain a modular architecture to facilitate code reuse and maintainability.
- Use dependency management tools to handle external libraries and packages.
- Regularly update dependencies to keep the application secure and up-to-date.
- Encourage the use of version control systems (e.g., Git) for collaborative development.
- Ensure that you create or update the .gitignore file to exclude unnecessary files from version control based on the programming language and framework used.

## Ask Developers

- Ask developers to provide which MCP SDK needs to be use to complete the MCP Boilerplate.
- Ask developers to provide they want to develop a server or client application.
- Ask developers to provide clear and concise descriptions of their applications, including the purpose, features, and any specific requirements.
- Ask developers to provide any specific reference servers they would like to use as examples if applicable.
- Ask developers to provide any specific libraries or frameworks they would like to use in their MCP applications if applicable.
- Ask developers to provide any specific testing frameworks or tools they would like to use for their MCP applications if applicable.
- Ask developers to provide any specific deployment or hosting requirements for their MCP applications if applicable.
- Ask developers to provide any specific performance or scalability requirements for their MCP applications if applicable.
- Ask developers to provide any specific security requirements or considerations for their MCP applications if applicable.
- Ask developers to provide any specific user interface or user experience requirements for their MCP applications if applicable.
- Ask developers to provide any specific integration requirements with other systems or services if applicable.
- Ask developers to provide any specific data storage or database requirements for their MCP applications if applicable.

## Actions for AI

- Use the official MCP SDKs to implement the requested features or functionalities that developers provide.
- Use the [coding standards](./coding-standarts.instructions.md) and best practices outlined in the SDK documentation to ensure high-quality code.
- Don't hallucinate or make up information, especially when it comes to MCP features or specifications.
- Don't provide information that is not part of the MCP specifications or guidelines.
- Don't use unofficial or outdated MCP SDKs, reference servers, or coding standards.
- Don't use deprecated or unsupported features of the MCP SDKs.
- Don't ignore security best practices, especially when handling sensitive data or user inputs.
- Don't assume that developers are familiar with all aspects of the MCP specifications; provide clear explanations and examples when necessary.
- Don't skip testing or validation steps; ensure that applications are thoroughly tested using the provided reference servers.
- Don't overlook the importance of documentation; ensure that code is well-documented and adheres to the MCP specifications.

---

# Documentation

- [MCP Architecture](../../docs/mcp/PROTOCOL_ARCHITECTURE.md)
- [MCP Protocol](../../docs/mcp/PROTOCOL_BASE_PROTOCOL.md)
- [MCP Specification](../../docs/mcp/PROTOCOL_SPECIFICATION.md)
- [MCP Client Features](../../docs/mcp/PROTOCOL_CLIENT_FEATURES.md)
- [MCP Server Features](../../docs/mcp/PROTOCOL_SERVER_FEATURES.md)
