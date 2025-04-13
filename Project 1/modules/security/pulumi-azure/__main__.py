import json
import pulumi
from pulumi_azure_native import securityinsights, operationalinsights, resources

# Extract values from JSON config (using correct key names and case)
resource_location = config_data.get("Resource_location") 
resource_group_name = config_data.get("resource_group_name")


resourceGroup = resources.Resoures


# Create Log Analytics Workspace
workspace = operationalinsights.Workspace(
    "laworkspace",
    resource_group_name=resource_group.name

    location=resource_location,  # Use variable from JSON
    sku=operationalinsights.WorkspaceSkuArgs(name="PerGB2018"),
    retention_in_days=90
)

# Complete the KQL query with proper syntax
MALWARE_QUERY = """SecurityEvent
| where EventID == 4688
| where ProcessCommandLine has_any (
    "powershell -e", 
    "certutil -urlcache", 
    "mshta.exe", 
    "rundll32.exe", 
    "wscript.exe"
)
| extend MalwareIndicator = case(
    ProcessCommandLine contains "powershell -e", "Suspicious PowerShell Encoded Command",
    ProcessCommandLine contains "certutil -urlcache", "Abusing CertUtil for Download",
    ProcessCommandLine contains "mshta.exe", "Malicious HTA Execution",
    ProcessCommandLine contains "rundll32.exe", "Suspicious DLL Execution",
    ProcessCommandLine contains "wscript.exe", "Suspicious Script Execution",
    "Other"
)
| where MalwareIndicator != "Other"
| summarize by Computer, ProcessCommandLine, MalwareIndicator"""

# ... (previous imports and config loading remain the same)

# Create Sentinel Alert Rule (corrected)
malware_alert_rule = securityinsights.ScheduledAlertRule(
    "malware-process-detection",
    resource_group_name=resource_group.name,
    workspace_name=workspace.name,
    # Add the required 'kind' property:
    kind="Scheduled",  # <-- THIS IS REQUIRED
    display_name="Malware Process Execution Detection",
    description="Detects suspicious processes indicative of malware execution",
    severity="Medium",
    enabled=True,
    query=MALWARE_QUERY,
    query_frequency="PT5M",
    query_period="PT24H",
    trigger_operator="GreaterThan",
    trigger_threshold=0,
    suppression_duration="PT1H",
    suppression_enabled=False,
    tactics=["Execution"],
    incident_configuration=securityinsights.IncidentConfigurationArgs(
        create_incident=True
    ),
    entity_mappings=[
        securityinsights.EntityMappingArgs(
            entity_type="Host",
            field_mappings=[
                securityinsights.FieldMappingArgs(
                    identifier="FullName",
                    column_name="Computer"
                )
            ]
        )
    ]
)



# infected_endpoint = securityinsights.EntityMappingArgs(
#             entity_type="Host",
#             field_mappings=[
#                 securityinsights.FieldMappingArgs(
#                     identifier="FullName",
#                     column_name="Computer")
#                     ]
#                     )



# def isolation(computerID):
    