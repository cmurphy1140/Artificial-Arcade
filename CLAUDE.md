# CLAUDE.md - Project Guidelines and Quality Standards

## Purpose
This document establishes quality control standards and agent usage guidelines to ensure high-quality code delivery.

## Available Agents

### 1. Quality Control Enforcer Agent
**Location**: `~/.claude/agents/quality-control-enforcer.md` (when configured)
**Purpose**: Reviews and validates work to ensure it meets quality standards and avoids common pitfalls.

**When to Use**:
- After implementing any new feature
- At natural stop points in development
- When completing a task from the todo list
- Before marking any todo item as complete
- When user expresses concern about code quality

**What it Checks**:
- No workarounds or temporary fixes
- Real implementation (no simulated data)
- Complete functionality end-to-end
- Preserved working solutions
- Proper error handling
- No hard-coded logic that should be LLM-driven

### 2. CLAUDE.md Checker Agent
**Location**: `~/.claude/agents/claude-md-checker.md` (when configured)
**Purpose**: Ensures all work adheres to guidelines specified in this CLAUDE.md file.

**When to Use**:
- At the END of EVERY todo list completion
- After making changes to project structure
- When modifying development workflows
- Before finalizing any implementation

### 3. Playwright MCP Agent
**Configuration**: `/Users/connormurphy/Desktop/playwright_mcp_agent_config.json`
**Purpose**: Specialized browser automation and web interaction tasks.

**When to Use**:
- Web scraping tasks
- Browser automation needs
- Form testing and submission
- Accessibility testing
- Dynamic content interaction

## Mandatory Quality Control Process

### Todo List Requirements
**CRITICAL**: Every todo list MUST follow this structure:
1. Planning tasks
2. Implementation tasks
3. Testing/verification tasks
4. **Quality Control Check** (using quality-control-enforcer agent)
5. **CLAUDE.md Adherence Check** (ALWAYS the final task)

### Stop Point Protocol
At EVERY natural stop point or feature completion:
1. Run the quality-control-enforcer agent
2. Address any issues identified
3. Re-run until PASS status achieved
4. Document findings in comments or logs

## Common Frustrations to Avoid

Based on user feedback, these issues MUST be prevented:

1. **Usage Limits**: Be efficient with context and tool usage
2. **Performance Issues**: Optimize code for speed, avoid unnecessary operations
3. **Code Generation Loops**: Don't regenerate the same broken code - fix root causes
4. **Incomplete Instructions**: Read and follow ALL parts of user prompts
5. **Temporal Context**: Use current dates from environment, not training data
6. **Integration Problems**: Test with actual tools and environments
7. **Transparency**: Clearly communicate what's being done and why
8. **Error Handling**: Don't hide errors - address them properly
9. **Innovation**: Suggest improvements and modern approaches
10. **Real Solutions**: Never use workarounds or simulated functionality

## Workflow Standards

### Before Starting Work
1. Read this CLAUDE.md file
2. Understand the project context
3. Create a comprehensive todo list
4. Plan quality checkpoints

### During Development
1. Follow todo list systematically
2. Mark items in_progress before starting
3. Complete one task fully before moving on
4. Run quality checks at stop points
5. Use appropriate agents for specialized tasks

### After Completing Work
1. Run quality-control-enforcer agent
2. Fix any identified issues
3. Verify all todos are complete
4. Run CLAUDE.md checker as final step
5. Provide clear summary of work done

## Agent Integration Commands

### Using Quality Control Enforcer
```
Use the Task tool with subagent_type: "general-purpose" and prompt:
"Act as the quality-control-enforcer agent and review [specific implementation/code] 
for workarounds, incomplete implementations, and quality issues."
```

### Using CLAUDE.md Checker
```
Use the Task tool with subagent_type: "general-purpose" and prompt:
"Act as the CLAUDE.md checker agent. Read /Users/connormurphy/Artificial Arcade/CLAUDE.md 
and verify that recent changes and implementations adhere to all guidelines."
```

## Enforcement Rules

1. **NO EXCEPTIONS**: These guidelines apply to ALL work
2. **QUALITY OVER SPEED**: Better to do it right than fast
3. **REAL SOLUTIONS ONLY**: No mocking, simulation, or pretending
4. **COMPLETE IMPLEMENTATIONS**: Partial solutions are not acceptable
5. **CONTINUOUS VALIDATION**: Check quality at every opportunity

## Update History
- Initial creation: Guidelines for agent usage and quality control
- Added: Playwright MCP agent configuration
- Added: Mandatory todo list structure
- Added: Stop point protocol
- Added: Common frustrations prevention list

---
*This file should be updated whenever new agents are added or quality standards change.*