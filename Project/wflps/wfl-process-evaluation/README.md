# Install
```shell
cd CHART_DIR
git clone git@code.wfl-ischool.cn:liukun/helm-chart-rails-nginx.git
```
# Deploy
```shell
k config use-context K8S_CONFIG_NAME
helm [install|upgrade] DEPLOY_NAME CHARTS_DIR -f values.yaml
```

# 定时任务
1. 已经支持多个定时任务
2. cron变为crons

## Example

```yaml
crons:
  - name: job1
    schedule: "*/5 * * * *"
    command:
      - /bin/sh
      - -c
      - command1
  - name: job2
    schedule: "1 3 * * *"
    command:
      - /bin/sh
      - -c
      - command2
```
# 环境变量
注意！

1. 环境变量不再自动转换小写到大写
2. 数字需要使用双引号，变成字符串
## Example
```yaml
replicaCount: 1

images:
  rails:
    repository: registry-vpc.cn-shanghai.aliyuncs.com/ac-wfl/oa-ac-test
    pullPolicy: Always
    tag: "0.1.0"
  reverse_proxy:
    repository: registry.cn-shanghai.aliyuncs.com/ac-wfl/nginx-reverse-proxy-puma-assets
    pullPolicy: Always
    tag: "0.1.0"

app:
  sidekiq: true
  reverse_proxy: true

app_env:
  RAILS_ENV: production
  RAILS_LOG_TO_STDOUT: enabled
  MYSQL_HOST: rm-uf6l802xo45e94176.mysql.rds.aliyuncs.com
  MYSQL_DB: oa_ac_test
  MYSQL_USER: oa_ac_test_dba
  MYSQL_PASSWORD: xxxxxx
  MYSQL_TIMEOUT: "5000"
  MYSQL_ENCODING: utf8mb4
  MYSQL_COLLATION: utf8mb4_unicode_ci
  REDIS_HOST: r-uf65ov4cm3mlcre65n.redis.rds.aliyuncs.com
  REDIS_PORT: "6379"
  REDIS_NAMESPACE: oa-ac-test
  REDIS_DATA_DB: "0"
  REDIS_JOB_DB: "1"
  REDIS_CACHE_DB: "2"
  RAILS_MAX_THREADS: "16"
  RAILS_MAX_WORKER: "2"
  SCHOOL_ID: "1"
  CUSTOM_PROVIDER_URL: 'http://sso.wfl-ischool.cn'
  APP_ID: 'MxJ8I8uhi6MGceN-'
  APP_SECRET: 'T1ZXD8TIWeVAA90xanvroA'
  SMS_URL: 'http://sms.wfl-ischool.cn'
  SMS_SECRET: '34764323455'
  SECRET_KEY_BASE: f693bc2370224bc987479ef2edfc27379a2d35090532c40f806286c263aee7fc27f370d07884e1879488cf9b5235747931239c04494ce501ec33fcc622a072b5
  LOCAL_HOST: 'http://oa-ac-test.wfl-ischool.cn'

project:
  name: "OA第三方-测试"
  fqdn: oa-ac-test.wfl-ischool.cn
  team: oa
```