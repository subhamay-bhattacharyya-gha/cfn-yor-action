# CloudFormation Yor Tagging Action - Test Scenarios

This document describes the comprehensive test scenarios created for the CloudFormation Yor Tagging action.

## Test Structure

### Test Workflows
- **`.github/workflows/test-action.yml`**: Main automated test workflow
- **`.github/workflows/manual-test.yml`**: Manual testing workflow for interactive testing

### Test Templates
The following CloudFormation templates are available in the `test-templates/` directory:

| Template | Format | Purpose | Resources |
|----------|--------|---------|-----------|
| `basic-s3-bucket.yaml` | YAML | Basic functionality testing | S3 Bucket, Bucket Policy |
| `ec2-instance.json` | JSON | JSON format testing | EC2 Instance, Security Group |
| `vpc-stack.yaml` | YAML | Complex stack testing | VPC, Subnets, NAT Gateway, Route Tables |
| `rds-database.yml` | YML | .yml extension testing | RDS Instance, Security Groups, Parameter Group |
| `lambda-function.yaml` | YAML | No-commit scenario | Lambda Function, IAM Role, Log Group |
| `api-gateway.json` | JSON | No-commit scenario | API Gateway, Methods, Deployment |
| `sns-topic.yaml` | YAML | Commit scenario | SNS Topic, Subscription, Topic Policy |
| `sqs-queue.yml` | YML | Commit scenario | SQS Queue, Dead Letter Queue, Queue Policy |

## Test Scenarios

### 1. Default Directory Behavior Test
**Requirements Validated**: 1.1, 1.2, 1.3, 2.2

- **Purpose**: Validates that the action works with the default `cloudformation/` directory
- **Setup**: Creates `cloudformation/` directory with sample templates
- **Templates Used**: `basic-s3-bucket.yaml`, `ec2-instance.json`
- **Expected Result**: Yor tags applied to all templates in default directory

### 2. Custom Directory Specification Test
**Requirements Validated**: 2.1, 2.3

- **Purpose**: Validates custom directory path specification
- **Setup**: Creates `infrastructure/cloudformation/` directory structure
- **Templates Used**: `vpc-stack.yaml`, `rds-database.yml`
- **Configuration**: `cloudformation-dir: infrastructure/cloudformation`
- **Expected Result**: Yor tags applied to templates in custom directory

### 3. No-Commit Scenario Test
**Requirements Validated**: 4.1, 4.2

- **Purpose**: Validates that files are tagged but not committed when `commit-changes: false`
- **Setup**: Creates templates and tracks git status
- **Templates Used**: `lambda-function.yaml`, `api-gateway.json`
- **Configuration**: `commit-changes: false`
- **Expected Result**: Files modified but no git commit created

### 4. Commit Scenario Test
**Requirements Validated**: 4.1, 4.3

- **Purpose**: Validates that tagged files are committed when `commit-changes: true`
- **Setup**: Tracks initial commit hash and compares after action
- **Templates Used**: `sns-topic.yaml`, `sqs-queue.yml`
- **Configuration**: `commit-changes: true`
- **Expected Result**: New commit created with tagged files

### 5. Release Tag Checkout Test
**Requirements Validated**: 3.1, 3.2, 3.3

- **Purpose**: Validates checkout of specific release tags
- **Setup**: Creates a test tag and attempts to check it out
- **Configuration**: `release-tag: v1.0.0-test`
- **Expected Result**: Action runs against specified tag

### 6. Error Handling Test
**Requirements Validated**: 2.4, 3.4

- **Purpose**: Validates proper error handling for invalid inputs
- **Test Cases**:
  - Invalid directory path
  - Non-existent release tag
- **Expected Result**: Action fails gracefully with clear error messages

### 7. Multiple Template Formats Test
**Requirements Validated**: 1.1, 1.2

- **Purpose**: Validates processing of all supported CloudFormation formats
- **Templates Used**: Mixed `.yaml`, `.yml`, and `.json` files
- **Expected Result**: All template formats processed correctly

## Running Tests

### Automated Tests
The main test workflow runs automatically on:
- Push to `main` or `develop` branches
- Pull requests to `main` branch
- Manual workflow dispatch

```bash
# Trigger specific test scenario
gh workflow run test-action.yml -f test_scenario=default-directory
```

### Manual Testing
Use the manual test workflow for interactive testing:

```bash
# Run manual test with custom parameters
gh workflow run manual-test.yml \
  -f cloudformation_dir=infrastructure/cf \
  -f commit_changes=false \
  -f release_tag=v1.0.0
```

## Test Validation Criteria

### Success Criteria
1. **Tagging Verification**: Yor tags (containing `yor_trace`) found in processed templates
2. **Format Support**: All CloudFormation formats (.yaml, .yml, .json) processed
3. **Directory Handling**: Both default and custom directories work correctly
4. **Commit Behavior**: Commit/no-commit scenarios work as configured
5. **Error Handling**: Invalid inputs produce clear error messages

### Failure Indicators
- No Yor tags found in templates after processing
- Action fails with unclear error messages
- Incorrect commit behavior (commits when shouldn't, or vice versa)
- Templates not processed due to format issues

## Requirements Coverage

| Requirement | Test Scenario | Validation Method |
|-------------|---------------|-------------------|
| 1.1 | Default Directory, Multiple Formats | Check for yor_trace in templates |
| 1.2 | Default Directory, Multiple Formats | Verify JSON output format |
| 1.3 | Default Directory | Confirm tagging completion |
| 1.4 | Default Directory | Verify conditional commit logic |
| 2.1 | Custom Directory | Test custom path specification |
| 2.2 | Default Directory | Confirm default directory usage |
| 2.3 | Custom Directory | Test relative path resolution |
| 2.4 | Error Handling | Test invalid directory handling |
| 3.1 | Release Tag | Test tag checkout functionality |
| 3.2 | Release Tag | Test default branch behavior |
| 3.3 | Release Tag | Test tag validation |
| 3.4 | Error Handling | Test invalid tag handling |
| 4.1 | Commit/No-Commit | Test both commit scenarios |
| 4.2 | No-Commit | Verify no commit when disabled |
| 4.3 | Commit | Verify commit when enabled |

## Troubleshooting Test Failures

### Common Issues
1. **Missing Yor Tags**: Check if Yor action is properly configured and templates are valid CloudFormation
2. **Directory Not Found**: Ensure test templates are copied to correct directory
3. **Commit Failures**: Check repository permissions and branch protection rules
4. **Tag Checkout Failures**: Verify tag exists and is accessible

### Debug Steps
1. Check GitHub Actions logs for detailed error messages
2. Verify test template syntax and CloudFormation validity
3. Confirm action inputs are properly configured
4. Review git status and repository state during test execution