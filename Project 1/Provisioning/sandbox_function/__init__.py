import logging
import azure.functions as func

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    # Extract info from the request body or query parameters
    device_id = req.params.get('deviceId')
    if not device_id:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            device_id = req_body.get('deviceId')

    # Do the “sandboxing” or “isolation” logic here 
    # (call Microsoft Defender for Endpoint, etc.)

    return func.HttpResponse(
        f"Isolated device: {device_id}",
        status_code=200
    )
