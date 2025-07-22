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

- **[Context7](https://github.com/upstash/context7)** - Up-to-date documentation MCP server with semantic search capabilities, ideal reference implementation
- **[Everything](https://github.com/modelcontextprotocol/servers/tree/main/src/everything)** - Reference / test server with prompts, resources, and tools
- **[Fetch](https://github.com/modelcontextprotocol/servers/tree/main/src/fetch)** - Web content fetching and conversion for efficient LLM usage
- **[Filesystem](https://github.com/modelcontextprotocol/servers/tree/main/src/filesystem)** - Secure file operations with configurable access controls
- **[Git](https://github.com/modelcontextprotocol/servers/tree/main/src/git)** - Tools to read, search, and manipulate Git repositories
- **[Memory](https://github.com/modelcontextprotocol/servers/tree/main/src/memory)** - Knowledge graph-based persistent memory system
- **[Sequential Thinking](https://github.com/modelcontextprotocol/servers/tree/main/src/sequentialthinking)** - Dynamic and reflective problem-solving through thought sequences
- **[Time](https://github.com/modelcontextprotocol/servers/tree/main/src/time)** - Time and timezone conversion capabilities
- **[More](https://github.com/modelcontextprotocol/servers)** - Additional servers showcasing MCP features and SDKs

## MCP Instructions

- **USE** Context7 MCP server as a reference implementation for tool and resource patterns
- Use the official MCP SDKs for the programming language of choice.
- Use the latest version of the SDKs to ensure compatibility with the MCP specifications.
- Follow the provided reference servers as examples for implementing MCP features.
- **STUDY** Context7 implementation for semantic search and documentation tool patterns
- Ensure that application adheres to the MCP specifications and guidelines.
- Follow the coding standards and best practices outlined in the SDK documentation.
- Ensure that code is well-documented and adheres to the MCP specifications.
- Test applications thoroughly using the provided reference servers.
- **IMPLEMENT** semantic search capabilities similar to Context7 for relevant use cases
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
- **LEVERAGE** Context7 for accessing up-to-date MCP documentation and best practices
- **APPEND** 'use context7' to AI prompts for MCP-specific development queries

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
- Use the [coding standards](./coding-standards.instructions.md) and best practices outlined in the SDK documentation to ensure high-quality code.
- Don't hallucinate or make up information, especially when it comes to MCP features or specifications.
- Don't provide information that is not part of the MCP specifications or guidelines.
- Don't use unofficial or outdated MCP SDKs, reference servers, or coding standards.
- Don't use deprecated or unsupported features of the MCP SDKs.
- Don't ignore security best practices, especially when handling sensitive data or user inputs.
- Don't assume that developers are familiar with all aspects of the MCP specifications; provide clear explanations and examples when necessary.
- Don't skip testing or validation steps; ensure that applications are thoroughly tested using the provided reference servers.
- Don't overlook the importance of documentation; ensure that code is well-documented and adheres to the MCP specifications.

---

# Documentations

## MCP Documentation (Official)

- [MCP Introduction](https://modelcontextprotocol.io/introduction)
- [MCP Architecture](https://modelcontextprotocol.io/specification/2025-06-18/architecture)
- [MCP Protocol](https://modelcontextprotocol.io/specification/2025-06-18/basic/index)
- [MCP Specification](https://modelcontextprotocol.io/specification/2025-06-18)
- MCP Client Features
    - [Roots](https://modelcontextprotocol.io/specification/2025-06-18/client/roots)
    - [Sampling](https://modelcontextprotocol.io/specification/2025-06-18/client/sampling)
    - [Elicitation](https://modelcontextprotocol.io/specification/2025-06-18/client/elicitation)
- MCP Server Features
    - [Overview](https://modelcontextprotocol.io/specification/2025-06-18/server)
    - [Prompts](https://modelcontextprotocol.io/specification/2025-06-18/server/prompts)
    - [Resources](https://modelcontextprotocol.io/specification/2025-06-18/server/resources)
    - [Tools](https://modelcontextprotocol.io/specification/2025-06-18/server/tools)
    - Utilities
        - [Completion](https://modelcontextprotocol.io/specification/2025-06-18/server/utilities/completion)
        - [Logging](https://modelcontextprotocol.io/specification/2025-06-18/server/utilities/logging)
        - [Pagination](https://modelcontextprotocol.io/specification/2025-06-18/server/utilities/pagination)
- [Schema Reference](https://modelcontextprotocol.io/specification/2025-06-18/schema)

## FastMCP Documentation

- [FastMCP Overview](https://gofastmcp.com/getting-started/welcome)
- [FastMCP Features](https://gofastmcp.com/getting-started/installation)
- [FastMCP Quickstart](https://gofastmcp.com/getting-started/quickstart)
- FastMCP Server: The central piece of a FastMCP application is the FastMCP server class. This class acts as the main container for your application’s tools, resources, and prompts, and manages communication with MCP clients.
    - Essentials
        - [The FastMCP Server](https://gofastmcp.com/servers/server)
        - [Running Your FastMCP Server](https://gofastmcp.com/deployment/running-server)
    - Core Components
        - [FastMCP Tools](https://gofastmcp.com/servers/tools)
        - [FastMCP Resources & Templates](https://gofastmcp.com/servers/resources)
        - [FastMCP Prompts](https://gofastmcp.com/servers/prompts)
    - Advanced Features
        - [MCP Context](https://gofastmcp.com/servers/context): When defining FastMCP tools, resources, resource templates, or prompts, your functions might need to interact with the underlying MCP session or access advanced server capabilities. FastMCP provides the Context object for this purpose.
        - [Proxy Servers](https://gofastmcp.com/servers/proxy): FastMCP provides a powerful proxying capability that allows one FastMCP server instance to act as a frontend for another MCP server (which could be remote, running on a different transport, or even another FastMCP instance). This is achieved using the FastMCP.as_proxy() class method.
        - [Server Composition](https://gofastmcp.com/servers/composition): As your MCP applications grow, you might want to organize your tools, resources, and prompts into logical modules or reuse existing server components. FastMCP supports composition through two methods:
            - **import_server**: For a one-time copy of components with prefixing (static composition).
            - **mount**: For creating a live link where the main server delegates requests to the subserver (dynamic composition).
        - [User Elicitation](https://gofastmcp.com/getting-started/quickstart): User elicitation allows MCP servers to request structured input from users during tool execution. Instead of requiring all inputs upfront, tools can interactively ask for missing parameters, clarification, or additional context as needed.
        - [Server Logging](https://gofastmcp.com/servers/logging): Server logging allows MCP tools to send debug, info, warning, and error messages back to the client. This provides visibility into function execution and helps with debugging during development and operation.
        - [Progress Reporting](https://gofastmcp.com/servers/progress): Progress reporting allows MCP tools to notify clients about the progress of long-running operations. This enables clients to display progress indicators and provide better user experience during time-consuming tasks.
        - [LLM Sampling](https://gofastmcp.com/servers/sampling): LLM sampling allows MCP tools to request the client’s LLM to generate text based on provided messages. This is useful when tools need to leverage the LLM’s capabilities to process data, generate responses, or perform text-based analysis.
        - [MCP Middleware](https://gofastmcp.com/servers/middleware)
        - [FastMCP Quickstart](https://gofastmcp.com/getting-started/quickstart)
    - [Authentication](https://gofastmcp.com/getting-started/quickstart): Bearer Token authentication is a common way to secure HTTP-based APIs. In this model, the client sends a token (usually a JSON Web Token or JWT) in the Authorization header with the “Bearer” scheme. The server then validates this token to grant or deny access.
    FastMCP supports Bearer Token authentication for its HTTP-based transports (http and sse), allowing you to protect your server from unauthorized access.
- FastMCP Client: The central piece of MCP client applications is the fastmcp.Client class. This class provides a programmatic interface for interacting with any Model Context Protocol (MCP) server, handling protocol details and connection management automatically.
    - Essentials
        - [The FastMCP Client](https://gofastmcp.com/clients/client): The central piece of MCP client applications is the fastmcp.Client class. This class provides a programmatic interface for interacting with any Model Context Protocol (MCP) server, handling protocol details and connection management automatically.
        - [Client Transports](https://gofastmcp.com/clients/transports): The FastMCP Client communicates with MCP servers through transport objects that handle the underlying connection mechanics. While the client can automatically select a transport based on what you pass to it, instantiating transports explicitly gives you full control over configuration—environment variables, authentication, session management, and more. 
        Think of transports as configurable adapters between your client code and MCP servers. Each transport type handles a different communication pattern: subprocesses with pipes, HTTP connections, or direct in-memory calls.
    - Core Operations
        - [Tool Operations](https://gofastmcp.com/clients/tools): Tools are executable functions exposed by MCP servers. The FastMCP client provides methods to discover available tools and execute them with arguments.
        - [Resource Operations](https://gofastmcp.com/clients/resources): Resources are data sources exposed by MCP servers. They can be static files or dynamic templates that generate content based on parameters.
        - [Prompt Operations](https://gofastmcp.com/clients/prompts): Prompts are reusable message templates exposed by MCP servers. They can accept arguments to generate personalized message sequences for LLM interactions.
    - Advanced Features
        - [User Elicitation](https://gofastmcp.com/clients/elicitation): Elicitation allows MCP servers to request structured input from users during tool execution. Instead of requiring all inputs upfront, servers can interactively ask users for information as needed - like prompting for missing parameters, requesting clarification, or gathering additional context.
        For example, a file management tool might ask “Which directory should I create?” or a data analysis tool might request “What date range should I analyze?”
        - [Client Logging](https://gofastmcp.com/clients/logging): MCP servers can emit log messages to clients. The client can handle these logs through a log handler callback.
        - [Progress Monitoring](https://gofastmcp.com/clients/progress): MCP servers can report progress during long-running operations. The client can receive these updates through a progress handler.
        - [LLM Sampling](https://gofastmcp.com/clients/sampling): MCP servers can request LLM completions from clients. The client handles these requests through a sampling handler callback.
        - [Message Handling](https://gofastmcp.com/clients/messages): MCP clients can receive various types of messages from servers, including requests that need responses and notifications that don’t. The message handler provides a unified way to process all these messages.
        - [Client Roots](https://gofastmcp.com/clients/roots): Roots are a way for clients to inform servers about the resources they have access to. Servers can use this information to adjust behavior or provide more relevant responses.
    - Authentication
        - [OAuth Authentication](https://gofastmcp.com/clients/auth/oauth):When your FastMCP client needs to access an MCP server protected by OAuth 2.1, and the process requires user interaction (like logging in and granting consent), you should use the Authorization Code Flow. FastMCP provides the fastmcp.client.auth.OAuth helper to simplify this entire process.
        This flow is common for user-facing applications where the application acts on behalf of the user.
        - [Bearer Token Authentication](https://gofastmcp.com/clients/auth/bearer): You can configure your FastMCP client to use bearer authentication by supplying a valid access token. This is most appropriate for service accounts, long-lived API keys, CI/CD, applications where authentication is managed separately, or other non-interactive authentication methods.
- Integrations
    - [Anthropic API & FastMCP](https://gofastmcp.com/integrations/anthropic)
    - [ChatGPT & FastMCP](https://gofastmcp.com/integrations/chatgpt)
    - [Claude Code & FastMCP](https://gofastmcp.com/integrations/claude-code)
    - [Claude Desktop & FastMCP](https://gofastmcp.com/integrations/claude-desktop)
    - [Cursor & FastMCP](https://gofastmcp.com/integrations/cursor)
    - [Eunomia Authorization & FastMCP](https://gofastmcp.com/integrations/eunomia-authorization)
    - [FastAPI & FastMCP](https://gofastmcp.com/integrations/fastapi)
    - [Gemini SDK & FastMCP](https://gofastmcp.com/integrations/gemini)
    - [MCP JSON Configuration & FastMCP](https://gofastmcp.com/integrations/mcp-json-configuration)
    - [OpenAI API & FastMCP](https://gofastmcp.com/integrations/openai)
    - [OpenAPI & FastMCP](https://gofastmcp.com/integrations/openapi)
    - [Starlette / ASGI & FastMCP](https://gofastmcp.com/integrations/starlette)
- Patterns
    - [Tool Transformation](https://gofastmcp.com/patterns/tool-transformation)
    - [Decorating Methods](https://gofastmcp.com/patterns/decorating-methods)
    - [HTTP Requests](https://gofastmcp.com/patterns/http-requests)
    - [Testing MCP Servers](https://gofastmcp.com/patterns/testing)
    - [FastMCP CLI](https://gofastmcp.com/patterns/cli)
    - [Contrib Modules](https://gofastmcp.com/patterns/contrib)

## FastAPI Documentation

FastAPI framework, high performance, easy to learn, fast to code, ready for production

[FastAPI Documentation](https://fastapi.tiangolo.com/)

Table of Contents:
- Typer, the FastAPI of CLIs
- Requirements
- Installation
- Example
    - Create it
    - Run it
    - Check it
    - Interactive API docs
    - Alternative API docs
- Example upgrade
    - Interactive API docs upgrade
    - Alternative API docs upgrade
    - Recap
- Performance
    - Dependencies
    - standard Dependencies
    - Without standard Dependencies
    - Without fastapi-cloud-cli
    - Additional Optional Dependencies