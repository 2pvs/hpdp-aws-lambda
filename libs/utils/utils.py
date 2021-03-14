import boto3
import os
import json
import traceback
from io import BytesIO
from botocore.exceptions import ClientError
from urllib.parse import unquote_plus

queue_url = os.environ['SQS_QUEUE_URL']
queue_name = os.environ['SQS_QUEUE_NAME']
destination_prefix = os.environ['DESTINATION_PREFIX']

s3_client = boto3.client('s3')
sqs_client = boto3.client('sqs')
cw_client = boto3.client('cloudwatch')
sns_client = boto3.client('sns')

class S3Event():
    def __init__(self, event: dict) -> None:
        self.key = unquote_plus(event['Records'][0]['s3']['object']['key'])
        self.bucket = event['Records'][0]['s3']['bucket']['name']
        self.prefix = self.key.rsplit('/',1)[0] if '/' in self.key else '/'

class SQSEvent():
    def __init__(self, event: dict) -> None:
        self.messages = [x['body'] for x in event['Records']]
        self.receipt_handles = [x['receiptHandle'] for x in event['Records']]

class CWAlarm():
    def __init__(self, event: dict) -> None:
        self.alarm_name = event['detail']['alarmName']
        self.alarm_arn = event['resources'][0]

class Folder():
    def __init__(self, bucket: str, prefix: str) -> None:
        self.bucket = bucket
        self.prefix = prefix

    def list_objects(self) -> None:
        self.object_list = []
        paginator = s3_client.get_paginator('list_objects_v2')
        page_iterator = paginator.paginate(Bucket=self.bucket, Prefix=self.prefix)
        for page in page_iterator:
            for key_record in page['Contents']:
                if not key_record['Key'].endswith('/') and not key_record['Key'].endswith('.start'): 
                    self.object_list.append(key_record['Key'])

class Queue():
    def __init__(self):
        self.url = queue_url
        self.destination_prefix = destination_prefix

    def _prepare_message(self, bucket: str, key: str) -> str:
        destination_key = self.destination_prefix + key.rsplit('/',1)[1].rsplit('.',1)[0] + '.jpeg'
        message = {
            'source_bucket': bucket, 
            'source_key': key,
            'destination_bucket': bucket,
            'destination_key': destination_key
            }
        return json.dumps(message, ensure_ascii=False)
    
    def push_objects(self, bucket:str, key_list: list) -> None:
        sqs_entries=[]
        for i, key in enumerate(key_list):
            msg = self._prepare_message(bucket, key)
            sqs_entries.append({'Id':str(i).zfill(12),'MessageBody':msg})
            if i != 0 and ((i+1)%10 == 0 or i == len(key_list)-1):
                response=sqs_client.send_message_batch(QueueUrl=self.url, Entries=sqs_entries)
                if response.get('Failed',[]):
                    print('ERROR: SQS send message failed')
                    for m in response['Failed']:
                        response = sqs_client.send_message(QueueUrl=self.url, MessageBody=m['Message'])
                sqs_entries=[]

    def delete_message(self, receipt_handle):
        sqs_client.delete_message(QueueUrl=self.url, ReceiptHandle=receipt_handle)

    def check_empty(self):
        re = sqs_client.get_queue_attributes(QueueUrl=self.url, AttributeNames=['All'])
        messages_left = sum([int(re['Attributes'][a]) for a in
                             ['ApproximateNumberOfMessages', 'ApproximateNumberOfMessagesDelayed',
                              'ApproximateNumberOfMessagesNotVisible']])
        return messages_left == 0

class QueueMessage():
    def __init__(self, message):
        self.message = json.loads(message)
        self.source_bucket = self.message['source_bucket']
        self.source_key = self.message['source_key']
        self.destination_bucket = self.message['destination_bucket']
        self.destination_key = self.message['destination_key']

    def read_obj_from_s3(self):
        return BytesIO(s3_client.get_object(Bucket=self.source_bucket, Key=self.source_key)['Body'].read())

    def save_obj_to_s3(self, result_file):
        try:
            s3_client.put_object(Bucket=self.destination_bucket, Key=self.destination_key, Body=result_file.getvalue()) 
        except ClientError:
            print('ERROR: file not saved: ', traceback.format_exc())
            return False
        return True

class EmptyReceivesAlarm():
    def __init__(self):
        self.name = queue_name

    def put(self):
        cw_client.put_metric_alarm(
            AlarmName=self.name,
            EvaluationPeriods=1,
            DatapointsToAlarm=1,
            Threshold=0.0,
            ComparisonOperator='GreaterThanOrEqualToThreshold',
            TreatMissingData='missing',
            MetricName = "NumberOfEmptyReceives",
            Namespace = "AWS/SQS",
            Dimensions = [
                {
                    "Name": "QueueName",
                    "Value": queue_name
                },
            ],
            Statistic = "Sum",
            Period = 60
        )

    def delete(self):
        cw_client.delete_alarms(AlarmNames=[self.name])

    def reset(self):
        self.delete_queue_empty_alarm()
        self.put_queue_empty_alarm()

