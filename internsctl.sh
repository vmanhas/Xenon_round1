
#!/bin/bash

cli_help() {
    # --help: Shows help message
    echo "
internsctl - Custom command

Usage:
    internsctl [options]

Options:
    --help / -h: Show this message and exit.
    --version / -V: Show current version of command.
    cpu getinfo: Get CPU information.
    memory getinfo: Get memory information.
    user create <username>: Create a new user.
    user list: List regular users.
    user list --sudo-only: List users with sudo permissions.
    file getinfo [options] <file-name>: Get information about a file.
"
    exit
}

cli_version() {
    # --version: Show version
    echo "v0.1.0"
    exit
}

cli_cpu_getinfo() {
    # Retrieve CPU information using lscpu command and display it
    lscpu
    exit
}

cli_memory_getinfo() {
    # Retrieve memory information using free command and display it
    free
    exit
}

cli_user_create() {
    # Create a new user
    if [ -z "$1" ]; then
        echo "Error: Missing username. Usage: internsctl user create <username>"
        exit 1
    fi

    username="$1"
    sudo useradd -m "$username"
    echo "User '$username' has been created."
}

cli_user_list() {
    # List regular users or users with sudo permissions based on arguments
    if [ "$1" = "--sudo-only" ]; then
        getent passwd | cut -d: -f1,3,4 | awk -F: '$2 == 0 {print $1}' | tr '\n' ' '
        echo
    else
        getent passwd | cut -d: -f1,3,4 | awk -F: '$2 >= 1000 {print $1}' | tr '\n' ' '
        echo
    fi
}

cli_file_getinfo() {
    if [ -z "$1" ]; then
        echo "Error: Missing file name. Usage: internsctl file getinfo <file-name>"
        exit 1
    fi

    file="$1"

    # Get file information using stat command
    if [ -f "$file" ]; then
        file_info=$(stat -c "File: %n\nAccess: %A\nSize(B): %s\nOwner: %U" "$file")
        echo -e "$file_info"
    else
        echo "File not found: $file"
        exit 1
    fi
}


# Argument parsing
case $1 in
    "--help" | "-h")
        cli_help
        ;;
    "--version" | "-V")
        cli_version
        ;;
    "cpu")
        case $2 in
            "getinfo")
                cli_cpu_getinfo
                ;;
            *)
                echo "Invalid CPU subcommand: $2"
                cli_help
                ;;
        esac
        ;;
    "memory")
        case $2 in
            "getinfo")
                cli_memory_getinfo
                ;;
            *)
                echo "Invalid memory subcommand: $2"
                cli_help
                ;;
        esac
        ;;
    "user")
        case $2 in
            "create")
                cli_user_create "$3"
                ;;
            "list")
                cli_user_list "$3"
                ;;
            *)
                echo "Invalid user subcommand: $2"
                cli_help
                ;;
        esac
        ;;
    "file")
        case $2 in
            "getinfo")
                cli_file_getinfo "$3"
                ;;
            *)
                echo "Invalid file subcommand: $2"
                cli_help
                ;;
        esac
        ;;
    *)
        echo "Invalid command: $1"
        cli_help
        ;;
esac

# Main program
echo "Intern SCTL custom commands"
