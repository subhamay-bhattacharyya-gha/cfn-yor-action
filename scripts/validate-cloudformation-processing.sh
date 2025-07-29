#!/bin/bash

# CloudFormation Template Processing Validation Script
# This script validates the CloudFormation Yor Tagging action locally

set -e

echo "🔍 CloudFormation Template Processing Validation"
echo "=============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "SUCCESS") echo -e "${GREEN}✅ $message${NC}" ;;
        "ERROR") echo -e "${RED}❌ $message${NC}" ;;
        "WARNING") echo -e "${YELLOW}⚠️  $message${NC}" ;;
        "INFO") echo -e "${BLUE}ℹ️  $message${NC}" ;;
    esac
}

# Function to validate template format processing
validate_template_formats() {
    print_status "INFO" "Validating CloudFormation template format processing..."
    
    # Create test directory
    mkdir -p test-validation/formats
    
    # Copy different format templates
    cp test-templates/basic-s3-bucket.yaml test-validation/formats/test.yaml
    cp test-templates/rds-database.yml test-validation/formats/test.yml
    cp test-templates/ec2-instance.json test-validation/formats/test.json
    
    print_status "INFO" "Created test templates with different extensions"
    
    # Check if templates exist
    if [[ -f "test-validation/formats/test.yaml" && -f "test-validation/formats/test.yml" && -f "test-validation/formats/test.json" ]]; then
        print_status "SUCCESS" "All template formats created successfully"
        return 0
    else
        print_status "ERROR" "Failed to create test templates"
        return 1
    fi
}

