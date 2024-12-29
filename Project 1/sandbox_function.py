import os
from azure.identity import DefaultAzureCredential
from azure.mgmt.network import NetworkManagementClient

def main(req):
    import json
    from azure.functions import HttpResponse
    
    # Parse incoming request
    req_body = req.get_json()
    vm_name = req_body.get('vm_name')
    resource_group = req_body.get('resource_group')

    if not vm_name or not resource_group:
        return HttpResponse("Missing vm_name or resource_group in the payload.", status_code=400)

    # Azure credentials
    credential = DefaultAzureCredential()
    subscription_id = os.environ['AZURE_SUBSCRIPTION_ID']

    # Network Management Client
    network_client = NetworkManagementClient(credential, subscription_id)

    try:
        # Retrieve NSG associated with the VM
        nsg_name = f"{vm_name}-nsg"  # Assumes NSG follows VM naming convention
        nsg = network_client.network_security_groups.get(resource_group, nsg_name)

        # Create a Deny-All Rule
        deny_rule = {
            "name": "DenyAllTraffic",
            "priority": 100,
            "direction": "Inbound",
            "access": "Deny",
            "protocol": "*",
            "source_address_prefix": "*",
            "destination_address_prefix": "*",
            "source_port_range": "*",
            "destination_port_range": "*",
        }

        # Append rule to NSG
        nsg.security_rules.append(deny_rule)

        # Update NSG
        network_client.network_security_groups.begin_create_or_update(resource_group, nsg_name, nsg)
        
        return HttpResponse(f"Workstation '{vm_name}' successfully sandboxed!", status_code=200)

    except Exception as e:
        return HttpResponse(f"Error sandboxing workstation: {str(e)}", status_code=500)
