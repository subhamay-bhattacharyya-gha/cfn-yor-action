# CloudFormation Yor Tagging Action

![Built with Kiro](https://img.shields.io/badge/Built%20with-Kiro-blue?style=flat&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTEyIDJMMTMuMDkgOC4yNkwyMCA5TDEzLjA5IDE1Ljc0TDEyIDIyTDEwLjkxIDE1Ljc0TDQgOUwxMC45MSA4LjI2TDEyIDJaIiBmaWxsPSJ3aGl0ZSIvPgo8L3N2Zz4K)&nbsp;![GitHub Action](https://img.shields.io/badge/GitHub-Action-blue?logo=github)&nbsp;![Release](https://github.com/subhamay-bhattacharyya-gha/cfn-yor-action/actions/workflows/release.yaml/badge.svg)&nbsp;![Commit Activity](https://img.shields.io/github/commit-activity/t/subhamay-bhattacharyya-gha/cfn-yor-action)&nbsp;![Bash](https://img.shields.io/badge/Language-Bash-green?logo=gnubash)&nbsp;![CloudFormation](https://img.shields.io/badge/AWS-CloudFormation-orange?logo=amazonaws)&nbsp;![Last Commit](https://img.shields.io/github/last-commit/subhamay-bhattacharyya-gha/cfn-yor-action)&nbsp;![Release Date](https://img.shields.io/github/release-date/subhamay-bhattacharyya-gha/cfn-yor-action)&nbsp;![Repo Size](https://img.shields.io/github/repo-size/subhamay-bhattacharyya-gha/cfn-yor-action)&nbsp;![File Count](https://img.shields.io/github/directory-file-count/subhamay-bhattacharyya-gha/cfn-yor-action)&nbsp;![Issues](https://img.shields.io/github/issues/subhamay-bhattacharyya-gha/cfn-yor-action)&nbsp;![Top Language](https://img.shields.io/github/languages/top/subhamay-bhattacharyya-gha/cfn-yor-action)&nbsp;![Custom Endpoint](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/bsubhamay/32f412f5da921930c6ad59169859ed46/raw/cfn-yor-action.json?)

A GitHub Action that automatically applies Yor Git metadata tags to CloudFormation templates for better infrastructure traceability and governance.

## 🏷️ CloudFormation Yor Tagging

### 📋 Description

This GitHub Action provides an automated solution for applying [Yor](https://github.com/bridgecrewio/yor) Git metadata tags to CloudFormation templates. Yor is an open-source tool that automatically tags infrastructure-as-code resources with Git metadata, enabling better traceability, governance, and cost management for your AWS infrastructure.

**Key Features:**
- 🔍 **Automatic Discovery**: Identifies CloudFormation templates by file extensions (`.yaml`, `.yml`, `.json`)
- 🏷️ **Git Metadata Tagging**: Applies comprehensive Git metadata tags including commit SHA, repository info, and more
- 📁 **Flexible Directory Support**: Works with custom directory structures and nested folders
- 🔄 **Release Tag Support**: Can checkout and process specific Git release tags
- ⚙️ **Configurable Commits**: Option to automatically commit tagged templates or just apply tags
- 🛡️ **Robust Error Handling**: Graceful handling of invalid templates while continuing to process valid ones
- 📊 **Comprehensive Validation**: Built-in validation for inputs, directories, and CloudFormation syntax

---

## 📥 Inputs

| Name | Description | Required | Default |
|------|-------------|----------|---------|
| `cloudformation-dir` | Relative path to the directory containing CloudFormation templates (`.yaml`, `.yml`, `.json` files). The path is resolved relative to the workspace root. | No | `cloudformation` |
| `release-tag` | Specific Git release tag to checkout before processing templates. If not provided, uses the latest commit on the default branch. | No | `''` (latest commit) |
| `commit-changes` | Whether to automatically commit the Yor-tagged CloudFormation templates back to the repository. Set to `"false"` to only apply tags without committing. | No | `'true'` |
| `github-token` | GitHub token for authenticated API requests to avoid rate limiting. Uses the default GitHub Actions token if not specified. | No | `${{ github.token }}` |

---

## 🚀 Usage Examples

### Basic Usage (Default Directory)

```yaml
name: Tag CloudFormation Templates

on:
  push:
    branches: [ main ]
    paths: [ 'cloudformation/**' ]

jobs:
  tag-cloudformation:
    runs-on: ubuntu-latest
    steps:
      - name: Tag CloudFormation Templates
        uses: subhamay-bhattacharyya-gha/cfn-yor-action@v1
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
```

### Custom Directory with No Auto-Commit

```yaml
name: Tag Infrastructure Templates

on:
  pull_request:
    paths: [ 'infrastructure/**' ]

jobs:
  tag-templates:
    runs-on: ubuntu-latest
    steps:
      - name: Tag Infrastructure Templates
        uses: subhamay-bhattacharyya-gha/cfn-yor-action@v1
        with:
          cloudformation-dir: 'infrastructure/cloudformation'
          commit-changes: 'false'
          github-token: ${{ secrets.GITHUB_TOKEN }}
```

### Process Specific Release Tag

```yaml
name: Tag Release Templates

on:
  release:
    types: [published]

jobs:
  tag-release:
    runs-on: ubuntu-latest
    steps:
      - name: Tag CloudFormation Templates for Release
        uses: subhamay-bhattacharyya-gha/cfn-yor-action@v1
        with:
          release-tag: ${{ github.event.release.tag_name }}
          cloudformation-dir: 'templates'
          github-token: ${{ secrets.GITHUB_TOKEN }}
```

### Advanced Configuration

```yaml
name: Advanced CloudFormation Tagging

on:
  workflow_dispatch:
    inputs:
      directory:
        description: 'CloudFormation directory to process'
        required: false
        default: 'cloudformation'
      tag:
        description: 'Git tag to checkout (optional)'
        required: false
      commit:
        description: 'Commit changes back to repository'
        required: false
        default: 'true'
        type: choice
        options:
          - 'true'
          - 'false'

jobs:
  tag-cloudformation:
    runs-on: ubuntu-latest
    steps:
      - name: Tag CloudFormation Templates
        uses: subhamay-bhattacharyya-gha/cfn-yor-action@v1
        with:
          cloudformation-dir: ${{ github.event.inputs.directory }}
          release-tag: ${{ github.event.inputs.tag }}
          commit-changes: ${{ github.event.inputs.commit }}
          github-token: ${{ secrets.GITHUB_TOKEN }}
```

---

## 🏗️ Supported CloudFormation Templates

This action supports all standard CloudFormation template formats:

- **YAML Templates**: `.yaml` and `.yml` extensions
- **JSON Templates**: `.json` extension
- **Complex Structures**: Nested stacks, cross-stack references, and dependencies
- **All AWS Resources**: EC2, S3, RDS, Lambda, VPC, IAM, and 100+ other AWS services

### Template Structure Support

- ✅ **Parameters**: Input parameters and their validation
- ✅ **Mappings**: Static lookup tables
- ✅ **Conditions**: Conditional resource creation
- ✅ **Resources**: All AWS resource types
- ✅ **Outputs**: Stack outputs and exports
- ✅ **Metadata**: Custom metadata sections
- ✅ **Intrinsic Functions**: `Ref`, `GetAtt`, `Sub`, `Join`, etc.
- ✅ **Nested Stacks**: `AWS::CloudFormation::Stack` resources
- ✅ **Cross-Stack References**: Import/Export functionality

---

## 🏷️ Applied Tags

Yor automatically applies the following Git metadata tags to your CloudFormation resources:

| Tag Key | Description | Example Value |
|---------|-------------|---------------|
| `yor_trace` | Unique trace identifier | `a1b2c3d4-e5f6-7890-abcd-ef1234567890` |
| `git_commit` | Git commit SHA | `abc123def456...` |
| `git_file` | Relative file path | `cloudformation/s3-bucket.yaml` |
| `git_last_modified_at` | Last modification timestamp | `2024-01-15T10:30:00Z` |
| `git_last_modified_by` | Last modifier email | `user@example.com` |
| `git_modifiers` | All contributors | `user1,user2,user3` |
| `git_org` | GitHub organization | `my-organization` |
| `git_repo` | Repository name | `my-infrastructure-repo` |

### Example Tagged Resource

```yaml
Resources:
  MyS3Bucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: my-application-bucket
      Tags:
        - Key: yor_trace
          Value: a1b2c3d4-e5f6-7890-abcd-ef1234567890
        - Key: git_commit
          Value: abc123def456789...
        - Key: git_file
          Value: cloudformation/storage.yaml
        - Key: git_last_modified_at
          Value: 2024-01-15T10:30:00Z
        - Key: git_repo
          Value: my-infrastructure-repo
```

---

## 🔧 Action Workflow

The action follows a comprehensive workflow to ensure reliable processing:

1. **🔍 Input Validation**: Validates all input parameters and formats
2. **📥 Repository Checkout**: Checks out the specified release tag or latest commit
3. **📁 Directory Validation**: Verifies CloudFormation directory exists and is accessible
4. **🔍 Template Discovery**: Identifies all CloudFormation templates (`.yaml`, `.yml`, `.json`)
5. **🏷️ Yor Processing**: Applies Git metadata tags using the Yor tool
6. **✅ Result Validation**: Verifies successful tagging completion
7. **💾 Commit Changes**: Optionally commits tagged templates back to repository
8. **📊 Summary Report**: Provides detailed execution summary

---

## 🛡️ Error Handling

The action includes robust error handling for common scenarios:

### Input Validation Errors
- Invalid `commit-changes` values (must be `'true'` or `'false'`)
- Empty or invalid `cloudformation-dir` paths
- Invalid `release-tag` formats

### Repository Errors
- Non-existent release tags
- Insufficient repository permissions
- Invalid GitHub tokens

### Directory Errors
- Missing CloudFormation directories
- Unreadable directory permissions
- No CloudFormation templates found (warning, not error)

### Template Processing Errors
- Invalid CloudFormation syntax (logs warning, continues processing)
- Unsupported file formats (skipped)
- Network issues during Yor processing

### Commit Errors
- Branch protection rules preventing commits
- No changes to commit (informational)
- Insufficient permissions for commits

---

## 📋 Prerequisites

- **Repository Access**: The action requires read/write access to your repository
- **GitHub Token**: A valid GitHub token with appropriate permissions
- **CloudFormation Templates**: Valid CloudFormation templates in supported formats
- **Directory Structure**: Organized directory structure for your templates

### Required Permissions

The GitHub token needs the following permissions:
- `contents: write` - To commit tagged templates
- `metadata: read` - To access repository metadata
- `actions: read` - To run the action

---

## 🧪 Testing and Validation

This action includes comprehensive testing infrastructure:

### Automated Tests
- **Template Format Validation**: Tests all supported file extensions
- **Resource Identification**: Validates AWS resource type detection
- **Nested Stack Handling**: Tests complex template structures
- **Error Handling**: Validates graceful failure scenarios

### Manual Testing
Use the provided test workflows for manual validation:

```bash
# Run comprehensive validation
gh workflow run validate-cloudformation-processing.yml

# Test specific scenarios
gh workflow run test-action.yml -f test_scenario=default-directory
```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Setup

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [Yor](https://github.com/bridgecrewio/yor) - The open-source tool that powers the tagging functionality
- [Bridgecrew](https://bridgecrew.io/) - For developing and maintaining Yor
- [GitHub Actions](https://github.com/features/actions) - For providing the automation platform

---

## 📞 Support

If you encounter any issues or have questions:

1. Check the [Issues](https://github.com/subhamay-bhattacharyya-gha/cfn-yor-action/issues) page
2. Review the action logs for detailed error messages
3. Create a new issue with detailed information about your problem

For more information about Yor and its capabilities, visit the [official Yor documentation](https://yor.io/).
