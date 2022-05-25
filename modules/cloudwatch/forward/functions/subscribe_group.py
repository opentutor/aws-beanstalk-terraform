# -*- coding: utf-8 -*-
"""
    Subscribe log group
    ------------

    CloudWatch::CreateLogGroup event handler, creates a subscription filter to the given TARGET_ARN
"""

import json
import logging
import os
from typing import Any, Dict
import boto3


def lambda_handler(event: Dict[str, Any], context: Dict[str, Any]) -> str:
    """
    Lambda function to subscribe newly created log groups

    :param event: lambda expected event object
    :param context: lambda expected context object
    :returns: none
    """
    if os.environ.get("LOG_EVENTS", "False") == "True":
        logging.info(f"Event logging enabled: `{json.dumps(event)}`")

    log_group_to_subscribe = event['detail']['requestParameters']['logGroupName']
    logging.info(f"Subscribing new log group `{log_group_to_subscribe}")

    cloudwatch_logs = boto3.client('logs')

    cloudwatch_logs.put_subscription_filter(
        destinationArn=os.environ.get('TARGET_ARN'),
        filterName=f'{log_group_to_subscribe}-filter',
        filterPattern=' ',
        logGroupName=log_group_to_subscribe,
    )
