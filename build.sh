AWS_PROFILE=myaws
AWS_REGION=eu-central-1
for LAMBDA in Launcher Reducer Worker 
do
    echo $LAMBDA
    cd lambdas/$LAMBDA
    if [ $LAMBDA = "Worker" ]; then
        python3.8 -m pip install Pillow -t .
        cp -R ../../libs/images .
    fi
    cp -R ../../libs/utils .
    zip -r $LAMBDA.zip . 
    aws lambda update-function-code --function-name $LAMBDA --zip-file fileb://$LAMBDA.zip --region $AWS_REGION --profile $AWS_PROFILE
    rm $LAMBDA.zip
    rm -rf ./*
    cd ../../
done