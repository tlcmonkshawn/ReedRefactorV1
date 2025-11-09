# Render MCP Integration Guide

**Last Updated:** 2025-01-27

---

## Overview

This project uses **Render MCP (Model Context Protocol)** to enable AI assistants to help manage deployments, monitor services, and troubleshoot issues on Render.com.

---

## What is Render MCP?

Render MCP is a Model Context Protocol server that provides AI assistants with programmatic access to Render.com services. It allows AI assistants to:

- **Manage Services**: List, create, update, and monitor Render services
- **View Logs**: Query and filter service logs programmatically
- **Monitor Metrics**: Check CPU, memory, HTTP request metrics, and database connections
- **Manage Deployments**: View deployment history and status
- **Update Configuration**: Modify environment variables and service settings
- **Query Databases**: Run read-only SQL queries on Render PostgreSQL databases

---

## Available MCP Tools

### Service Management

#### `list_services`
List all services in your Render account.

**Use Cases:**
- Check what services are deployed
- Verify service names and IDs
- Find services by type (web, database, etc.)

#### `get_service`
Get detailed information about a specific service.

**Use Cases:**
- Check service configuration
- Verify environment variables
- Check service status and health

#### `get_selected_workspace`
Get the currently selected Render workspace.

**Use Cases:**
- Verify which workspace is active
- Ensure operations are on the correct workspace

#### `select_workspace`
Select a workspace to use for all operations.

**Use Cases:**
- Switch between multiple Render workspaces
- Ensure operations target the correct workspace

### Deployment Management

#### `list_deploys`
List deployments for a service with filtering options.

**Use Cases:**
- View deployment history
- Check recent deployments
- Find specific deployments by status

#### `get_deploy`
Get detailed information about a specific deployment.

**Use Cases:**
- Check deployment status
- View deployment logs
- Troubleshoot failed deployments

### Log Management

#### `list_logs`
Query logs with advanced filtering options.

**Filter Options:**
- Time range (startTime, endTime)
- Log level (INFO, WARNING, ERROR, etc.)
- Resource (service ID, database ID, etc.)
- Text search
- HTTP method, path, status code (for request logs)
- Instance ID

**Use Cases:**
- Debug application errors
- Monitor service health
- Track specific requests or operations
- Filter logs by severity or time

#### `list_log_label_values`
List available values for log labels (for discovering filter options).

**Use Cases:**
- Discover what log levels are available
- Find instance IDs
- See available status codes

### Environment Variables

#### `update_environment_variables`
Update environment variables for a service.

**Features:**
- Merge with existing variables (default)
- Replace all variables (optional)
- Secure variable management

**Use Cases:**
- Update API keys
- Modify configuration
- Add new environment variables
- Fix misconfigured variables

### Metrics & Monitoring

#### `get_metrics`
Get performance metrics for any Render resource.

**Available Metrics:**
- CPU usage, limits, targets
- Memory usage, limits, targets
- HTTP request counts
- HTTP latency (with quantiles)
- Active database connections
- Instance counts
- Bandwidth usage

**Filter Options:**
- Time range
- Resolution (granularity)
- HTTP host and path (for HTTP metrics)
- Aggregation methods

**Use Cases:**
- Monitor service performance
- Debug performance issues
- Track resource usage
- Capacity planning

### Database Management

#### `list_postgres_instances`
List all PostgreSQL databases in your Render account.

**Use Cases:**
- Find database IDs
- Check database status
- Verify database configuration

#### `get_postgres`
Get detailed information about a PostgreSQL database.

**Use Cases:**
- Check database configuration
- Verify connection details
- Check database status

#### `query_render_postgres`
Run read-only SQL queries on Render PostgreSQL databases.

**Features:**
- Read-only queries (wrapped in transaction)
- Automatic connection management
- Safe for production use

**Use Cases:**
- Debug database issues
- Verify data
- Check table schemas
- Monitor database state

---

## Common Use Cases

### 1. Check Deployment Status

**Scenario**: Verify if a recent deployment succeeded.

**MCP Tools Used:**
1. `list_services` - Find the service
2. `list_deploys` - Get recent deployments
3. `get_deploy` - Check deployment status

### 2. Debug Application Errors

