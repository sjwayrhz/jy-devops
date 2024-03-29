以下yaml是ops-k8s-test中的yaml脚本

```
kind: StatefulSet
apiVersion: apps/v1
metadata:
  name: jumpssh
  namespace: ops-ssh
  selfLink: /apis/apps/v1/namespaces/ops-ssh/statefulsets/jumpssh
  uid: 6b8c9ca2-e4c4-47f5-a9bf-aa67873c2fd3
  resourceVersion: '3708140'
  generation: 1
  creationTimestamp: '2021-01-21T00:34:43Z'
  labels:
    appgroup: ''
    version: v1
  annotations:
    description: ''
    field.cattle.io/publicEndpoints: '[{"addresses":["119.3.76.101"],"port":30022,"protocol":"TCP","serviceName":"ops-ssh:jumpssh","allNodes":false}]'
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jumpssh
      version: v1
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: jumpssh
        version: v1
      annotations:
        metrics.alpha.kubernetes.io/custom-endpoints: '[{"api":"","path":"","port":"","names":""}]'
        pod.alpha.kubernetes.io/initialized: 'true'
    spec:
      containers:
        - name: jumpssh
          image: 'swr.cn-east-2.myhuaweicloud.com/lanjing/jumpssh:ops-k8s-test'
          env:
            - name: PAAS_APP_NAME
              value: jumpssh
            - name: PAAS_NAMESPACE
              value: ops-ssh
            - name: PAAS_PROJECT_ID
              value: edce9d162bad450c94c2e9c66ea6a6a9
          resources:
            limits:
              cpu: 250m
              memory: 512Mi
            requests:
              cpu: 250m
              memory: 512Mi
          terminationMessagePath: /dev/termination-log
          terminationMessagePolicy: File
          imagePullPolicy: IfNotPresent
      restartPolicy: Always
      terminationGracePeriodSeconds: 30
      dnsPolicy: ClusterFirst
      securityContext: {}
      imagePullSecrets:
        - name: default-secret
      affinity: {}
      schedulerName: default-scheduler
      tolerations:
        - key: node.kubernetes.io/not-ready
          operator: Exists
          effect: NoExecute
          tolerationSeconds: 300
        - key: node.kubernetes.io/unreachable
          operator: Exists
          effect: NoExecute
          tolerationSeconds: 300
      dnsConfig:
        options:
          - name: timeout
            value: ''
          - name: ndots
            value: '5'
          - name: single-request-reopen
  serviceName: jumpssh-headless
  podManagementPolicy: OrderedReady
  updateStrategy:
    type: RollingUpdate
  revisionHistoryLimit: 10
status:
  observedGeneration: 1
  replicas: 1
  readyReplicas: 1
  currentReplicas: 1
  updatedReplicas: 1
  currentRevision: jumpssh-67dc5dbbf4
  updateRevision: jumpssh-67dc5dbbf4
  collisionCount: 0
```

