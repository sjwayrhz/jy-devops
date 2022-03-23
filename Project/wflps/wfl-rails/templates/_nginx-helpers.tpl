{{- define "wfl-rails.nginx.http" }}
nginx.ingress.kubernetes.io/force-ssl-redirect: "false"
nginx.ingress.kubernetes.io/ssl-redirect: "false"
{{ end }}

{{- define "wfl-rails.nginx.https" }}
nginx.ingress.kubernetes.io/ssl-redirect: "true"
{{ end }}

{{- define "wfl-rails.nginx.httpsOnly" }}
nginx.ingress.kubernetes.io/ssl-redirect: "true"
nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
{{ end }}

{{- define "wfl-rails.nginx.enableTls" }}
tls:
  - hosts:
      - {{ .Values.project.fqdn }}
    secretName: tls-wfl-ischool.cn
    # secretName: wfl-ischool.cn-2021-04-29
{{ end }}
