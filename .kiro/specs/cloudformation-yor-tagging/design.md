# Design Document

## Overview

The CloudFormation Yor Tagging action is a GitHub composite action that automatically applies Git metadata tags to CloudFormation templates using the Yor tool. The action follows the same pattern as the existing Terraform Yor action but is specifically configured for CloudFormation template processing.

The action will:
1. Check out the repository at a specified release tag or latest commit
2. Run the Yor tool configured for CloudFormation templates
3. Optionally commit the tagged templates back to the repository

## Architecture

### Action Structure
The action follows GitHub's composite action pattern with the following components:

```
action.yaml (main action definition)
├── inputs (configuration parameters)
├── runs.steps[]
    ├── Checkout Repository
    ├── Run Yor Action (CloudFormation mode)
    └── Commit Changes (conditional)
```

### Input Parameters
- `cloudformation-dir`: Target directory containing CloudFormation templates
- `release-tag`: Specific Git tag to checkout (optional)
- `commit-changes`: Boolean flag to control auto-commit behavior
- `github-token`: Authentication token for API requests

### External Dependencies
- `actions/checkout@v4`: Repository checkout
- `bridgecrewio/yor-action@main`: Core Yor tagging functionality
- `stefanzweifel/git-auto-commit-action@v6`: Automated commit handling

## Components and Interfaces

### Input Interface
```yaml
inputs:
  cloudformation-dir:
    description: "Relative path to CloudFormation templates directory"
    required: false
    type: string
    default: "cloudformation"
  
  release-tag:
    description: "Git release tag to check out"
    required: false
    type: string
    default: ""
  
  commit-changes:
    description: "Whether to commit tagged files"
    required: false
    type: boolean
    default: true
  
  github-token:
    description: "GitHub token for authenticated API requests"
    required: false
    default: ${{ github.token }}
```

### Step Components

#### 1. Repository Checkout Step
- **Purpose**: Checkout repository at specified tag or latest commit
- **Implementation**: Uses `actions/checkout@v4`
- **Configuration**: Standard checkout with no special parameters

#### 2. Yor Tagging Step
- **Purpose**: Apply Git metadata tags to CloudFormation templates
- **Implementation**: Uses `bridgecrewio/yor-action@main`
- **Configuration**:
  - `directory`: Resolved path to CloudFormation templates
  - `tag_groups`: Set to "git" for Git metadata tagging
  - `output_format`: Set to "json" for structured output
  - Environment variables for authentication and logging

#### 3. Commit Changes Step (Conditional)
- **Purpose**: Commit tagged files back to repository
- **Implementation**: Uses `stefanzweifel/git-auto-commit-action@v6`
- **Condition**: Only runs when `commit-changes` input is true
- **Configuration**: Standard auto-commit with appropriate commit message

## Data Models

### Action Inputs Model
```typescript
interface ActionInputs {
  cloudformationDir: string;     // Default: "cloudformation"
  releaseTag: string;            // Default: ""
  commitChanges: boolean;        // Default: true
  githubToken: string;           // Default: github.token
}
```

### Yor Configuration Model
```typescript
interface YorConfig {
  directory: string;             // Resolved CloudFormation directory path
  tagGroups: "git";             // Fixed to git metadata
  outputFormat: "json";         // Fixed to JSON output
  environment: {
    LOG_LEVEL: "DEBUG";
    GITHUB_TOKEN: string;
  };
}
```

## Error Handling

### Input Validation
- **Invalid Directory**: If the specified CloudFormation directory doesn't exist, the action should fail gracefully with a clear error message
- **Invalid Release Tag**: If a non-existent release tag is specified, the checkout step will fail with GitHub's standard error handling
- **Missing Token**: If no GitHub token is provided and the default is unavailable, Yor may encounter rate limiting

### Runtime Errors
- **Yor Execution Failures**: The action will inherit error handling from the `bridgecrewio/yor-action`
- **Commit Failures**: Auto-commit failures will be handled by the `stefanzweifel/git-auto-commit-action`
- **Permission Issues**: File system permission errors will cause the action to fail with appropriate error messages

### Error Propagation
- All steps use standard GitHub Actions error propagation
- Failed steps will cause the entire action to fail
- Error messages will be visible in the GitHub Actions logs

## Testing Strategy

### Unit Testing Approach
Since this is a composite GitHub Action, testing will focus on:

1. **Input Validation Testing**
   - Test default value assignment
   - Test input parameter parsing
   - Test edge cases for directory paths

2. **Integration Testing**
   - Test with various CloudFormation template structures
   - Test with different repository configurations
   - Test commit and no-commit scenarios

3. **End-to-End Testing**
   - Create test repositories with sample CloudFormation templates
   - Run the action in different GitHub workflow contexts
   - Verify tagging output and commit behavior

### Test Scenarios
- **Basic Functionality**: Default parameters with standard CloudFormation templates
- **Custom Directory**: Non-default CloudFormation directory location
- **Release Tag Checkout**: Specific release tag processing
- **No Commit Mode**: Tagging without committing changes
- **Error Conditions**: Invalid directories, missing files, permission issues

### Validation Criteria
- CloudFormation templates are correctly identified and processed
- Git metadata tags are properly applied to resources
- Commit behavior matches the input configuration
- Error handling provides clear, actionable messages
- Performance is acceptable for typical repository sizes