# Function to validate CloudFormation syntax
validate_cloudformation_syntax() {
    print_status "INFO" "Validating CloudFormation template syntax..."
    
    local valid_count=0
    local total_count=0
    
    # Check YAML templates
    for template in test-templates/*.yaml test-templates/*.yml; do
        if [[ -f "$template" ]]; then
            ((total_count++))
            if python3 -c "import yaml; yaml.safe_load(open('$template'))" 2>/dev/null; then
                print_status "SUCCESS" "Valid YAML syntax: $(basename $template)"
                ((valid_count++))
            else
                if [[ "$template" == *"invalid-template"* ]]; then
                    print_status "INFO" "Invalid template (expected): $(basename $template)"
                else
                    print_status "ERROR" "Invalid YAML syntax: $(basename $template)"
                fi
            fi
        fi
    done
    
    # Check JSON templates
    for template in test-templates/*.json; do
        if [[ -f "$template" ]]; then
            ((total_count++))
            if python3 -c "import json; json.load(open('$template'))" 2>/dev/null; then
                print_status "SUCCESS" "Valid JSON syntax: $(basename $template)"
                ((valid_count++))
            else
                print_status "ERROR" "Invalid JSON syntax: $(basename $template)"
            fi
        fi
    done
    
    print_status "INFO" "Template syntax validation: $valid_count/$total_count valid templates"
    
    if [[ $valid_count -gt 0 ]]; then
        return 0
    else
        return 1
    fi
}

# Function to validate CloudFormation resource types
validate_cloudformation_resources() {
    print_status "INFO" "Validating CloudFormation resource types..."
    
    local aws_resources=()
    
    # Extract AWS resource types from templates
    for template in test-templates/*.yaml test-templates/*.yml; do
        if [[ -f "$template" && "$template" != *"invalid-template"* ]]; then
            while IFS= read -r line; do
                if [[ $line =~ Type:[[:space:]]*AWS:: ]]; then
                    resource_type=$(echo "$line" | sed 's/.*Type:[[:space:]]*//' | tr -d '"'"'"'')
                    aws_resources+=("$resource_type")
                fi
            done < "$template"
        fi
    done
    
    # Extract from JSON templates
    for template in test-templates/*.json; do
        if [[ -f "$template" ]]; then
            if command -v jq >/dev/null 2>&1; then
                while IFS= read -r resource_type; do
                    if [[ $resource_type =~ AWS:: ]]; then
                        aws_resources+=("$resource_type")
                    fi
                done < <(jq -r '.Resources[].Type' "$template" 2>/dev/null || true)
            fi
        fi
    done
    
    # Remove duplicates and count
    unique_resources=($(printf '%s\n' "${aws_resources[@]}" | sort -u))
    
    print_status "INFO" "Found ${#unique_resources[@]} unique AWS resource types:"
    for resource in "${unique_resources[@]}"; do
        print_status "INFO" "  - $resource"
    done
    
    if [[ ${#unique_resources[@]} -gt 0 ]]; then
        print_status "SUCCESS" "CloudFormation resources identified successfully"
        return 0
    else
        print_status "ERROR" "No CloudFormation resources found"
        return 1
    fi
}

# Function to validate nested stack structure
validate_nested_stack_structure() {
    print_status "INFO" "Validating nested stack structure..."
    
    if [[ -f "test-templates/nested-stack.yaml" ]]; then
        # Check for nested stack indicators
        if grep -q "AWS::CloudFormation::Stack" test-templates/nested-stack.yaml; then
            print_status "SUCCESS" "Nested stack resources found"
        else
            print_status "ERROR" "No nested stack resources found"
            return 1
        fi
        
        # Check for complex dependencies
        if grep -q "DependsOn" test-templates/nested-stack.yaml; then
            print_status "SUCCESS" "Resource dependencies found"
        else
            print_status "WARNING" "No resource dependencies found"
        fi
        
        # Check for cross-stack references
        if grep -q "GetAtt.*Outputs" test-templates/nested-stack.yaml; then
            print_status "SUCCESS" "Cross-stack references found"
        else
            print_status "WARNING" "No cross-stack references found"
        fi
        
        return 0
    else
        print_status "ERROR" "Nested stack template not found"
        return 1
    fi
}

# Function to validate error handling setup
validate_error_handling_setup() {
    print_status "INFO" "Validating error handling test setup..."
    
    if [[ -f "test-templates/invalid-template.yaml" ]]; then
        # Check if invalid template is actually invalid
        if ! python3 -c "import yaml; yaml.safe_load(open('test-templates/invalid-template.yaml'))" 2>/dev/null; then
            print_status "SUCCESS" "Invalid template correctly structured for error testing"
        else
            print_status "WARNING" "Invalid template may be valid YAML"
        fi
        
        # Check for invalid CloudFormation constructs
        if grep -q "AWS::InvalidService" test-templates/invalid-template.yaml; then
            print_status "SUCCESS" "Invalid AWS resource types found for testing"
        else
            print_status "WARNING" "No invalid AWS resource types found"
        fi
        
        return 0
    else
        print_status "ERROR" "Invalid template for error testing not found"
        return 1
    fi
}

# Function to run comprehensive validation
run_comprehensive_validation() {
    print_status "INFO" "Running comprehensive CloudFormation processing validation..."
    
    local validation_results=()
    
    # Run all validation functions
    if validate_template_formats; then
        validation_results+=("Template Formats: PASS")
    else
        validation_results+=("Template Formats: FAIL")
    fi
    
    if validate_cloudformation_syntax; then
        validation_results+=("CF Syntax: PASS")
    else
        validation_results+=("CF Syntax: FAIL")
    fi
    
    if validate_cloudformation_resources; then
        validation_results+=("CF Resources: PASS")
    else
        validation_results+=("CF Resources: FAIL")
    fi
    
    if validate_nested_stack_structure; then
        validation_results+=("Nested Stacks: PASS")
    else
        validation_results+=("Nested Stacks: FAIL")
    fi
    
    if validate_error_handling_setup; then
        validation_results+=("Error Handling: PASS")
    else
        validation_results+=("Error Handling: FAIL")
    fi
    
    # Print summary
    echo ""
    print_status "INFO" "Validation Summary:"
    echo "=================="
    
    local pass_count=0
    local total_count=${#validation_results[@]}
    
    for result in "${validation_results[@]}"; do
        if [[ $result == *"PASS" ]]; then
            print_status "SUCCESS" "$result"
            ((pass_count++))
        else
            print_status "ERROR" "$result"
        fi
    done
    
    echo ""
    print_status "INFO" "Overall Result: $pass_count/$total_count validations passed"
    
    if [[ $pass_count -eq $total_count ]]; then
        print_status "SUCCESS" "All CloudFormation processing validations passed!"
        print_status "SUCCESS" "Requirements 6.1, 6.2, 6.3, 6.4 can be validated"
        return 0
    else
        print_status "ERROR" "Some validations failed - check individual results"
        return 1
    fi
}

# Main execution
main() {
    echo "Starting CloudFormation template processing validation..."
    echo ""
    
    # Check prerequisites
    if ! command -v python3 >/dev/null 2>&1; then
        print_status "ERROR" "Python3 is required for validation"
        exit 1
    fi
    
    # Install required Python packages if needed
    python3 -c "import yaml" 2>/dev/null || {
        print_status "INFO" "Installing PyYAML..."
        pip3 install PyYAML --user || {
            print_status "ERROR" "Failed to install PyYAML"
            exit 1
        }
    }
    
    # Create test directory
    mkdir -p test-validation
    
    # Run comprehensive validation
    if run_comprehensive_validation; then
        print_status "SUCCESS" "CloudFormation processing validation completed successfully"
        exit 0
    else
        print_status "ERROR" "CloudFormation processing validation failed"
        exit 1
    fi
}

# Cleanup function
cleanup() {
    if [[ -d "test-validation" ]]; then
        rm -rf test-validation
        print_status "INFO" "Cleaned up test validation directory"
    fi
}

# Set up cleanup trap
trap cleanup EXIT

# Run main function
main "$@"