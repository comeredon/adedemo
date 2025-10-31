# GitHub Actions Linting Notes

## VS Code Linting Errors

If you see linting errors in VS Code for the GitHub Actions workflows like:

```
Unable to resolve action `Azure/login@v1`, repository or version not found
Context access might be invalid: AZURE_CLIENT_ID
```

**These are VS Code extension issues, not runtime problems.**

### Why This Happens
- The GitHub Actions VS Code extension cache may be outdated
- Network connectivity issues to GitHub's action registry
- Extension version compatibility issues
- VS Code doesn't know about your repository secrets (AZURE_CLIENT_ID, etc.)

### Solutions
1. **Ignore the lint errors** - The workflows will run correctly in GitHub Actions
2. **Restart VS Code** - This refreshes the extension cache
3. **Update the GitHub Actions extension** - Get the latest version
4. **Check internet connectivity** - Extension needs to fetch action metadata

### Verification
The `Azure/login@v1` action is the official Microsoft Azure login action available at:
- https://github.com/marketplace/actions/azure-login
- https://github.com/Azure/login

### Alternative Action References
If linting continues to be problematic, you can also use:
- `azure/login@v1` (lowercase, but same action)
- `Azure/login@v1.4.6` (specific version)

The workflows are tested and working correctly despite the VS Code linting warnings.