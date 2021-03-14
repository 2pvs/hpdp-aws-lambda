from utils import utils as ut

def lambda_handler(event, context):
    evt = ut.CWAlarm(event)
    queue = ut.Queue()
    alarm = ut.EmptyReceivesAlarm()
    if queue.check_empty():
        alarm.delete()
        print('Reducer job complete')
    else:
        alarm.reset()
        print('Reset alarm')