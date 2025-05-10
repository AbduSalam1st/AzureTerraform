import pulumi
import pulumi_azure_native as azure_native
from pulumi_azure_native import resources, storage, web, eventgrid
from pulumi import Output


# 3a. Create an Azure Resource Group
rg = azure_native.resources.ResourceGroup("rg",
    location="UK South",                      
    resource_group_name="VPC1"
)

pulumi.export("resource_group_name", rg.name)

# 3b. Create a Log Analytics Workspace
workspace = azure_native.operationalinsights.Workspace("sentworkspace",
    resource_group_name=rg.name,
    workspace_name="sentworkspace",
    location=rg.location,
    sku=azure_native.operationalinsights.WorkspaceSkuArgs(
        name=azure_native.operationalinsights.WorkspaceSkuNameEnum.PER_GB2018
    ),
    retention_in_days=30,
)
pulumi.export("workspace_id", workspace.id)

# 3c. Enable Azure Sentinel (onboard the workspace)
sentinel = azure_native.securityinsights.SentinelOnboardingState("onboarding",
    resource_group_name=rg.name,
    workspace_name= workspace.id,
    sentinel_onboarding_state_name="default",
    customer_managed_key=False,
)
pulumi.export("sentinel_id", sentinel.id)


# Safe KQL query with fallback to avoid errors if table is empty
malware_query = """
union isfuzzy=true
(
    SecurityAlert
    | where ProviderName == "MDATP"
    | where AlertName contains "Malware"
    | extend HostCustomEntity = tostring(Entities[0].HostName)
),
(datatable(ProviderName:string, AlertName:string, Entities:dynamic, HostCustomEntity:string)[])
"""

# Create the scheduled analytics rule
malware_rule = azure_native.securityinsights.ScheduledAlertRule("malware-detection-rule",
    resource_group_name="rg-sentinel-demo",
    workspace_name="la-sentinel-demo",
    rule_id="malware-detection-rule",  # must be unique
    display_name="Malware Detection on VM",
    description="Detects malware alerts from Microsoft Defender for Endpoint (MDATP) involving VMs.",
    severity="High",
    enabled=True,
    kind="Scheduled",
    query=malware_query,
    query_frequency="PT1H",  # Rule runs every hour
    query_period="PT1H",     # Looks at the last 1 hour of data
    trigger_operator="GreaterThan",
    trigger_threshold=0,
    tactics=["Execution", "Persistence"],
    suppression_enabled=False,
    suppression_duration="PT1H",
    entity_mappings=[
        azure_native.securityinsights.EntityMappingArgs(
            entity_type="Host",
            field_mappings=[
                azure_native.securityinsights.FieldMappingArgs(
                    identifier="FullName",
                    column_name="HostCustomEntity"
                )
            ]
        )
    ]
)



# monitor_rule = azure_native.monitor.ScheduledQueryRule("scheduledQueryRule",
#     actions={
#         "action_groups": ["/subscriptions/394d0ce1-39f1-4a67-bfad-9f7ca4f3cca9/resourcegroups/VPC1/providers/microsoft.insights/actiongroups/myactiongroup"],
#         "action_properties": {
#             "Icm.Title": "Custom title in ICM",
#             "Icm.TsgId": "https://tsg.url",
#         },
#         "custom_properties": {
#             "key11": "value11",
#             "key12": "value12",
#         },
#     },
#     check_workspace_alerts_storage_configured=True,
#     criteria={
#         "all_of": [{
#             "dimensions": [],
#             "failing_periods": {
#                 "min_failing_periods_to_alert": 1,
#                 "number_of_evaluation_periods": 1,
#             },
#             "operator": azure_native.monitor.ConditionOperator.GREATER_THAN,
#             "query": "Heartbeat",
#             "threshold": 360,
#             "time_aggregation": azure_native.monitor.TimeAggregation.COUNT,
#         }],
#     },
#     description="Health check rule",
#     enabled=True,
#     evaluation_frequency="PT5M",
#     location=rg.location,
#     mute_actions_duration="PT30M",
#     resolve_configuration={
#         "auto_resolved": True,
#         "time_to_resolve": "PT10M",
#     },
#     resource_group_name=rg.name,
#     rule_name="triggeredsentinel",
#     scopes=["/subscriptions/394d0ce1-39f1-4a67-bfad-9f7ca4f3cca9/resourceGroups/VPC1"],
#     severity=4,
#     skip_query_validation=True,
#     target_resource_types=["Microsoft.Compute/virtualMachines"],
#     window_size="PT10M")


# # # 5. Azure Function App (retrieved)
# # function_app = azure_native.web.WebApp.get("fn-app",
# #     resource_group_name=rg.name,
# #     name="fn-app")
# # host_keys = azure_native.web.list_web_app_host_keys_output(
# #     resource_group_name="rg-functions-basic",
# #     name=function_app.name)
# # default_key = host_keys.apply(lambda keys: keys.function_keys["default"])
# # endpoint = Output.concat("https://", function_app.default_host_name, "/api/HttpTrigger?code=", default_key)

# # # 6. Create Event Grid Subscription on the Monitor rule
# # event_subscription = azure_native.eventgrid.EventSubscription("malwareAlertToFunction",
# #     scope=monitor_rule.id,  # use the actual .id :contentReference[oaicite:7]{index=7}
# #     event_subscription_name="malwareAlertToFunction",
# #     destination=azure_native.eventgrid.AzureFunctionEventSubscriptionDestinationArgs(
# #         resource_id=Output.concat(function_app.id, "/functions/HttpTrigger1"),
# #         max_events_per_batch=1,
# #         preferred_batch_size_in_kilobytes=64,
# #     ),
# #     filter=azure_native.eventgrid.EventSubscriptionFilterArgs(
# #         included_event_types=["Microsoft.Insights.ScheduledQueryRuleExecuted"],
# #     ))  # :contentReference[oaicite:8]{index=8} :contentReference[oaicite:9]{index=9}

# # pulumi.export("scheduled_query_rule_id", monitor_rule.id)
# # pulumi.export("function_url", endpoint)