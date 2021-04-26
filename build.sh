AWS_PROFILE=myaws
AWS_REGION=eu-central-1
for LAMBDA in Launcher Reducer Worker 
do
    echo $LAMBDA
    cd lambdas/$LAMBDA
    sudo mkdir libs/
    if [ $LAMBDA = "Worker" ]; then
        python3.8 -m pip install Pillow -t .
        sudo cp -R ../../libs/images libs/images/
    fi
    sudo cp -R ../../libs/utils libs/utils/
    zip -r $LAMBDA.zip . 
    aws lambda update-function-code --function-name $LAMBDA --zip-file fileb://$LAMBDA.zip --region $AWS_REGION --profile $AWS_PROFILE
    rm $LAMBDA.zip
    rm -R `ls -1 -d */`
    cd ../../
done