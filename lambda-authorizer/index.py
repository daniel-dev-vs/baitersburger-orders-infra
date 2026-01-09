import json
import os
import time
import urllib.request
from jose import jwk, jwt
from jose.utils import base64url_decode

REGION = os.environ['AWS_REGION']
USER_POOL_ID = os.environ['USER_POOL_ID']
APP_CLIENT_ID = os.environ['APP_CLIENT_ID']
KEYS_URL = f"https://cognito-idp.{REGION}.amazonaws.com/{USER_POOL_ID}/.well-known/jwks.json"

keys = None

def get_keys():
    global keys
    if keys is None:
        with urllib.request.urlopen(KEYS_URL) as response:
            keys = json.loads(response.read().decode('utf-8'))['keys']
    return keys

def handler(event, context):
    token = event.get('authorizationToken', '')
    
    if not token.startswith('Bearer '):
        raise Exception('Unauthorized')
    
    token = token.split(' ')[1]
    method_arn = event.get('methodArn')

    try:
        public_keys = get_keys()
        header = jwt.get_unverified_header(token)
        kid = header['kid']
        key_index = -1
        for i, key in enumerate(public_keys):
            if kid == key['kid']:
                key_index = i
                break
        
        if key_index == -1:
            print('Public key not found in jwks.json')
            raise Exception('Unauthorized')

        decoded = jwt.decode(
            token,
            public_keys[key_index],
            algorithms=['RS256'],
            audience=None, 
            issuer=f"https://cognito-idp.{REGION}.amazonaws.com/{USER_POOL_ID}"
        )

        
        token_scopes = decoded.get('scope', '').split(' ')

        arn_parts = method_arn.split(':')
        api_gateway_parts = arn_parts[-1].split('/')
        http_method = api_gateway_parts[2]
        
        is_authorized = False
        
        if http_method == 'GET':
            is_authorized = 'orders/read' in token_scopes
        elif http_method == 'POST':
            is_authorized = 'orders/write' in token_scopes
        else:
            is_authorized = 'orders/read' in token_scopes or 'orders/write' in token_scopes
        
        return generate_policy('user', 'Allow' if is_authorized else 'Deny', method_arn)

    except Exception as e:
        print(f"Erro na validação: {str(e)}")
        return generate_policy('user', 'Deny', method_arn)

def generate_policy(principal_id, effect, resource):
    return {
        'principalId': principal_id,
        'policyDocument': {
            'Version': '2012-10-17',
            'Statement': [{
                'Action': 'execute-api:Invoke',
                'Effect': effect,
                'Resource': resource
            }]
        }
    }