
## Configure permissions

- Export vars
```bash
export AWS_PROFILE=test
```

- Create IAM policy document
```json
cat << EOF > ack-sns-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "SNSPermissions",
      "Effect": "Allow",
      "Action": [
        "sns:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "SQSPermissions",
      "Effect": "Allow",
      "Action": [
        "sqs:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "KMSPermissions",
      "Effect": "Allow",
      "Action": [
        "kms:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
```

- Create IAM policy
```bash
aws iam create-policy \
  --policy-name ack-sns \
  --policy-document file://ack-sns-policy.json
```

- Get EKS cluster OIDC provider and account ID
```bash
aws eks describe-cluster \
  --name "test-lok-k8s-main" \
  --query "cluster.identity.oidc.issuer" \
  --output text

aws --profile lokalise-admin-test sts get-caller-identity | jq -r '.Account'
```

- Create IAM role assume policy document
```json
cat << EOF > ack-sns-role.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::542748512672:oidc-provider/oidc.eks.eu-central-1.amazonaws.com/id/8CD4048BE96A0246F2B4B337306D999C"
            },
            "Action": "sts:AssumeRoleWithWebIdentity"
        }
    ]
}
EOF
```

- Create IAM role
```bash
aws iam create-role \
  --role-name "lok-k8s-main-aws-ack-sns-controller@kube-system" \
  --assume-role-policy-document file://ack-sns-role.json
```

- Attach IAM policy to IAM role
```bash
aws iam attach-role-policy \
  --role-name "lok-k8s-main-aws-ack-sns-controller@kube-system" \
  --policy-arn "arn:aws:iam::542748512672:policy/ack-sns"
```

## Install controllers

- Helm charts
  - https://gallery.ecr.aws/aws-controllers-k8s/sqs-chart
  - https://gallery.ecr.aws/aws-controllers-k8s/sns-chart
  - https://gallery.ecr.aws/aws-controllers-k8s/kms-chart

- Values
  ```bash
  helm show values oci://public.ecr.aws/aws-controllers-k8s/sns-chart --version 1.0.2
  ```

- Install ( https://aws-controllers-k8s.github.io/community/docs/user-docs/install/#install-an-ack-service-controller-with-helm-recommended )
  ```
  helm upgrade --install aws-sns oci://public.ecr.aws/aws-controllers-k8s/sns-chart --version 1.0.2 --namespace kube-system --values helm/values/aws-sns.yaml
  ```

## Create resources

- Create SNS topic
```yaml
cat << EOF | kubectl apply -f -
apiVersion: sns.services.k8s.aws/v1alpha1
kind: Topic
metadata:
  name: test-topic
spec:
  name: test-topic
  fifoTopic: "false"
  tags:
    - key: "env"
      value: "test"
EOF
```

- Check
```bash
aws sns list-topics
k get topics
```
