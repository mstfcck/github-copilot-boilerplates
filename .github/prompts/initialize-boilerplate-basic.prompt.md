---
mode: agent
---

# Initialize Boilerplate Basic

This prompt is designed to help you quickly set up a new project using the boilerplate structure provided in this repository. Follow the steps below to get started.

## Step 1: Choose Your Boilerplate

Ask the user to initialize the boilerplate based on their project needs:

- **Boilerplate Name**: ${input:boilerplateName}
- **Project Type**: ${input:projectType} (e.g., web application, API service, etc.)
- **Technology Stack**: ${input:technologyStack} (e.g., Spring Boot, Node.js, etc.)
- **Implementation Level**: ${input:implementationLevel} (e.g., basic, advanced, production-ready)
- **Additional Requirements**: ${input:additionalRequirements} (e.g., database integration, authentication, etc.)

Ensure that the user provides all necessary details to tailor the boilerplate to their specific needs.

## Step 2: Analyze Boilerplate Instructions

Review the boilerplate instructions to ensure compliance with the project's requirements.
Ensure the boilerplate structure follows all the instructions step by step.
Ensure the boilerplate structure follows the conventions outlined in the boilerplate instructions.

## Step 3: Generate Boilerplate Code

Think step by step using Sequential Thinking MCP Server and Context7 MCP Server for up-to-date context.

Use the boilerplate instructions to generate the initial code structure for the project. This includes:
- Directory structure
- Configuration files
- Sample code files (controllers, services, repositories, etc.)