**Scenario**: Application is returning 500 errors.

**MCP Tools Used:**
1. `list_logs` - Filter logs by:
   - Level: ERROR
   - Time range: Last hour
   - Resource: Service ID
   - Text: "500" or "error"

### 3. Monitor Service Performance

**Scenario**: Check if service is experiencing high CPU or memory usage.

**MCP Tools Used:**
1. `get_metrics` - Query:
   - Metric types: `cpu_usage`, `memory_usage`
   - Time range: Last hour
   - Resolution: 60 seconds

### 4. Update Environment Variables

**Scenario**: Need to update an API key after rotation.

**MCP Tools Used:**
1. `get_service` - Get current service configuration
2. `update_environment_variables` - Update the API key variable

### 5. Query Database

**Scenario**: Verify that migrations ran correctly.

**MCP Tools Used:**
1. `list_postgres_instances` - Find database ID
2. `query_render_postgres` - Run: `SELECT * FROM schema_migrations ORDER BY version;`

### 6. View Recent Logs

**Scenario**: Check what happened in the last 30 minutes.

**MCP Tools Used:**
1. `list_logs` - Query with:
   - Time range: Last 30 minutes
   - Direction: backward (most recent first)
   - Limit: 100 logs

---

## Best Practices

### 1. Workspace Selection
- Always verify the correct workspace is selected before operations
- Use `get_selected_workspace` to confirm
- Use `select_workspace` if needed

### 2. Log Queries
- Use specific time ranges to avoid large result sets
- Filter by log level to focus on errors
- Use text search for specific error messages
- Start with recent logs (backward direction)

### 3. Metrics Queries
- Use appropriate resolution (60 seconds for hourly, 300 for daily)
- Query specific time ranges to avoid data limits
- Use aggregation methods (AVG, MAX) for CPU/memory

### 4. Environment Variables
- Use merge mode (default) to avoid overwriting other variables
- Only use replace mode when intentionally replacing all variables
- Verify changes with `get_service` after updates

### 5. Database Queries
- Only use read-only queries in production
- Keep queries simple and focused
- Use LIMIT clauses for large tables

---

## Security Considerations

### API Tokens
- Render MCP requires a Render API token
- Token should be stored securely in MCP server configuration
- Never commit tokens to git

### Workspace Access
- Ensure MCP server has access to the correct workspace
- Verify workspace selection before destructive operations

### Read-Only Operations
- Database queries are automatically read-only
- Environment variable updates require explicit confirmation
- Service creation/updates should be reviewed carefully

---

## Troubleshooting

### MCP Server Not Responding
- Verify MCP server is configured correctly
- Check API token is valid
- Ensure workspace access is correct

### No Logs Returned
- Check time range (logs only available for last 30 days)
- Verify resource ID is correct
- Try broader filters (remove specific filters)

### Metrics Not Available
- Some metrics may not be available for all resource types
- Check metric type is valid for the resource
- Verify time range is within last 30 days

### Database Query Fails
- Verify database ID is correct
- Check query syntax
- Ensure query is read-only (no INSERT/UPDATE/DELETE)

---

## Integration with AI Assistants

AI assistants (like Cursor AI) can use Render MCP tools to:

1. **Automated Debugging**: Query logs and metrics to diagnose issues
2. **Deployment Monitoring**: Check deployment status and logs automatically
3. **Configuration Management**: Update environment variables as needed
4. **Performance Analysis**: Monitor metrics and identify bottlenecks
5. **Database Verification**: Query database to verify state

**Example AI Assistant Workflow:**
```
User: "Check if the deployment succeeded"
AI: [Uses list_deploys → get_deploy → reports status]

User: "Why is the service returning 500 errors?"
AI: [Uses list_logs with ERROR filter → analyzes logs → reports findings]

User: "Update the GEMINI_API_KEY environment variable"
AI: [Uses update_environment_variables → confirms update]
```

---

## Related Documentation

- [Deployment Overview](./overview.md) - General deployment guide
- [Troubleshooting](./troubleshooting.md) - Common issues and solutions
- [Viewing Logs](./viewing-logs.md) - Manual log viewing methods
- [Render.com Documentation](https://render.com/docs) - Official Render documentation

---

*Last Updated: 2025-01-27*

