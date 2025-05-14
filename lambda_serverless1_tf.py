import json
import math
import boto3
import os

def lambda_handler(event, context):
    #SNS
    sns_client = boto3.client('sns')
    arn = os.environ['SNS_TOPIC_ARN']

    #dynamoDB
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(os.environ['DDB_TABLE_ARN'])


    R = event['value']
    if R < 1 or R > 20 * 10**3:
        table.update_item(
            Key={
                'sensor_id': event['sensor_id']
            },
            UpdateExpression="set broken = :b",
            ExpressionAttributeValues={
                ':b': True
            }
        )
        return { 
            'error': "VALUE OUT OF RANGE"
        }
    else:
        a = 1.4 * 10**-3
        b = 2.37 * 10**-4
        c = 9.9 * 10**-8

        T = (1/(a + b*math.log(R) + c*math.log(R)**3)) - 273.15
        print(T)

        if T < 20:
            status = "TEMPERATURE.TOO.LOW"
        elif T < 100:
            status = "TEMPERATURE.OK"
        elif T < 250:
            status = "TEMPERATURE.TOO.HIGH"
        else:
            sns_client.publish(
                TopicArn=arn, 
                Message=f"TEMPERATURE.CRITICAL ON SENSOR_ID: {event['sensor_id']}",
                Subject="TEMPERATURE.CRITICAL WARNING")
            status = "TEMPERATURE.CRITICAL"
        return {
            'statusCode': 200,
            'body': json.dumps(status)
        }
