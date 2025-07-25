# Requirements Document

## Introduction

This feature involves creating a GitHub reusable action that applies Yor Git metadata tagging to CloudFormation templates, similar to the existing Terraform Yor action. The action will scan CloudFormation templates in a specified directory, apply Git metadata tags using Yor, and optionally commit the changes back to the repository. This enables automatic tagging of CloudFormation resources with Git metadata for better traceability and governance.

## Requirements

### Requirement 1

**User Story:** As a DevOps engineer, I want to automatically tag my CloudFormation resources with Git metadata, so that I can trace infrastructure changes back to specific commits and maintain better governance.

#### Acceptance Criteria

1. WHEN the action is triggered THEN the system SHALL scan the specified CloudFormation directory for template files
2. WHEN CloudFormation templates are found THEN the system SHALL apply Yor Git metadata tags to the resources
3. WHEN tagging is complete THEN the system SHALL output the results in JSON format
4. IF commit-changes is true THEN the system SHALL commit the tagged files back to the repository

### Requirement 2

**User Story:** As a developer, I want to specify which directory contains my CloudFormation templates, so that the action can target the correct files regardless of my project structure.

#### Acceptance Criteria

1. WHEN the cloudformation-dir input is provided THEN the system SHALL use that directory path for scanning
2. IF no cloudformation-dir is specified THEN the system SHALL default to "cloudformation" directory
3. WHEN the directory path is relative THEN the system SHALL resolve it relative to the workspace root
4. IF the specified directory does not exist THEN the system SHALL handle the error gracefully

### Requirement 3

**User Story:** As a release manager, I want to tag CloudFormation templates at specific release points, so that I can maintain consistent tagging across different versions.

#### Acceptance Criteria

1. WHEN a release-tag input is provided THEN the system SHALL checkout that specific tag before processing
2. IF no release-tag is specified THEN the system SHALL use the latest commit on the default branch
3. WHEN checking out a release tag THEN the system SHALL verify the tag exists before proceeding
4. IF the release tag is invalid THEN the system SHALL fail with a clear error message

### Requirement 4

**User Story:** As a CI/CD pipeline maintainer, I want control over whether tagged files are automatically committed, so that I can integrate the action into different workflow patterns.

#### Acceptance Criteria

1. WHEN commit-changes is set to true THEN the system SHALL automatically commit tagged files
2. WHEN commit-changes is set to false THEN the system SHALL only apply tags without committing
3. IF commit-changes is not specified THEN the system SHALL default to true
4. WHEN committing changes THEN the system SHALL use an appropriate commit message indicating Yor tagging

### Requirement 5

**User Story:** As a security-conscious developer, I want the action to use authenticated GitHub API requests, so that I can avoid rate limiting issues and ensure secure access.

#### Acceptance Criteria

1. WHEN a github-token is provided THEN the system SHALL use it for authenticated API requests
2. IF no github-token is specified THEN the system SHALL default to the GitHub Actions token
3. WHEN making API requests THEN the system SHALL include proper authentication headers
4. IF authentication fails THEN the system SHALL provide clear error messaging

### Requirement 6

**User Story:** As a DevOps engineer, I want the action to work specifically with CloudFormation template formats, so that it correctly identifies and processes my infrastructure files.

#### Acceptance Criteria

1. WHEN scanning directories THEN the system SHALL identify CloudFormation templates by file extensions (.yaml, .yml, .json)
2. WHEN processing templates THEN the system SHALL validate they are valid CloudFormation format
3. WHEN applying tags THEN the system SHALL use CloudFormation-specific resource identification
4. IF invalid CloudFormation templates are found THEN the system SHALL log warnings but continue processing valid files