#!/bin/bash

# update-submodules.sh - Update all git submodules recursively with error handling and logging
# Usage: ./scripts/update-submodules.sh

# Enable strict error handling
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log file location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/../logs"
LOG_FILE="${LOG_DIR}/submodule-update-$(date +%Y%m%d-%H%M%S).log"

# Create logs directory if it doesn't exist
mkdir -p "${LOG_DIR}"

# Function to log messages to both console and file
log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Log to file
    echo "[${timestamp}] [${level}] ${message}" >> "${LOG_FILE}"
    
    # Log to console with color
    case ${level} in
        INFO)
            echo -e "${BLUE}[INFO]${NC} ${message}"
            ;;
        SUCCESS)
            echo -e "${GREEN}[SUCCESS]${NC} ${message}"
            ;;
        WARNING)
            echo -e "${YELLOW}[WARNING]${NC} ${message}"
            ;;
        ERROR)
            echo -e "${RED}[ERROR]${NC} ${message}"
            ;;
    esac
}

# Function to handle errors
handle_error() {
    local exit_code=$?
    local line_number=$1
    log ERROR "Script failed at line ${line_number} with exit code ${exit_code}"
    log INFO "Check the log file for details: ${LOG_FILE}"
    exit ${exit_code}
}

# Set up error handling
trap 'handle_error ${LINENO}' ERR

# Function to check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log ERROR "Not in a git repository. Please run this script from the root of your git repository."
        exit 1
    fi
}

# Function to update a single submodule
update_submodule() {
    local submodule_path=$1
    local submodule_name=$(basename "${submodule_path}")
    
    log INFO "Updating submodule: ${submodule_path}"
    
    # Try to update the submodule
    if git submodule update --init --recursive "${submodule_path}" 2>&1 | tee -a "${LOG_FILE}"; then
        log SUCCESS "Successfully updated: ${submodule_path}"
        return 0
    else
        log ERROR "Failed to update: ${submodule_path}"
        return 1
    fi
}

# Main script execution
main() {
    log INFO "=== Starting submodule update process ==="
    log INFO "Log file: ${LOG_FILE}"
    
    # Check if we're in a git repository
    check_git_repo
    
    # Get repository root
    REPO_ROOT=$(git rev-parse --show-toplevel)
    cd "${REPO_ROOT}"
    log INFO "Repository root: ${REPO_ROOT}"
    
    # Check if there are any submodules
    if ! git submodule status > /dev/null 2>&1; then
        log WARNING "No submodules found in this repository"
        exit 0
    fi
    
    # Initialize submodules if needed
    log INFO "Initializing submodules..."
    if git submodule init 2>&1 | tee -a "${LOG_FILE}"; then
        log SUCCESS "Submodules initialized"
    else
        log ERROR "Failed to initialize submodules"
        exit 1
    fi
    
    # Sync submodule URLs
    log INFO "Syncing submodule URLs..."
    if git submodule sync --recursive 2>&1 | tee -a "${LOG_FILE}"; then
        log SUCCESS "Submodule URLs synced"
    else
        log WARNING "Failed to sync some submodule URLs"
    fi
    
    # Get list of all submodules
    log INFO "Fetching list of submodules..."
    submodules=$(git config --file .gitmodules --get-regexp path | awk '{print $2}')
    total_count=$(echo "${submodules}" | wc -l | tr -d ' ')
    
    log INFO "Found ${total_count} submodule(s)"
    
    # Update each submodule
    success_count=0
    failed_count=0
    failed_submodules=""
    
    for submodule in ${submodules}; do
        if update_submodule "${submodule}"; then
            ((success_count++))
        else
            ((failed_count++))
            failed_submodules="${failed_submodules}\n  - ${submodule}"
        fi
    done
    
    # Summary
    log INFO "=== Update Summary ==="
    log INFO "Total submodules: ${total_count}"
    log SUCCESS "Successfully updated: ${success_count}"
    
    if [ ${failed_count} -gt 0 ]; then
        log ERROR "Failed to update: ${failed_count}"
        log ERROR "Failed submodules:${failed_submodules}"
        
        # Ask if user wants to try force update
        echo -e "\n${YELLOW}Would you like to try a force update on failed submodules? (y/N)${NC}"
        read -r response
        if [[ "${response}" =~ ^[Yy]$ ]]; then
            log INFO "Attempting force update on failed submodules..."
            for submodule in ${submodules}; do
                if [[ "${failed_submodules}" == *"${submodule}"* ]]; then
                    log INFO "Force updating: ${submodule}"
                    if git submodule update --init --recursive --force "${submodule}" 2>&1 | tee -a "${LOG_FILE}"; then
                        log SUCCESS "Force update successful: ${submodule}"
                    else
                        log ERROR "Force update failed: ${submodule}"
                    fi
                fi
            done
        fi
    fi
    
    log INFO "=== Update process completed ==="
    log INFO "Full log available at: ${LOG_FILE}"
}

# Run the main function
main "$@"
