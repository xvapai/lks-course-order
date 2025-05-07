FROM 659925004097.dkr.ecr.us-east-1.amazonaws.com/order:latest

RUN apk update && apk add --no-cache \
    curl \
    unzip \
    less \
    groff \
    python3 \
    py3-pip \
    git \
    aws-cli

ARG NODE_ENV=production
ARG PORT=8000
ARG AWS_ACCESS_KEY
ARG AWS_SECRET_KEY

ENV AWS_ACCESS_KEY=$AWS_ACCESS_KEY
ENV AWS_SECRET_KEY=$AWS_SECRET_KEY
ENV PORT=8000
ENV NODE_ENV=${NODE_ENV}
ENV AWS_REGION=us-east-1
ENV AWS_DYNAMODB_TABLE_PROD=lks-order-production
ENV AWS_DYNAMODB_TABLE_TEST=lks-order-testing

RUN export PORT=8000

RUN if [ -n "$CODEBUILD_BUILD_ID" ]; then \
        echo "Running locally... Skipping AWS Credentials Fetch"; \
    else \
        echo "Running inside AWS CodeBuild..."; \
        echo "Fetching credentials from AWS SSM Parameter Store..."; \
        export AWS_ACCESS_KEY=$(aws ssm get-parameter --name "/course-order/AWS_ACCESS_KEY" --with-decryption --query "Parameter.Value" --output text) && \
        export AWS_SECRET_KEY=$(aws ssm get-parameter --name "/course-order/AWS_SECRET_KEY" --with-decryption --query "Parameter.Value" --output text) && \
        echo "AWS Credentials Fetched"; \
    fi

WORKDIR /usr/src/app
COPY . .

RUN node -v
RUN npm -v
RUN npm install

EXPOSE 8000

CMD ["npm", "run", "start"]
