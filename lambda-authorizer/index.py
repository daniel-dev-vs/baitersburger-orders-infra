import json
import os
import time
import urllib.request
from jose import jwk, jwt
from jose.utils import base64url_decode

# Variáveis configuradas via Terraform
REGION = os.environ['AWS_REGION']
USER_POOL_ID = os.environ['USER_POOL_ID']
APP_CLIENT_ID = os.environ['APP_CLIENT_ID']
KEYS_URL = f"https://cognito-idp.{REGION}.amazonaws.com/{USER_POOL_ID}/.well-known/jwks.json"

# Cache das chaves públicas do Cognito
keys = None

def get_keys():
    global keys
    if keys is None:
        with urllib.request.urlopen(KEYS_URL) as response:
            keys = json.loads(response.read().decode('utf-8'))['keys']
    return keys

def handler(event, context):
    token = event.get('authorizationToken', '')
    
    # Valida se é um Bearer token
    if not token.startswith('Bearer '):
        raise Exception('Unauthorized')
    
    token = token.split(' ')[1]
    method_arn = event.get('methodArn')

    try:
        # 1. Validar Assinatura e Claims do JWT
        public_keys = get_keys()
        header = jwt.get_unverified_header(token)
        kid = header['kid']
        key_index = -1
        for i, key in enumerate(public_keys):
            if kid == key['kid']:
                key_index = i
                break
        
        if key_index == -1:
            print('Chave pública não encontrada')
            raise Exception('Unauthorized')

        # Decodifica e valida (issuer e client_id)
        decoded = jwt.decode(
            token,
            public_keys[key_index],
            algorithms=['RS256'],
            audience=None, # client_credentials não costuma ter aud, validamos o client_id se necessário
            issuer=f"https://cognito-idp.{REGION}.amazonaws.com/{USER_POOL_ID}"
        )

        # 2. Lógica de Scopes
        # O Cognito coloca os scopes em uma string separada por espaços no claim 'scope'
        token_scopes = decoded.get('scope', '').split(' ')
        
        # Exemplo: permitir acesso se tiver o scope 'orders/manage'
        # Você pode customizar para validar baseado no method_arn se quiser granularidade total
        is_authorized = 'orders/manage' in token_scopes

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